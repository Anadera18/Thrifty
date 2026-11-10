"""
Thrifty MobileNetV2 Multi-Task Training Pipeline:
1. Clothing Category Classification (Shirt, T-Shirt, Pants, Jacket)
2. Condition Grading (Grade A, Grade B, Grade C, Grade D)
Fulfills Proposal Section 6.2 and Appendix C.
"""

import os
import json
import numpy as np
from PIL import Image
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models
from sklearn.metrics import classification_report, confusion_matrix
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns

CATEGORIES = ['Shirt', 'T-Shirt', 'Pants', 'Jacket']
GRADES = ['Grade A', 'Grade B', 'Grade C', 'Grade D']
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 8

def load_split(split_dir):
    """Loads images, category labels, and grade labels from structured folders."""
    images = []
    cat_labels = []
    grade_labels = []

    for folder_name in os.listdir(split_dir):
        folder_path = os.path.join(split_dir, folder_name)
        if not os.path.isdir(folder_path):
            continue
        parts = folder_name.split('__')
        if len(parts) != 2:
            continue
        cat_name, grade_raw = parts
        grade_name = grade_raw.replace('_', ' ')

        if cat_name not in CATEGORIES or grade_name not in GRADES:
            continue

        cat_idx = CATEGORIES.index(cat_name)
        grade_idx = GRADES.index(grade_name)

        for fname in os.listdir(folder_path):
            if fname.lower().endswith(('.jpg', '.jpeg', '.png')):
                fpath = os.path.join(folder_path, fname)
                try:
                    with Image.open(fpath) as img:
                        img = img.convert('RGB').resize(IMG_SIZE)
                        images.append(np.array(img, dtype=np.float32) / 255.0)
                        cat_labels.append(cat_idx)
                        grade_labels.append(grade_idx)
                except Exception as e:
                    print(f"Skipping {fpath}: {e}")

    X = np.array(images, dtype=np.float32)
    y_cat = tf.keras.utils.to_categorical(cat_labels, num_classes=len(CATEGORIES))
    y_grade = tf.keras.utils.to_categorical(grade_labels, num_classes=len(GRADES))
    return X, y_cat, y_grade, np.array(cat_labels), np.array(grade_labels)

def build_multitask_mobilenetv2():
    """
    Builds a Dual-Head Transfer Learning Network using MobileNetV2 backbone.
    Shared backbone extracts rich semantic clothing features.
    Head 1 classifies Category (Shirt, T-Shirt, Pants, Jacket).
    Head 2 classifies Condition Grade (Grade A, B, C, D).
    """
    base_model = tf.keras.applications.MobileNetV2(
        input_shape=(224, 224, 3),
        include_top=False,
        weights='imagenet'
    )
    # Freeze base model weights for initial transfer learning
    base_model.trainable = False

    inputs = layers.Input(shape=(224, 224, 3), name='clothing_image_input')
    
    # Preprocessing / normalization for MobileNetV2
    x = layers.Rescaling(scale=2.0, offset=-1.0)(inputs) # maps [0, 1] to [-1, 1]
    
    # Feature extractor
    features = base_model(x, training=False)
    pooled = layers.GlobalAveragePooling2D(name='global_pooling')(features)
    shared_dense = layers.Dense(128, activation='relu', name='shared_features')(pooled)
    shared_dense = layers.BatchNormalization()(shared_dense)
    shared_dense = layers.Dropout(0.3)(shared_dense)

    # Head 1: Category Classification
    cat_dense = layers.Dense(64, activation='relu', name='category_features')(shared_dense)
    cat_dense = layers.Dropout(0.2)(cat_dense)
    cat_output = layers.Dense(len(CATEGORIES), activation='softmax', name='category_output')(cat_dense)

    # Head 2: Condition Grading
    grade_dense = layers.Dense(64, activation='relu', name='grade_features')(shared_dense)
    grade_dense = layers.Dropout(0.2)(grade_dense)
    grade_output = layers.Dense(len(GRADES), activation='softmax', name='grade_output')(grade_dense)

    model = models.Model(
        inputs=inputs,
        outputs={'category_output': cat_output, 'grade_output': grade_output},
        name='Thrifty_MobileNetV2_MultiTask'
    )

    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
        loss={
            'category_output': 'categorical_crossentropy',
            'grade_output': 'categorical_crossentropy'
        },
        loss_weights={
            'category_output': 1.0,
            'grade_output': 1.2  # slightly higher focus on condition grading
        },
        metrics={
            'category_output': ['accuracy'],
            'grade_output': ['accuracy']
        }
    )

    return model

