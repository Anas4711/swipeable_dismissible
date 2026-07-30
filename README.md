# Swipeable Dismissible
[![pub package](https://img.shields.io/pub/v/swipeable_dismissible.svg)](https://pub.dev/packages/swipeable_dismissible)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/Anas4711/swipeable_dismissible/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/Anas4711/swipeable_dismissible?style=social)](https://github.com/Anas4711/swipeable_dismissible)


<p align="center">
  <img src="https://raw.githubusercontent.com/Anas4711/swipeable_dismissible/main/media/preview.png" alt="Swipeable Dismissible Banner" width="100%">
</p>


A fluid, highly customizable, and **1:1 touch-responsive** swipe-to-dismiss widget **built purely with native Flutter widgets (zero external dependencies)**. It supports single or dual-side swipe action sets, dynamic over-swipe expansion, smooth fading transitions, ambient Directionality and native system locale (RTL/LTR) support, and fully custom action widgets.

---

## ✨ Features

- ⚡ **1:1 Touch Response** — Instant fluid drag tracking with zero perceived latency.
- ↔️ **Dual-Side Actions** — Define separate actions for left and right swipe gestures (`leftActions` & `rightActions`).
- 🎨 **Fully Customizable Actions** — Customize width, height, colors, border radius, elevation, and shadow colors.
- 🌐 **Automatic RTL / LTR Support** — Intelligently resolves swipe direction from ambient `Directionality` or the native system platform locale.
- 🧩 **Custom Content Support** — Display any widget inside an action using `customContent`.
- 📐 **Multiple Action Layouts** — Arrange actions in either a horizontal row or a grid.
- 🎯 **Opt-in Dismiss Expansion** — Full-swipe dismissal and button expansion only trigger when `isDismissAction: true` is set.
- 🛡️ **Overflow Safe** — Prevents `RenderFlex` overflow during extreme drag gestures.
- 🔔 **Swipe Callbacks** — Listen to gesture lifecycle events with `onSwipeStart`, `onSwipeUpdate`, and `onSwipeEnd`.


---

## 📦 Installation

Add the package to your **pubspec.yaml**:

```yaml
dependencies:
  swipeable_dismissible: ^1.0.0
```

Then run:

```bash
flutter pub get
```

---

## 🚀 Usage

### Dual-Side Swiping (Both Directions)

```dart
import 'package:flutter/material.dart';
import 'package:swipeable_dismissible/swipeable_dismissible.dart';

class DualSideExample extends StatelessWidget {
  const DualSideExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SwipeDismissible(
          key: const ValueKey('item_1'),
          direction: SwipeDirection.both,
          borderRadius: BorderRadius.circular(50),
          spacing: 8,
          actionGap: 12,
          // Actions revealed on swiping Left -> Right
          leftActions: [
            SwipeDismissableAction(
              icon: const Icon(Icons.archive),
              backgroundColor: Colors.blue,
              width: 50,
              height: 50,
              borderRadius: BorderRadius.circular(25),
              onPressed: () {},
            ),
          ],
          // Actions revealed on swiping Right -> Left
          rightActions: [
            SwipeDismissableAction(
              icon: const Icon(Icons.delete),
              label: 'Delete',
              backgroundColor: Colors.red,
              width: 70,
              height: 50,
              borderRadius: BorderRadius.circular(50),
              isDismissAction: true, // Enables auto-dismiss on full swipe
              onPressed: () {},
            ),
          ],
          child: const ListTile(
            title: Text('Swipeable Item'),
            subtitle: Text('Swipe right to archive, left to delete'),
          ),
        ),
      ),
    );
  }
}


```

---

# API Reference

## SwipeDismissible

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `child` | `Widget` | **Required** | Main widget displayed in the foreground (e.g. `ListTile`, `Card`). |
| `actions` | `List<SwipeDismissableAction>?` | `null` | Single action list fallback if `leftActions` / `rightActions` are omitted. |
| `leftActions` | `List<SwipeDismissableAction>?` | `null` | Action buttons revealed when swiping Left-to-Right. |
| `rightActions` | `List<SwipeDismissableAction>?` | `null` | Action buttons revealed when swiping Right-to-Left. |
| `layout` | `SwipeActionLayout` | `SwipeActionLayout.row` | Layout arrangement for actions (`row` or `grid`). |
| `direction` | `SwipeDirection?` | `null` | Allowed swipe direction (`endToStart`, `startToEnd`, `both`). Automatically adapts to ambient `Directionality` or native system locale (RTL/LTR) if left `null`. |
| `spacing` | `double` | `8.0` | Space between action buttons. |
| `actionGap` | `double` | `12.0` | Gap between the child and the action container. |
| `borderRadius` | `BorderRadiusGeometry?` | `null` | Default border radius applied to actions. |
| `animationDuration` | `Duration` | `200ms` | Duration of slide and snap animations. |
| `animationCurve` | `Curve` | `Curves.easeOutCubic` | Animation curve used for transitions. |
| `gridCrossAxisCount` | `int` | `2` | Number of columns when using grid layout. |
| `gridChildAspectRatio` | `double` | `1.0` | Child aspect ratio for grid layout. |
| `dismissThresholdRatio` | `double` | `0.65` | Swipe ratio required to trigger automatic dismissal when an action has `isDismissAction: true`. |
| `onSwipeStart` | `VoidCallback?` | `null` | Called when dragging begins. |
| `onSwipeUpdate` | `ValueChanged<double>?` | `null` | Reports the current drag offset in pixels. |
| `onSwipeEnd` | `VoidCallback?` | `null` | Called when dragging ends. |


---

## SwipeDismissableAction

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `onPressed` | `VoidCallback` | **Required** | Called when the action button is pressed. |
| `icon` | `Widget?` | `null` | Optional icon displayed inside the action button. |
| `label` | `String?` | `null` | Optional text label. |
| `labelStyle` | `TextStyle?` | `null` | Custom text style for the label. |
| `backgroundColor` | `Color` | `Colors.red` | Background color of the action button. |
| `foregroundColor` | `Color` | `Colors.white` | Default color for icons and text. |
| `width` | `double?` | `60.0` | Width of the action button. |
| `height` | `double?` | `50.0` | Height of the action button. |
| `elevation` | `double` | `0.0` | Elevation (shadow depth). |
| `shadowColor` | `Color?` | `null` | Shadow color when elevation is greater than zero. |
| `borderRadius` | `BorderRadiusGeometry?` | `null` | Border radius of the action button. |
| `padding` | `EdgeInsetsGeometry?` | `null` | Internal padding around the action content. |
| `isDismissAction` | `bool` | `false` | Enables full-swipe expansion and auto-dismiss behavior for this action. |
| `customContent` | `Widget?` | `null` | Displays a custom widget instead of the default icon/label layout. |

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](https://github.com/Anas4711/swipeable_dismissible/blob/main/LICENSE) file for details.
