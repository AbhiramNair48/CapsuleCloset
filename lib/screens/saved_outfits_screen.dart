import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/outfit.dart';
import '../services/data_service.dart';
import '../widgets/outfit_card.dart';
import '../widgets/outfit_detail_drawer.dart';

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

      return Consumer<DataService>(

        builder: (context, dataService, child) {

          final outfits = dataService.outfits;

          

          if (outfits.isEmpty) {

            return Center(

              child: Column(

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  Icon(

                    Icons.checkroom_outlined,

                    size: 64,

                    color: Theme.of(context).colorScheme.secondary,

                  ),

                  const SizedBox(height: 16),

                  Text(

                    'No saved outfits yet',

                    style: Theme.of(context).textTheme.titleMedium?.copyWith(

                      color: Theme.of(context).colorScheme.onSurfaceVariant,

                    ),

                  ),

                ],

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

              cacheExtent: 1000, // Increase cache extent to preload more items

              itemBuilder: (context, index) {

                return OutfitCard(

                  key: ValueKey(outfits[index].id), // Add key for better performance

                  outfit: outfits[index],

                  onTap: () => _showOutfitDetails(outfits[index]),

                );

              },

            ),

          );

        },

      );

    }

  }

  