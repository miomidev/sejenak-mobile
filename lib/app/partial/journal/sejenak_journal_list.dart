import 'package:flutter/material.dart';
import 'package:selena/app/components/sejenak_text.dart';
import 'package:selena/root/sejenak_color.dart';

class SejenakJournalList extends StatefulWidget {
  final String title;
  final String text;
  final String fontStyle;
  final Color color;
  final double fontSize;
  final Future<void> Function() action;
  final Future<void> Function()? onEdit;
  final Future<void> Function()? onDelete;

  const SejenakJournalList({
    super.key,
    required this.title,
    required this.text,
    required this.action,
    this.onEdit,
    this.onDelete,
    this.color = SejenakColor.primary,
    this.fontStyle = 'Lexend',
    this.fontSize = 14.24,
  });

  @override
  _SejenakJournalListState createState() => _SejenakJournalListState();
}

class _SejenakJournalListState extends State<SejenakJournalList> {
  bool _isPressed = false;

  Future<void> _onClick() async {
    setState(() {
      _isPressed = true;
    });

    await Future.delayed(const Duration(milliseconds: 150));
    
    await widget.action();
    
    // Reset state setelah action selesai
    if (mounted) {
      setState(() {
        _isPressed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onClick,
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.0,
            color: Colors.grey[900]!,
          ),
          color: widget.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isPressed 
              ? [] // Hilangkan shadow saat ditekan
              : [
                  BoxShadow(
                    color: SejenakColor.black,
                    spreadRadius: 0.4,
                    blurRadius: 0,
                    offset: const Offset(0.3, 4),
                  ),
                ],
        ),
        transform: Matrix4.translationValues(
          0, 
          _isPressed ? 2.0 : 0.0, // Translasi lebih kecil
          0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SejenakText(
                    text: widget.title,
                    type: SejenakTextType.h5,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  SejenakText(
                    text: widget.text,
                    type: SejenakTextType.regular,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Three-dot dropdown menu (simpler version)
            if (widget.onEdit != null || widget.onDelete != null)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: Colors.grey[700],
                ),
                onSelected: (value) async {
                  if (value == 'edit' && widget.onEdit != null) {
                    await widget.onEdit!();
                  } else if (value == 'delete' && widget.onDelete != null) {
                    await widget.onDelete!();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  if (widget.onEdit != null)
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 18,
                            color: SejenakColor.secondary,
                          ),
                          const SizedBox(width: 8),
                          const Text('Edit'),
                        ],
                      ),
                    ),
                  if (widget.onDelete != null)
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            size: 18,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}