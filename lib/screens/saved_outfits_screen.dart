import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/outfit.dart';
import '../services/data_service.dart';
import '../widgets/outfit_card.dart';
import '../widgets/outfit_detail_drawer.dart';
import '../widgets/empty_state_widget.dart'; // Ensure imported
import 'delete_outfits_screen.dart';
import '../widgets/glass_container.dart';
import '../theme/app_design.dart';
import '../services/navigation_service.dart';

/// Screen for displaying saved outfits
class SavedOutfitsScreen extends StatefulWidget {
  const SavedOutfitsScreen({super.key});

  @override
  State<SavedOutfitsScreen> createState() => _SavedOutfitsScreenState();
}

class _SavedOutfitsScreenState extends State<SavedOutfitsScreen> {
  static const double _gridPadding = 16.0;
  static const double _gridSpacing = 16.0;
  static const double _gridAspectRatio = 1.2;

  void _updateOutfit(Outfit updatedOutfit) {
    context.read<DataService>().updateOutfit(updatedOutfit);
  }

  void _showOutfitDetails(Outfit outfit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return OutfitDetailDrawer(
          outfit: outfit,
          onOutfitUpdated: _updateOutfit,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Inherit background from parent
      body: Consumer<DataService>(
        builder: (context, dataService, child) {
          final outfits = dataService.outfits;

          if (outfits.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 125.0), // Match closet screen padding
              child: EmptyStateWidget(
                icon: Icons.checkroom_outlined,
                message: '', 
                buttonText: 'Save Your First Outfit!',
                onPressed: () {
                  context.read<NavigationService>().setIndex(0); // Switch to Chat tab (index 0)
                },
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(_gridPadding),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                crossAxisSpacing: _gridSpacing,
                mainAxisSpacing: _gridSpacing,
                childAspectRatio: _gridAspectRatio,
              ),
              itemCount: outfits.length,
              cacheExtent: 1000, 
              itemBuilder: (context, index) {
                return OutfitCard(
                  key: ValueKey(outfits[index].id), 
                  outfit: outfits[index],
                  onTap: () => _showOutfitDetails(outfits[index]),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0), // Lift above custom nav bar
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const DeleteOutfitsScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(position: animation.drive(tween), child: FadeTransition(opacity: animation, child: child));
                },
              ),
            );
          },
          child: GlassContainer(
            width: 56,
            height: 56,
            borderRadius: BorderRadius.circular(28),
            blur: 20,
            color: AppColors.glassFill.withValues(alpha: 0.2),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

  