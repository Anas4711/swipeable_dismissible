import 'package:flutter/material.dart';

/// Represents an individual swipe action button displayed behind the dismissible child widget.
class SwipeDismissableAction {
  /// Optional custom icon widget.
  final Widget? icon;

  /// Optional label text.
  final String? label;

  /// TextStyle for the [label].
  final TextStyle? labelStyle;

  /// Background color of the action button. Defaults to [Colors.red].
  final Color backgroundColor;

  /// Color for icons and default text. Defaults to [Colors.white].
  final Color foregroundColor;

  /// Fixed width of the action button. Defaults to 60.0.
  final double? width;

  /// Fixed height of the action button. Defaults to 50.0.
  final double? height;

  /// Elevation/shadow height of the action button. Defaults to 0.0.
  final double elevation;

  /// Shadow color when [elevation] is greater than 0.
  final Color? shadowColor;

  /// Custom border radius for the action button.
  final BorderRadiusGeometry? borderRadius;

  /// Custom padding for the action button interior.
  final EdgeInsetsGeometry? padding;

  /// Callback fired when the action button is clicked.
  final VoidCallback onPressed;

  /// Indicates if this action acts as the primary dismiss/delete action that triggers layout expansion.
  final bool isDismissAction;

  /// Gives complete freedom to render any custom Widget inside the action button,
  /// bypassing the default icon/label Column structure completely.
  final Widget? customContent;

  const SwipeDismissableAction({
    required this.onPressed,
    this.icon,
    this.label,
    this.labelStyle,
    this.backgroundColor = Colors.red,
    this.foregroundColor = Colors.white,
    this.width,
    this.height,
    this.elevation = 0.0,
    this.shadowColor,
    this.borderRadius,
    this.padding,
    this.isDismissAction = false,
    this.customContent,
  }) : assert(
         icon != null || label != null || customContent != null,
         'Provide at least an icon, a label, or customContent for SwipeDismissableAction.',
       );
}

/// Defines the layout arrangement of swipe action buttons.
enum SwipeActionLayout { row, grid }

/// Specifies allowable drag directions.
enum SwipeDirection { endToStart, startToEnd, both }

/// A highly fluid, 1:1 touch-responsive, fully customizable swipe-to-dismiss widget.
class SwipeDismissible extends StatefulWidget {
  /// Main child widget (e.g. Card, ListTile).
  final Widget child;

  /// List of swipe action buttons.
  final List<SwipeDismissableAction> actions;

  /// Action layout structure (Row or Grid). Defaults to [SwipeActionLayout.row].
  final SwipeActionLayout layout;

  /// Drag direction allowed. If left null, it automatically adapts to RTL / LTR layout.
  final SwipeDirection? direction;

  /// Spacing between action buttons. Defaults to 8.0.
  final double spacing;

  /// Safety gap between slided child and action container. Defaults to 12.0.
  final double actionGap;

  /// Outer border radius for action buttons fallback.
  final BorderRadiusGeometry? borderRadius;

  /// Duration of animations. Defaults to 200ms.
  final Duration animationDuration;

  /// Animation curve. Defaults to [Curves.easeOutCubic].
  final Curve animationCurve;

  /// Cross axis count for Grid layout. Defaults to 2.
  final int gridCrossAxisCount;

  /// Child aspect ratio for Grid layout. Defaults to 1.0.
  final double gridChildAspectRatio;

  /// Ratio threshold to trigger auto-dismiss action (0.0 to 1.0). Defaults to 0.65.
  final double dismissThresholdRatio;

  /// Callback when drag starts.
  final VoidCallback? onSwipeStart;

  /// Callback during drag progress with current offset in pixels.
  final ValueChanged<double>? onSwipeUpdate;

  /// Callback when drag ends.
  final VoidCallback? onSwipeEnd;

  const SwipeDismissible({
    super.key,
    required this.child,
    required this.actions,
    this.layout = SwipeActionLayout.row,
    this.direction,
    this.spacing = 8.0,
    this.actionGap = 12.0,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOutCubic,
    this.gridCrossAxisCount = 2,
    this.gridChildAspectRatio = 1.0,
    this.dismissThresholdRatio = 0.65,
    this.onSwipeStart,
    this.onSwipeUpdate,
    this.onSwipeEnd,
  });

  @override
  State<SwipeDismissible> createState() => _SwipeDismissibleState();
}

