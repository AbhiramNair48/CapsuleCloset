import 'package:flutter/material.dart';
import '../models/outfit.dart';
import '../data/mock_outfit_data.dart';
import '../widgets/outfit_card.dart';
import '../widgets/outfit_detail_drawer.dart';

/// Screen for displaying saved outfits
class SavedOutfitsScreen extends StatefulWidget {
  const SavedOutfitsScreen({super.key});

  @override
  _SavedOutfitsScreenState createState() => _SavedOutfitsScreenState();
}

class _SavedOutfitsScreenState extends State<SavedOutfitsScreen> {
  static const double _gridPadding = 16.0;
  static const int _gridCrossAxisCount = 2;
  static const double _gridSpacing = 16.0;
  static const double _gridAspectRatio = 1.2;

  late List<Outfit> _outfits;

  @override
  void initState() {
    super.initState();
    _outfits = MockOutfitData.getOutfits();
  }

  void _updateOutfit(Outfit updatedOutfit) {
    setState(() {
      final index = _outfits.indexWhere((outfit) => outfit.id == updatedOutfit.id);
      if (index != -1) {
        _outfits[index] = updatedOutfit;
      }
    });
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
    if (_outfits.isEmpty) {
      return const Center(
        child: Text(
          'No saved outfits yet',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(_gridPadding),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridCrossAxisCount,
          crossAxisSpacing: _gridSpacing,
          mainAxisSpacing: _gridSpacing,
          childAspectRatio: _gridAspectRatio,
        ),
        itemCount: _outfits.length,
        itemBuilder: (context, index) {
          return OutfitCard(
            outfit: _outfits[index],
            onTap: () => _showOutfitDetails(_outfits[index]),
          );
        },
      ),
    );
  }
}

