import 'package:flutter/material.dart';

class AiGradingResultScreen extends StatelessWidget {
  const AiGradingResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('AI Condition Check', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            // Subheader Step
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.teal[100],
                      child: const Text('2', style: TextStyle(fontSize: 10, color: Colors.teal, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    const Text('STEP 2 OF 3 · AI CONDITION INSPECTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
                Row(
                  children: const [
                    Icon(Icons.auto_awesome, size: 12, color: Colors.teal),
                    SizedBox(width: 4),
                    Text('DIAGNOSTIC COMPLETE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.teal)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Box Preview Gambar & Tag Inspeksi AI
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage('https://picsum.photos/400/400'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Tag 1: Collar
                  Positioned(
                    top: 16,
                    left: 16,
                    child: _buildInspectionBadge('Collar: Minimal wear'),
                  ),
                  // Tag 2: Fabric
                  Positioned(
                    top: 32,
                    right: 16,
                    child: _buildInspectionBadge('Fabric: 100% Cotton'),
                  ),
                  // Tag 3: Screenprint
                  Positioned(
                    bottom: 40,
                    left: 16,
                    child: _buildInspectionBadge('Screenprint: Gentle patina (no cracks)'),
                  ),
                  // Bar analisis bawah gambar
                  Positioned(
                    bottom: 8,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 12, color: Colors.green),
                        const SizedBox(width: 4),
                        const Text('100% Surface Analyzed', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const LinearProgressIndicator(value: 1.0, color: Colors.green, minHeight: 4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card Evaluated Grade
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('EVALUATED GRADE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text('Confidence', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006828),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.check_circle, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Grade B · Very Good', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                      const Text('87%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Authentic vintage wear with preserved graphics, minor natural wash fading, zero structural holes or seam tears.',
                    style: TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),

                  // Detail Metrik Persentase
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.indigo[50]?.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetric('Fabric integrity', '92%'),
                        _buildMetric('Seam tension', '95%'),
                        _buildMetric('Color retention', '84%'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card Breakdown Model Confidence
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('MODEL CONFIDENCE BY GRADE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Text('Multi-layer CNN v4.2', style: TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildGradeBar('Grade A', 'Pristine / Like New', 0.08, '8%', false),
                  const SizedBox(height: 8),
                  _buildGradeBar(
                    'Grade B', 
                    'Very Good / Authentic Vintage', 
                    0.87, 
                    '87%', 
                    true, 
                    subtitle: 'Matched authentic aged cotton patina criteria without fabric deterioration.'
                  ),
                  const SizedBox(height: 8),
                  _buildGradeBar('Grade C', 'Fair / Distressed', 0.04, '4%', false),
                  const SizedBox(height: 8),
                  _buildGradeBar('Grade D', 'Upcycle / Reconstruction', 0.01, '1%', false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Aksi Bawah (Retake & Accept)
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.refresh, size: 16, color: Colors.black87),
                          SizedBox(width: 4),
                          Text('Retake', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006828),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Accept & continue', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(radius: 3, backgroundColor: Colors.green),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal)),
      ],
    );
  }

  Widget _buildGradeBar(String grade, String label, double value, String percentage, bool isSelected, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (isSelected) const Icon(Icons.check_circle, size: 14, color: Colors.green),
                if (isSelected) const SizedBox(width: 4),
                Text(grade, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.green[800] : Colors.black87)),
                Text(' · $label', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            Text(percentage, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.green[800] : Colors.black87)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey[200],
            color: isSelected ? Colors.green : Colors.grey[400],
            minHeight: 6,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ],
    );
  }
}