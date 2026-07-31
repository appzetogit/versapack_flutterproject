import 'package:flutter/material.dart';

class SlideToAcceptButton extends StatefulWidget {
  final VoidCallback onAccept;
  final bool isLoading;
  final String text;

  const SlideToAcceptButton({
    super.key,
    required this.onAccept,
    this.isLoading = false,
    this.text = 'SLIDE TO ACCEPT',
  });

  @override
  State<SlideToAcceptButton> createState() => _SlideToAcceptButtonState();
}

class _SlideToAcceptButtonState extends State<SlideToAcceptButton> with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  bool _isAccepted = false;
  final GlobalKey _containerKey = GlobalKey();
  
  static const double _thumbSize = 54;
  static const double _padding = 4;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        height: _thumbSize + (_padding * 2),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE85B17),
          borderRadius: BorderRadius.circular((_thumbSize + _padding * 2) / 2),
        ),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Colors.white),
      );
    }

    return Container(
      key: _containerKey,
      height: _thumbSize + (_padding * 2),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE85B17), // Orange
        borderRadius: BorderRadius.circular((_thumbSize + _padding * 2) / 2),
      ),
      child: Stack(
        children: [
          // Centered Text
          Center(
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          // Sliding Thumb
          Positioned(
            left: _padding + _dragPosition,
            top: _padding,
            bottom: _padding,
            child: GestureDetector(
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: AnimatedContainer(
                duration: _dragPosition == 0 ? const Duration(milliseconds: 250) : Duration.zero,
                width: _thumbSize,
                height: _thumbSize,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black87, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAccepted) return;
    
    final RenderBox? renderBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final maxWidth = renderBox.size.width - _thumbSize - (_padding * 2);
    
    setState(() {
      _dragPosition += details.delta.dx;
      _dragPosition = _dragPosition.clamp(0.0, maxWidth);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAccepted) return;
    
    final RenderBox? renderBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final maxWidth = renderBox.size.width - _thumbSize - (_padding * 2);
    
    // If dragged more than 80% across, accept it
    if (_dragPosition > maxWidth * 0.8) {
      setState(() {
        _dragPosition = maxWidth;
        _isAccepted = true;
      });
      widget.onAccept();
    } else {
      // Snap back to start
      setState(() {
        _dragPosition = 0;
      });
    }
  }
}
