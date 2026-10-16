import 'dart:typed_data';

import 'package:flutter/material.dart';

class AiGradingResultScreen extends StatefulWidget {
  const AiGradingResultScreen({
    super.key,
    required this.imageBytes,
    required this.category,
  });

  final List<Uint8List> imageBytes;
  final String category;

  @override
  State<AiGradingResultScreen> createState() => _AiGradingResultScreenState();
}

class _AiGradingResultScreenState extends State<AiGradingResultScreen> {
  String? _condition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Condition review',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        child: Text('2', style: TextStyle(fontSize: 12)),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Step 2 of 3: Condition review',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
                    child: PageView.builder(
                      itemCount: widget.imageBytes.length,
                      itemBuilder: (context, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          widget.imageBytes[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.imageBytes.length} photo${widget.imageBytes.length == 1 ? '' : 's'} · ${widget.category}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.brown),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Demo preview only',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This app build has no AI grading service connected. No condition was inferred from your photos. Check the item yourself and choose an honest condition before publishing.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose a condition',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _ConditionOption(
                    title: 'Grade A · Like new',
                    detail:
                        'Excellent condition with little to no visible wear.',
                    selected: _condition == 'Grade A · Like new',
                    onTap: () =>
                        setState(() => _condition = 'Grade A · Like new'),
                  ),
                  _ConditionOption(
                    title: 'Grade B · Good',
                    detail: 'Light signs of wear with no major flaws.',
                    selected: _condition == 'Grade B · Good',
                    onTap: () => setState(() => _condition = 'Grade B · Good'),
                  ),
                  _ConditionOption(
                    title: 'Grade C · Fair',
                    detail: 'Noticeable wear; describe visible flaws clearly.',
                    selected: _condition == 'Grade C · Fair',
                    onTap: () => setState(() => _condition = 'Grade C · Fair'),
                  ),
                  _ConditionOption(
                    title: 'Grade D · Well worn',
                    detail: 'Heavy wear or repairs; show all flaws in photos.',
                    selected: _condition == 'Grade D · Well worn',
                    onTap: () =>
                        setState(() => _condition = 'Grade D · Well worn'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Edit photos'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _condition == null
                          ? null
                          : () => Navigator.pop(context, _condition),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006828),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save condition'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConditionOption extends StatelessWidget {
  const _ConditionOption({
    required this.title,
    required this.detail,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String detail;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? Colors.green : Colors.grey,
      ),
      title: Text(title),
      subtitle: Text(detail),
      dense: true,
    );
  }
}
