import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:capsule_closet_app/widgets/generic_delete_screen.dart';

class TestItem {
  final String id;
  final String name;

  TestItem(this.id, this.name);
}

void main() {
  group('GenericDeleteScreen Tests', () {
    final testItems = [
      TestItem('1', 'Item 1'),
      TestItem('2', 'Item 2'),
    ];

    testWidgets('Renders empty message when no items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GenericDeleteScreen<TestItem>(
            title: 'Test Delete',
            items: const [],
            getId: (item) => item.id,
            itemBuilder: (context, item, isSelected, onTap) => Text(item.name),
            onDelete: (_) {},
            emptyMessage: 'Nothing here',
            snackBarMessage: 'Deleted',
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          ),
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Test Delete'), findsOneWidget);
    });

    testWidgets('Renders items and handles selection', (WidgetTester tester) async {
      // Set a fixed screen size
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      Set<String>? deletedIds;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GenericDeleteScreen<TestItem>(
                        title: 'Test Delete',
                        items: testItems,
                        getId: (item) => item.id,
                        itemBuilder: (context, item, isSelected, onTap) {
                          return GestureDetector(
                            onTap: onTap,
                            child: Container(
                              height: 100, 
                              width: 100,
                              color: isSelected ? Colors.blue : Colors.grey,
                              child: Text(item.name),
                            ),
                          );
                        },
                        onDelete: (ids) {
                          deletedIds = ids;
                        },
                        emptyMessage: 'Nothing here',
                        snackBarMessage: 'Deleted',
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                      ),
                    ),
                  );
                },
                child: const Text('Go to Delete'),
              ),
            ),
          ),
        ),
      );

      // Navigate to screen
      await tester.tap(find.text('Go to Delete'));
      await tester.pumpAndSettle();

      // Verify items are present
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);

      // Select Item 1
      await tester.tap(find.text('Item 1'));
      await tester.pumpAndSettle(); 

      // Verify selection visual
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Verify FAB appears
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);
      expect(find.text('Delete (1)'), findsOneWidget);

      // Tap FAB
      await tester.tap(fabFinder);
      await tester.pumpAndSettle(); 

      // Verify Dialog
      expect(find.text('Are you sure you want to delete 1 item(s)?'), findsOneWidget);

      // Tap Delete in Dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle(); 

      // Verify callback
      expect(deletedIds, contains('1'));
      expect(deletedIds!.length, 1);
      
      // Verify SnackBar
      expect(find.text('Deleted'), findsOneWidget);
      
      // Verify we are back
      expect(find.text('Go to Delete'), findsOneWidget);
    });
  });
}