class _SwipeDismissibleState extends State<SwipeDismissible>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  bool _isDragging = false;
  bool _isDismissing = false;

  late AnimationController _dismissController;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _sizeAnimation = CurvedAnimation(
      parent: _dismissController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _dismissController.dispose();
    super.dispose();
  }

  /// Calculates the effective swipe direction based on developer input or current ambient locale directionality.
  SwipeDirection _getEffectiveDirection(BuildContext context) {
    if (widget.direction != null) return widget.direction!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return isRtl ? SwipeDirection.startToEnd : SwipeDirection.endToStart;
  }

  SwipeDismissableAction get _dismissAction {
    return widget.actions.firstWhere(
      (a) => a.isDismissAction,
      orElse: () => widget.actions.last,
    );
  }

  int get _dismissActionIndex {
    final index = widget.actions.indexWhere((a) => a.isDismissAction);
    return index != -1 ? index : widget.actions.length - 1;
  }

  double get _baseMaxExtent {
    if (widget.actions.isEmpty) return 0.0;

    double total = 0.0;
    if (widget.layout == SwipeActionLayout.row) {
      for (var action in widget.actions) {
        total += (action.width ?? 60.0) + widget.spacing;
      }
    } else {
      final rows = (widget.actions.length / widget.gridCrossAxisCount).ceil();
      final itemHeight = widget.actions.first.height ?? 50.0;
      total = (rows * itemHeight) + ((rows - 1) * widget.spacing);
    }

    return total + widget.actionGap;
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (_isDismissing) return;
    setState(() {
      _isDragging = true;
    });
    widget.onSwipeStart?.call();
  }

  void _onHorizontalDragUpdate(
    DragUpdateDetails details,
    double totalWidth,
    SwipeDirection effectiveDirection,
  ) {
    if (widget.actions.isEmpty || _isDismissing) return;

    final delta = details.primaryDelta ?? 0.0;

    setState(() {
      _dragOffset += delta;

      // Enforce directional drag boundaries
      if (effectiveDirection == SwipeDirection.endToStart) {
        _dragOffset = _dragOffset.clamp(-totalWidth, 0.0);
      } else if (effectiveDirection == SwipeDirection.startToEnd) {
        _dragOffset = _dragOffset.clamp(0.0, totalWidth);
      } else {
        _dragOffset = _dragOffset.clamp(-totalWidth, totalWidth);
      }
    });

    widget.onSwipeUpdate?.call(_dragOffset);
  }

  void _onHorizontalDragEnd(DragEndDetails details, double totalWidth) {
    if (_isDismissing) return;

    setState(() {
      _isDragging = false;
    });

    widget.onSwipeEnd?.call();

    final triggerThreshold = totalWidth * widget.dismissThresholdRatio;
    final normalThreshold = _baseMaxExtent * 0.4;

    if (_dragOffset.abs() >= triggerThreshold) {
      _triggerDismiss(_dismissAction, totalWidth);
    } else if (_dragOffset.abs() >= normalThreshold) {
      setState(() {
        _dragOffset = _dragOffset < 0 ? -_baseMaxExtent : _baseMaxExtent;
      });
    } else {
      _close();
    }
  }

  void _triggerDismiss(SwipeDismissableAction action, double totalWidth) {
    final isSwipingLeft = _dragOffset < 0;
    setState(() {
      _isDismissing = true;
      _isDragging = false;
      _dragOffset = isSwipingLeft ? -totalWidth : totalWidth;
    });

    _dismissController.forward().then((_) {
      action.onPressed();
    });
  }

  void _close() {
    setState(() {
      _dragOffset = 0.0;
    });
  }

  Widget _buildActionButton(
    SwipeDismissableAction action, {
    double extraWidth = 0.0,
    double overrideWidth = -1.0,
  }) {
    final effectiveRadius =
        action.borderRadius ?? widget.borderRadius ?? BorderRadius.circular(12);

    final finalWidth = overrideWidth >= 0
        ? overrideWidth
        : (action.width ?? 60) + extraWidth;

    if (finalWidth <= 0) return const SizedBox.shrink();

    return Container(
      width: finalWidth,
      height: action.height ?? 50,
      padding: action.padding,
      child: Material(
        color: action.backgroundColor,
        elevation: action.elevation,
        shadowColor: action.shadowColor,
        borderRadius: effectiveRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (action.isDismissAction || action == _dismissAction) {
              final double width = context.size?.width ?? 300.0;
              _triggerDismiss(action, width);
            } else {
              _close();
              action.onPressed();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child:
                    action.customContent ??
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (action.icon != null)
                          IconTheme(
                            data: IconThemeData(color: action.foregroundColor),
                            child: action.icon!,
                          ),
                        if (action.icon != null && action.label != null)
                          const SizedBox(height: 2),
                        if (action.label != null)
                          Text(
                            action.label!,
                            style:
                                action.labelStyle ??
                                TextStyle(
                                  color: action.foregroundColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                      ],
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsLayout(double totalWidth) {
    final overScroll = (_dragOffset.abs() - _baseMaxExtent).clamp(
      0.0,
      double.infinity,
    );

    final fadeRange =
        (totalWidth * widget.dismissThresholdRatio) - _baseMaxExtent;
    final progress = fadeRange > 0
        ? (overScroll / fadeRange).clamp(0.0, 1.0)
        : 0.0;
    final otherActionsOpacity = (1.0 - progress).clamp(0.0, 1.0);

    final targetDismissIdx = _dismissActionIndex;

    if (widget.layout == SwipeActionLayout.row) {
      return ClipRect(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.actions.length, (index) {
              final action = widget.actions[index];
              final isTargetDismiss = index == targetDismissIdx;

              if (isTargetDismiss) {
                final double shrinkSpace =
                    (1.0 - otherActionsOpacity) *
                    (widget.actions
                        .where((a) => !a.isDismissAction && a != _dismissAction)
                        .fold(
                          0.0,
                          (sum, a) => sum + (a.width ?? 60.0) + widget.spacing,
                        ));

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                  child: _buildActionButton(
                    action,
                    extraWidth: overScroll + shrinkSpace,
                  ),
                );
              }

              final originalWidth = action.width ?? 60.0;
              final currentWidth = originalWidth * otherActionsOpacity;

              if (currentWidth <= 0.1 || _isDismissing) {
                return const SizedBox.shrink();
              }

              return Opacity(
                opacity: otherActionsOpacity,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: (widget.spacing / 2) * otherActionsOpacity,
                  ),
                  child: _buildActionButton(
                    action,
                    overrideWidth: currentWidth,
                  ),
                ),
              );
            }),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: _baseMaxExtent - widget.actionGap + overScroll,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.gridCrossAxisCount,
            crossAxisSpacing: widget.spacing,
            mainAxisSpacing: widget.spacing,
            childAspectRatio: widget.gridChildAspectRatio,
          ),
          itemCount: widget.actions.length,
          itemBuilder: (context, index) {
            final isTargetDismiss = index == targetDismissIdx;
            final buttonWidget = _buildActionButton(widget.actions[index]);

            if (isTargetDismiss) return buttonWidget;
            if (otherActionsOpacity <= 0.05 || _isDismissing) {
              return const SizedBox.shrink();
            }

            return Opacity(opacity: otherActionsOpacity, child: buttonWidget);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDirection = _getEffectiveDirection(context);

    return SizeTransition(
      sizeFactor: Tween<double>(begin: 1.0, end: 0.0).animate(_sizeAnimation),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final isSwipingLeft = _dragOffset < 0;

          return Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: isSwipingLeft
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: widget.spacing),
                    child: _buildActionsLayout(totalWidth),
                  ),
                ),
              ),
              _isDragging
                  ? Transform.translate(
                      offset: Offset(_dragOffset, 0),
                      child: _buildGestureChild(totalWidth, effectiveDirection),
                    )
                  : AnimatedContainer(
                      duration: _isDismissing
                          ? const Duration(milliseconds: 150)
                          : widget.animationDuration,
                      curve: widget.animationCurve,
                      transform: Matrix4.translationValues(_dragOffset, 0, 0),
                      child: _buildGestureChild(totalWidth, effectiveDirection),
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGestureChild(
    double totalWidth,
    SwipeDirection effectiveDirection,
  ) {
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: (details) =>
          _onHorizontalDragUpdate(details, totalWidth, effectiveDirection),
      onHorizontalDragEnd: (details) =>
          _onHorizontalDragEnd(details, totalWidth),
      behavior: HitTestBehavior.opaque,
      child: widget.child,
    );
  }
}
