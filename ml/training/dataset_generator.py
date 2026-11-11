"""
Dataset Generator for Thrifty AI Condition Grading and Category Classification.
Generates structured image datasets across the 4 proposal categories and 4 condition grades:
Categories: Shirt, T-Shirt, Pants, Jacket
Grades: Grade A (Like New), Grade B (Very Good), Grade C (Good/Usable), Grade D (Significant Wear)
"""

import os
import random
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageEnhance

CATEGORIES = ['Shirt', 'T-Shirt', 'Pants', 'Jacket']
GRADES = ['Grade A', 'Grade B', 'Grade C', 'Grade D']

# Color palettes for realistic secondhand clothes
PALETTES = [
    (30, 41, 59),    # Navy / Dark Slate
    (71, 85, 105),   # Slate Grey
    (185, 28, 28),   # Vintage Red
    (29, 78, 216),   # Royal Blue
    (20, 83, 45),    # Forest Green
    (194, 65, 12),   # Terracotta
    (245, 245, 240), # Off-white / Cream
    (17, 24, 39),    # Charcoal Black
    (217, 119, 6),   # Mustard Yellow
    (120, 53, 15),   # Brown Earth
]

def draw_clothing_shape(draw, category, width, height, base_color):
    """Draws representative silhouettes of the 4 clothing categories."""
    cx = width // 2
    cy = height // 2

    if category == 'T-Shirt':
        # Torso and short sleeves
        body = [
            (cx - 50, cy - 60),  # left neck
            (cx - 30, cy - 50),  # collar dip
            (cx + 30, cy - 50),  # collar dip right
            (cx + 50, cy - 60),  # right neck
            (cx + 90, cy - 35),  # right shoulder
            (cx + 85, cy + 10),  # right sleeve bottom
            (cx + 55, cy - 5),   # right armpit
            (cx + 50, cy + 70),  # right hem
            (cx - 50, cy + 70),  # left hem
            (cx - 55, cy - 5),   # left armpit
            (cx - 85, cy + 10),  # left sleeve bottom
            (cx - 90, cy - 35),  # left shoulder
        ]
        draw.polygon(body, fill=base_color, outline=(20, 20, 20))
        # Draw crew neck curve
        draw.arc([cx - 30, cy - 65, cx + 30, cy - 45], start=0, end=180, fill=(30, 30, 30), width=3)

    elif category == 'Shirt':
        # Button-down shirt with collar and cuffs
        body = [
            (cx - 45, cy - 65),
            (cx + 45, cy - 65),
            (cx + 95, cy - 25),  # long sleeve top
            (cx + 80, cy + 40),  # cuff
            (cx + 55, cy - 10),  # armpit
            (cx + 48, cy + 75),  # bottom right
            (cx - 48, cy + 75),  # bottom left
            (cx - 55, cy - 10),  # armpit
            (cx - 80, cy + 40),  # cuff
            (cx - 95, cy - 25),  # sleeve top
        ]
        draw.polygon(body, fill=base_color, outline=(20, 20, 20))
        # Collar flaps
        draw.polygon([(cx - 40, cy - 65), (cx, cy - 45), (cx - 15, cy - 65)], fill=(base_color[0]+15, base_color[1]+15, base_color[2]+15), outline=(10, 10, 10))
        draw.polygon([(cx + 40, cy - 65), (cx, cy - 45), (cx + 15, cy - 65)], fill=(base_color[0]+15, base_color[1]+15, base_color[2]+15), outline=(10, 10, 10))
        # Placket center line & buttons
        draw.line([(cx, cy - 45), (cx, cy + 75)], fill=(30, 30, 30), width=2)
        for by in range(cy - 30, cy + 65, 20):
            draw.ellipse([cx - 3, by - 3, cx + 3, by + 3], fill=(240, 240, 240), outline=(20, 20, 20))

    elif category == 'Pants':
        # Trousers / Jeans silhouette
        body = [
            (cx - 45, cy - 70),  # waist left
            (cx + 45, cy - 70),  # waist right
            (cx + 50, cy - 30),  # hip right
            (cx + 45, cy + 85),  # right cuff outer
            (cx + 10, cy + 85),  # right cuff inner
            (cx, cy - 15),       # crotch
            (cx - 10, cy + 85),  # left cuff inner
            (cx - 45, cy + 85),  # left cuff outer
            (cx - 50, cy - 30),  # hip left
        ]
        draw.polygon(body, fill=base_color, outline=(20, 20, 20))
        # Waistband & fly line
        draw.line([(cx - 45, cy - 60), (cx + 45, cy - 60)], fill=(30, 30, 30), width=2)
        draw.line([(cx, cy - 60), (cx, cy - 20)], fill=(30, 30, 30), width=2)

    elif category == 'Jacket':
        # Outerwear jacket with zipper and pockets
        body = [
            (cx - 55, cy - 65),
            (cx + 55, cy - 65),
            (cx + 100, cy - 20),
            (cx + 85, cy + 50),
            (cx + 60, cy - 5),
            (cx + 58, cy + 75),
            (cx - 58, cy + 75),
            (cx - 60, cy - 5),
            (cx - 85, cy + 50),
            (cx - 100, cy - 20),
        ]
        draw.polygon(body, fill=base_color, outline=(20, 20, 20))
        # Heavy zipper line
        draw.line([(cx, cy - 65), (cx, cy + 75)], fill=(200, 200, 200), width=4)
        # Side pockets
        draw.rectangle([cx - 45, cy + 20, cx - 15, cy + 50], outline=(40, 40, 40), width=2)
        draw.rectangle([cx + 15, cy + 20, cx + 45, cy + 50], outline=(40, 40, 40), width=2)

