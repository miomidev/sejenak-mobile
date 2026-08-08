import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:selena/root/sejenak_color.dart';

class SejenakNavbar extends StatelessWidget {
  final int index;
  const SejenakNavbar({super.key, this.index = 0});
  
  void _onItemTapped(BuildContext context, int selectedIndex) {
    String route = '/';

    if (selectedIndex == 0) {
      route = '/dashboard';
    } else if (selectedIndex == 1) {
      route = '/comunity';
    } else if (selectedIndex == 2) {
      route = '/meditation';
    } else if (selectedIndex == 3) {
      route = '/journal';
    } else if (selectedIndex == 4) {
      route = '/chat';
    }

    if (ModalRoute.of(context)!.settings.name != route) {
      Navigator.pushReplacementNamed(
        context, 
        route,
        // Tambahkan animasi transisi
        result: (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SejenakColor.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: SejenakColor.stroke.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (selectedIndex) => _onItemTapped(context, selectedIndex),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: SejenakColor.primary,
          selectedItemColor: SejenakColor.secondary,
          unselectedItemColor: SejenakColor.stroke,
          selectedLabelStyle: TextStyle(
            fontFamily: "Exo2",
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: "Exo2",
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          items: [
            // Dashboard
            BottomNavigationBarItem(
              icon: _AnimatedNavIcon(
                iconPath: "assets/svg/dashboard.svg",
                isSelected: index == 0,
              ),
              activeIcon: _AnimatedNavIcon(
                iconPath: "assets/svg/dashboard.svg",
                isSelected: true,
              ),
              label: 'Dashboard',
            ),
            // Community/Post
            BottomNavigationBarItem(
              icon: _AnimatedNavIcon(
                iconPath: "assets/svg/post_icon.svg",
                isSelected: index == 1,
              ),
              activeIcon: _AnimatedNavIcon(
                iconPath: "assets/svg/post_icon.svg",
                isSelected: true,
              ),
              label: 'Komunitas',
            ),
            // Meditasi
            BottomNavigationBarItem(
              icon: _AnimatedNavIcon(
                iconPath: "assets/svg/meditation_icon.svg",
                isSelected: index == 2,
              ),
              activeIcon: _AnimatedNavIcon(
                iconPath: "assets/svg/meditation_icon.svg",
                isSelected: true,
              ),
              label: 'Meditasi',
            ),
            // Journal
            BottomNavigationBarItem(
              icon: _AnimatedNavIcon(
                iconPath: "assets/svg/journal_icon.svg",
                isSelected: index == 3,
              ),
              activeIcon: _AnimatedNavIcon(
                iconPath: "assets/svg/journal_icon.svg",
                isSelected: true,
              ),
              label: 'Journal',
            ),
            // Chat
            BottomNavigationBarItem(
              icon: _AnimatedNavIcon(
                iconPath: "assets/svg/chat_icon.svg",
                isSelected: index == 4,
              ),
              activeIcon: _AnimatedNavIcon(
                iconPath: "assets/svg/chat_icon.svg",
                isSelected: true,
              ),
              label: 'Chat',
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedNavIcon extends StatefulWidget {
  final String iconPath;
  final bool isSelected;

  const _AnimatedNavIcon({
    required this.iconPath,
    required this.isSelected,
  });

  @override
  __AnimatedNavIconState createState() => __AnimatedNavIconState();
}

class __AnimatedNavIconState extends State<_AnimatedNavIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedNavIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _animationController.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: widget.isSelected
                  ? BoxDecoration(
                      color: SejenakColor.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: SejenakColor.secondary.withOpacity(0.3),
                        width: 1,
                      ),
                    )
                  : null,
              child: SvgPicture.asset(
                widget.iconPath,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  widget.isSelected ? SejenakColor.secondary : SejenakColor.stroke,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom Page Route untuk animasi transisi
class SlidePageRoute extends PageRouteBuilder {
  final Widget page;

  SlidePageRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 300),
        );
}

// Alternatif: Fade transition
class FadePageRoute extends PageRouteBuilder {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 250),
        );
}