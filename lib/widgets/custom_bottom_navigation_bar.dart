import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BottomAppBar(
      color: colorScheme.surface, // Light beige background
      elevation: 1,
      shadowColor: CupertinoColors.inactiveGray,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavItem(
            icon: Icons.all_inbox, // Closest icon for wardrobe
            index: 0,
            colorScheme: colorScheme,
          ),
           _buildNavItem(
            icon: Icons.auto_awesome, // Sparkle icon
            index: 1,
            colorScheme: colorScheme,
          ),
          //  _buildNavItem(
          //   icon: Icons.list_alt, // Closest icon for list
          //   index: 2,
          //   colorScheme: colorSchmee,
          // ),
           _buildNavItem(
            icon: Icons.person_outline, // Closest icon for person
            index: 2,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required ColorScheme colorScheme,
  }) {
    final isSelected = index == selectedIndex;
    final iconColor = isSelected ? colorScheme.background : colorScheme.primary;
    final backgroundColor = isSelected ? colorScheme.primary : Colors.transparent;

    return Expanded(
      child: InkWell(
        onTap: () => onItemTapped(index),
        child: Column(
           mainAxisSize: MainAxisSize.min,
           mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0), // Padding around the icon
               decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20.0), // Rounded background
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24.0,
              ),
            ),
           // Add Text label if needed, not visible in image though
          ],
        ),
      ),
    );
  }
} 