def main():
    print("=" * 60)
    print("Starting Thrifty AI Condition Grading & Classification Training")
    print("=" * 60)

    data_dir = os.path.join('ml', 'data', 'processed')
    models_dir = os.path.join('ml', 'models')
    reports_dir = os.path.join('ml', 'reports')
    os.makedirs(models_dir, exist_ok=True)
    os.makedirs(reports_dir, exist_ok=True)

    print("1. Loading dataset splits (train / val / test)...")
    X_train, y_train_cat, y_train_grade, train_cat_raw, train_grade_raw = load_split(os.path.join(data_dir, 'train'))
    X_val, y_val_cat, y_val_grade, val_cat_raw, val_grade_raw = load_split(os.path.join(data_dir, 'val'))
    X_test, y_test_cat, y_test_grade, test_cat_raw, test_grade_raw = load_split(os.path.join(data_dir, 'test'))

    print(f"Dataset summary:")
    print(f"  Training samples:   {len(X_train)}")
    print(f"  Validation samples: {len(X_val)}")
    print(f"  Testing samples:    {len(X_test)}")

    print("\n2. Initializing MobileNetV2 Dual-Head Architecture...")
    model = build_multitask_mobilenetv2()
    model.summary()

    print("\n3. Training model...")
    callbacks = [
        tf.keras.callbacks.EarlyStopping(monitor='val_grade_output_accuracy', mode='max', patience=3, restore_best_weights=True),
        tf.keras.callbacks.ReduceLROnPlateau(monitor='val_loss', mode='min', factor=0.5, patience=2, min_lr=1e-5)
    ]

    history = model.fit(
        X_train,
        {'category_output': y_train_cat, 'grade_output': y_train_grade},
        validation_data=(X_val, {'category_output': y_val_cat, 'grade_output': y_val_grade}),
        epochs=EPOCHS,
        batch_size=BATCH_SIZE,
        callbacks=callbacks,
        verbose=1
    )

    print("\n4. Evaluating model on unseen test split...")
    eval_results = model.evaluate(
        X_test,
        {'category_output': y_test_cat, 'grade_output': y_test_grade},
        verbose=0
    )
    
    loss_names = model.metrics_names
    metrics_dict = dict(zip(loss_names, eval_results))
    print("Test Metrics:", json.dumps({k: round(float(v), 4) for k, v in metrics_dict.items()}, indent=2))

    # Detailed test predictions
    preds = model.predict(X_test)
    pred_cats = np.argmax(preds['category_output'], axis=1)
    pred_grades = np.argmax(preds['grade_output'], axis=1)

    cat_acc = float(np.mean(pred_cats == test_cat_raw))
    grade_acc = float(np.mean(pred_grades == test_grade_raw))
    print(f"\nFinal Test Results:")
    print(f"  -> Category Classification Accuracy: {cat_acc * 100:.2f}%")
    print(f"  -> Clothing Condition Grading Accuracy: {grade_acc * 100:.2f}% (Target: >= 80.00%)")

    # Generate Classification Reports
    cat_report = classification_report(test_cat_raw, pred_cats, target_names=CATEGORIES, output_dict=True)
    grade_report = classification_report(test_grade_raw, pred_grades, target_names=GRADES, output_dict=True)

    report_summary = {
        'model_name': 'Thrifty_MobileNetV2_MultiTask',
        'metrics': {
            'category_accuracy': cat_acc,
            'grade_accuracy': grade_acc,
            'category_report': cat_report,
            'grade_report': grade_report
        }
    }
    with open(os.path.join(reports_dir, 'evaluation_report.json'), 'w') as f:
        json.dump(report_summary, f, indent=2)

    # Plot Confusion Matrices
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    cm_cat = confusion_matrix(test_cat_raw, pred_cats)
    sns.heatmap(cm_cat, annot=True, fmt='d', cmap='Blues', xticklabels=CATEGORIES, yticklabels=CATEGORIES, ax=axes[0])
    axes[0].set_title(f"Category Confusion Matrix (Acc: {cat_acc*100:.1f}%)")
    axes[0].set_ylabel('True Label')
    axes[0].set_xlabel('Predicted Label')

    cm_grade = confusion_matrix(test_grade_raw, pred_grades)
    sns.heatmap(cm_grade, annot=True, fmt='d', cmap='Greens', xticklabels=GRADES, yticklabels=GRADES, ax=axes[1])
    axes[1].set_title(f"Condition Grade Confusion Matrix (Acc: {grade_acc*100:.1f}%)")
    axes[1].set_ylabel('True Label')
    axes[1].set_xlabel('Predicted Label')

    plt.tight_layout()
    plt.savefig(os.path.join(reports_dir, 'confusion_matrix.png'), dpi=200)
    plt.close()

    # Plot Training Curves
    fig, axes = plt.subplots(1, 2, figsize=(14, 4))
    axes[0].plot(history.history['category_output_accuracy'], label='Train Cat Acc')
    axes[0].plot(history.history['val_category_output_accuracy'], label='Val Cat Acc')
    axes[0].plot(history.history['grade_output_accuracy'], label='Train Grade Acc')
    axes[0].plot(history.history['val_grade_output_accuracy'], label='Val Grade Acc')
    axes[0].set_title('Training & Validation Accuracy')
    axes[0].set_xlabel('Epoch')
    axes[0].set_ylabel('Accuracy')
    axes[0].legend()

    axes[1].plot(history.history['loss'], label='Total Train Loss')
    axes[1].plot(history.history['val_loss'], label='Total Val Loss')
    axes[1].set_title('Training & Validation Loss')
    axes[1].set_xlabel('Epoch')
    axes[1].set_ylabel('Loss')
    axes[1].legend()

    plt.tight_layout()
    plt.savefig(os.path.join(reports_dir, 'training_curves.png'), dpi=200)
    plt.close()

    print("\n5. Saving Keras Model and Metadata...")
    keras_path = os.path.join(models_dir, 'thrifty_model.keras')
    model.save(keras_path)
    print(f"Saved Keras model: {keras_path}")

    metadata = {
        'model_name': 'Thrifty MobileNetV2 Dual-Head',
        'backbone': 'MobileNetV2 (ImageNet pretrained)',
        'categories': CATEGORIES,
        'grades': GRADES,
        'grade_descriptions': {
            'Grade A': 'Like New - Clothing appears almost new, with little to no visible sign of use.',
            'Grade B': 'Very Good - Clothing shows minor visible signs of use but remains in very good condition.',
            'Grade C': 'Good / Usable - Clothing shows visible signs of use or minor defects but remains fully usable.',
            'Grade D': 'Significant Wear - Clothing shows noticeable visible defects or substantial signs of wear.'
        },
        'test_category_accuracy': round(cat_acc, 4),
        'test_grade_accuracy': round(grade_acc, 4),
        'input_shape': [224, 224, 3]
    }
    with open(os.path.join(models_dir, 'metadata.json'), 'w') as f:
        json.dump(metadata, f, indent=2)

    print("\n6. Exporting Optimized TFLite Model...")
    try:
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        tflite_model = converter.convert()
        tflite_path = os.path.join(models_dir, 'thrifty_model.tflite')
        with open(tflite_path, 'wb') as f:
            f.write(tflite_model)
        print(f"Exported TFLite Model: {tflite_path} ({len(tflite_model) / 1024:.1f} KB)")
    except Exception as e:
        print(f"TFLite export note: {e}")

    # Mirror to ml/results for convenience
    results_dir = os.path.join('ml', 'results')
    if os.path.exists(results_dir):
        import shutil
        for rf in ['evaluation_report.json', 'confusion_matrix.png', 'training_curves.png']:
            src = os.path.join(reports_dir, rf)
            if os.path.exists(src):
                shutil.copy2(src, os.path.join(results_dir, rf))
        print("Mirrored evaluation reports to ml/results/")

    print("\nTraining & evaluation completed successfully!")

if __name__ == '__main__':
    main()
