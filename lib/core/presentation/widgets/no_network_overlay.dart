import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoNetworkOverlay extends StatelessWidget {
  const NoNetworkOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120.r,
                height: 120.r,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: 64.sp,
                    color: Colors.red,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'Whoops!',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Please check your network settings and try again. We will automatically reconnect you once you\'re back online.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 48.h),
              _PulsingIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingIndicator extends StatefulWidget {
  @override
  State<_PulsingIndicator> createState() => _PulsingIndicatorState();
}

class _PulsingIndicatorState extends State<_PulsingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Column(
        children: [
          SizedBox(
            width: 24.r,
            height: 24.r,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFFE85B17),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Waiting for connection...',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE85B17),
            ),
          ),
        ],
      ),
    );
  }
}
