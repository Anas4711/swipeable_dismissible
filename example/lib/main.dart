import 'package:flutter/material.dart';
import 'package:swipeable_dismissible/swipeable_dismissible.dart';

/// The entry point of the example application demonstrating [SwipeDismissible].
void main() {
  runApp(const MyApp());
}

/// Root widget of the example application.
class MyApp extends StatelessWidget {
  /// Creates the root [MyApp] widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swipeable Dismissible Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const HistoryPage(),
    );
  }
}

/// A sample history list page showcasing custom swipe-to-dismiss functionality.
class HistoryPage extends StatefulWidget {
  /// Creates the [HistoryPage] widget.
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  /// The mock list of history items displayed in the list view.
  final List<String> _items = List.generate(10, (i) => 'History Item ${i + 1}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History Example'), centerTitle: true),
      body: ListView.builder(
        itemCount: _items.length,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemBuilder: (context, index) {
          final item = _items[index];

          return SwipeDismissible(
            key: ValueKey(item),
            borderRadius: BorderRadius.circular(50.0), // حواف دائرية للأزرار
            spacing: 8.0, // مسافة بين الأزرار
            actionGap: 12.0,
            actions: [
              /// Archive action button
              SwipeDismissableAction(
                icon: const Icon(Icons.archive),
                backgroundColor: Colors.blue,
                width: 50.0,
                height: 50.0,
                borderRadius: BorderRadius.circular(25.0),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$item archived'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),

              /// Favorite action button
              SwipeDismissableAction(
                icon: const Icon(Icons.star),
                backgroundColor: Colors.amber,
                width: 50.0,
                height: 50.0,
                borderRadius: BorderRadius.circular(25.0),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$item starred'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),

              /// Primary dismiss action button
              SwipeDismissableAction(
                icon: const Icon(Icons.delete),
                label: 'Delete',
                backgroundColor: Colors.red,
                width: 70.0,
                height: 50.0,
                borderRadius: BorderRadius.circular(50.0),
                isDismissAction: true,
                onPressed: () {
                  setState(() {
                    _items.removeAt(index);
                  });
                },
              ),
            ],
            // العنصر الرئيسي بدون زوايا وبدون حواف ومتصل مباشرة
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(item),
                subtitle: const Text('Swipe left to reveal actions'),
              ),
            ),
          );
        },
      ),
    );
  }
}