def apply_condition_grade(image, grade):
    """
    Applies authentic visual defects corresponding to condition grades:
    Grade A: Pristine, sharp, high contrast, clean.
    Grade B: Slight color wash, minor fabric softening.
    Grade C: Visible fading, light pilling, slight stain or discoloration spot.
    Grade D: Strong fabric fading, fraying, visible distress/stain/tear marks.
    """
    img = image.copy()
    draw = ImageDraw.Draw(img)
    w, h = img.size

    if grade == 'Grade A':
        # Crisp, bright, no blemishes
        enhancer = ImageEnhance.Sharpness(img)
        img = enhancer.enhance(1.2)
        color_enh = ImageEnhance.Color(img)
        img = color_enh.enhance(1.1)

    elif grade == 'Grade B':
        # Subtle softening and mild wash
        enhancer = ImageEnhance.Color(img)
        img = enhancer.enhance(0.92)
        bright_enh = ImageEnhance.Brightness(img)
        img = bright_enh.enhance(1.02)

    elif grade == 'Grade C':
        # Noticeable wear: faded color + faint stain / rub mark
        enhancer = ImageEnhance.Color(img)
        img = enhancer.enhance(0.80)
        contrast = ImageEnhance.Contrast(img)
        img = contrast.enhance(0.85)

        # Add faint wear patch or discoloration spot
        draw = ImageDraw.Draw(img)
        spot_x = random.randint(w // 3, 2 * w // 3)
        spot_y = random.randint(h // 3, 2 * h // 3)
        spot_r = random.randint(12, 22)
        draw.ellipse([spot_x - spot_r, spot_y - spot_r, spot_x + spot_r, spot_y + spot_r],
                     fill=(210, 190, 160, 90), outline=None)
        img = img.filter(ImageFilter.GaussianBlur(radius=0.6))

    elif grade == 'Grade D':
        # Heavy wear: strong wash, fray lines, multiple visible marks
        enhancer = ImageEnhance.Color(img)
        img = enhancer.enhance(0.65)
        contrast = ImageEnhance.Contrast(img)
        img = contrast.enhance(0.75)

        draw = ImageDraw.Draw(img)
        # Wear scratches / fray marks
        for _ in range(4):
            x1 = random.randint(w // 4, 3 * w // 4)
            y1 = random.randint(h // 4, 3 * h // 4)
            x2 = x1 + random.randint(-20, 20)
            y2 = y1 + random.randint(5, 25)
            draw.line([(x1, y1), (x2, y2)], fill=(130, 120, 110), width=random.randint(2, 4))

        # Noticeable stain spot
        sx = random.randint(w // 4, 3 * w // 4)
        sy = random.randint(h // 4, 3 * h // 4)
        draw.ellipse([sx - 15, sy - 15, sx + 15, sy + 15], fill=(160, 140, 110), outline=None)
        img = img.filter(ImageFilter.GaussianBlur(radius=0.8))

    return img

def generate_sample(category, grade, size=(224, 224)):
    """Creates a synthetic clothing sample image with background and realistic lighting."""
    # Background: clean photo backdrop (white, light grey, or wooden tone)
    bg_choice = random.choice([
        (248, 249, 250), # studio white
        (238, 240, 242), # light grey
        (244, 241, 234), # neutral beige
    ])
    image = Image.new('RGB', size, bg_choice)
    draw = ImageDraw.Draw(image)

    # Base clothing color
    base_color = random.choice(PALETTES)
    # Slight color jitter
    jitter = random.randint(-15, 15)
    base_color = tuple(max(0, min(255, c + jitter)) for c in base_color)

    # Draw silhouette
    draw_clothing_shape(draw, category, size[0], size[1], base_color)

    # Add cloth texture noise
    noise = np.random.normal(0, 4, (size[1], size[0], 3)).astype(np.int16)
    img_np = np.clip(np.array(image, dtype=np.int16) + noise, 0, 255).astype(np.uint8)
    image = Image.fromarray(img_np)

    # Apply condition grade characteristics
    image = apply_condition_grade(image, grade)
    return image

def build_dataset(base_dir='ml/data', samples_per_class=60):
    """
    Generates dataset split into train (80%), val (10%), test (10%)
    covering all 4 categories x 4 condition grades = 16 combinations.
    Total samples = 16 x 60 = 960 images.
    """
    splits = {
        'train': int(samples_per_class * 0.8), # 48
        'val': int(samples_per_class * 0.1),   # 6
        'test': samples_per_class - int(samples_per_class * 0.8) - int(samples_per_class * 0.1) # 6
    }

    print(f"Generating dataset in {base_dir} with splits: {splits}")
    count = 0
    for split_name, split_count in splits.items():
        for category in CATEGORIES:
            for grade in GRADES:
                folder = os.path.join(base_dir, 'processed', split_name, f"{category}__{grade.replace(' ', '_')}")
                os.makedirs(folder, exist_ok=True)
                for i in range(split_count):
                    img = generate_sample(category, grade)
                    filename = f"img_{category}_{grade.replace(' ', '')}_{i:03d}.jpg"
                    img.save(os.path.join(folder, filename), quality=92)
                    count += 1

    print(f"Dataset generation complete! Created {count} images across all splits.")

if __name__ == '__main__':
    build_dataset()
