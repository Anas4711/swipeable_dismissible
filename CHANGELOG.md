## 1.0.0

* **Feat:** Added dual-side swipe support with `leftActions` and `rightActions`.
* **Feat:** Setting `direction: SwipeDirection.both` now allows revealing different action sets on left vs right swipes.
* **Fix:** Improved `isDismissAction` logic — full swipe auto-dismiss and action expansion now only trigger if an action explicitly sets `isDismissAction: true`.
* **Fix:** Enhanced automatic RTL/LTR direction detection using native system locale and ambient `Directionality`.

## 0.0.4

* **Fix:** Fixed initial gesture response latency by unifying gesture tree state on the first drag.

## 0.0.3

* **Feat:** Added automatic `Directionality` support (RTL / LTR) when `direction` is left `null`.
* **Refactor:** Updated code documentation and example app to support ambient layout direction.

## 0.0.2

* Updated README usage example.

## 0.0.1

* Initial release.
* Added `SwipeDismissible` widget with fluid 1:1 touch response.
* Added support for multiple action layouts (`row` and `grid`).
* Added dynamic over-swipe action expansion and background fading.
* Added custom action widget support via `customContent`.
* Added touch lifecycle callbacks (`onSwipeStart`, `onSwipeUpdate`, `onSwipeEnd`).
