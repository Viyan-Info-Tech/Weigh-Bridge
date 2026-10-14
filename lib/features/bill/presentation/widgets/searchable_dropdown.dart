import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A keyboard-first searchable dropdown component for desktop weighbridge workflow.
///
/// Supports:
/// - Direct keyboard typing to filter options
/// - Arrow Up / Arrow Down keyboard navigation
/// - Enter to select and advance to [nextFocusNode]
/// - Clear visual focus indicator
/// - Dropdown menu with mouse click fallback
/// - Optional "+ Add New" footer button
class SearchableDropdown<T extends Object> extends StatefulWidget {
  final String label;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) itemLabel;
  final ValueChanged<T> onChanged;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final String hintText;
  final String? addNewLabel;
  final VoidCallback? onAddNew;
  final bool enabled;
  final bool isRequired;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.items,
    this.selectedItem,
    required this.itemLabel,
    required this.onChanged,
    this.focusNode,
    this.nextFocusNode,
    required this.hintText,
    this.addNewLabel,
    this.onAddNew,
    this.enabled = true,
    this.isRequired = false,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T extends Object>
    extends State<SearchableDropdown<T>> {
  late final TextEditingController _textController;
  final GlobalKey _fieldKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  OverlayEntry? _overlayEntry;
  int _highlightedIndex = -1;
  List<T> _currentOptions = [];
  final ScrollController _scrollController = ScrollController();
  bool _overlayUpdateScheduled = false;
  bool _shouldShowOverlay = false;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.selectedItem != null
          ? widget.itemLabel(widget.selectedItem!)
          : '',
    );
    _effectiveFocusNode.addListener(_handleFocusChange);
    _textController.addListener(_handleTextChange);
    _effectiveFocusNode.onKeyEvent = _handleKeyEvent;
  }

  @override
  void didUpdateWidget(covariant SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItem != oldWidget.selectedItem) {
      final newText = widget.selectedItem != null
          ? widget.itemLabel(widget.selectedItem!)
          : '';
      _textController.text = newText;
    }
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      _effectiveFocusNode.addListener(_handleFocusChange);
      _effectiveFocusNode.onKeyEvent = _handleKeyEvent;
    }
    if (widget.items != oldWidget.items && _effectiveFocusNode.hasFocus) {
      _rebuildOptions();
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChange);
    _textController.removeListener(_handleTextChange);
    _internalFocusNode?.dispose();
    _textController.dispose();
    _overlayEntry?.remove();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Focus & text change handling
  // ---------------------------------------------------------------------------

  void _handleFocusChange() {
    if (_effectiveFocusNode.hasFocus) {
      _isDismissed = false;

      // Select all text when the field receives focus.
      _textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _textController.text.length,
      );

      _rebuildOptions();
      return;
    }

    // IMPORTANT:
    // Do not dismiss the overlay synchronously here.
    //
    // On Windows desktop, clicking an item inside the OverlayEntry can
    // cause the TextFormField to lose focus before the mouse tap reaches
    // the InkWell. Removing the overlay here prevents the mouse click
    // from being delivered.
    //
    // Let the pointer event finish first.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_effectiveFocusNode.hasFocus) return;

      if (widget.selectedItem != null) {
        final currentText = _textController.text.trim().toLowerCase();
        final selectedText = widget
            .itemLabel(widget.selectedItem!)
            .toLowerCase();

        if (currentText != selectedText) {
          _textController.text = widget.itemLabel(widget.selectedItem!);
        }
      } else if (_textController.text.isNotEmpty) {
        _textController.clear();
      }
    });
  }

  void _handleTextChange() {
    if (_effectiveFocusNode.hasFocus) {
      _isDismissed = false;
      _rebuildOptions();
    }
  }

  // ---------------------------------------------------------------------------
  // Keyboard handling
  // ---------------------------------------------------------------------------

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (_overlayEntry == null) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _rebuildOptions(forceShow: true);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    if (_currentOptions.isEmpty) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _dismissOverlay();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      final nextIndex = (_highlightedIndex + 1).clamp(
        0,
        _currentOptions.length - 1,
      );
      setState(() {
        _highlightedIndex = nextIndex;
      });
      _overlayEntry?.markNeedsBuild();
      _scrollToHighlighted();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      final prevIndex = (_highlightedIndex - 1).clamp(
        0,
        _currentOptions.length - 1,
      );
      setState(() {
        _highlightedIndex = prevIndex;
      });
      _overlayEntry?.markNeedsBuild();
      _scrollToHighlighted();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_highlightedIndex >= 0 &&
          _highlightedIndex < _currentOptions.length) {
        _selectOption(_currentOptions[_highlightedIndex]);
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      _dismissOverlay();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _scrollToHighlighted() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _highlightedIndex >= 0) {
        _scrollController.animateTo(
          _highlightedIndex * 36.0, // approximate item height
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Options computation
  // ---------------------------------------------------------------------------

  List<T> _computeOptions() {
    final query = _textController.text.trim().toLowerCase();
    final selectedLabel = widget.selectedItem != null
        ? widget.itemLabel(widget.selectedItem!).toLowerCase()
        : '';

    // If empty or query equals current selected item label, show all items
    if (query.isEmpty || query == selectedLabel) {
      return widget.items;
    }

    return widget.items.where((item) {
      return widget.itemLabel(item).toLowerCase().contains(query);
    }).toList();
  }

  void _rebuildOptions({bool forceShow = false}) {
    final newOptions = _computeOptions();
    if (forceShow) {
      _isDismissed = false;
    }
    final shouldShow = !_isDismissed && _effectiveFocusNode.hasFocus;

    setState(() {
      _currentOptions = newOptions;
      _highlightedIndex = -1;
    });

    _scheduleOverlayUpdate(shouldShow: shouldShow);
  }

  // ---------------------------------------------------------------------------
  // Overlay management
  // ---------------------------------------------------------------------------

  void _scheduleOverlayUpdate({required bool shouldShow}) {
    _shouldShowOverlay = shouldShow;
    if (_overlayUpdateScheduled) return;
    _overlayUpdateScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlayUpdateScheduled = false;
      if (!mounted || !_effectiveFocusNode.hasFocus) return;

      final showOverlay = _shouldShowOverlay;
      if (showOverlay && _overlayEntry == null) {
        _showOverlay();
      } else if (!showOverlay && _overlayEntry != null) {
        _dismissOverlay();
      } else if (_overlayEntry != null) {
        _overlayEntry!.markNeedsBuild();
      }
    });
  }

  void _toggleOverlay() {
    if (!widget.enabled) return;
    if (_overlayEntry != null) {
      _dismissOverlay();
    } else {
      _isDismissed = false;
      if (!_effectiveFocusNode.hasFocus) {
        _effectiveFocusNode.requestFocus();
      } else {
        _rebuildOptions(forceShow: true);
      }
    }
  }

  void _showOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    if (mounted) setState(() {});
  }

  void _dismissOverlay() {
    _isDismissed = true;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _highlightedIndex = -1;
    if (mounted) setState(() {});
  }

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (context) {
        final renderBox =
            _fieldKey.currentContext?.findRenderObject() as RenderBox?;
        final fieldSize = renderBox?.size ?? const Size(320, 40);

        return Positioned(
          width: fieldSize.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, fieldSize.height + 4),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              shadowColor: Colors.black.withValues(alpha: 0.15),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 280),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: _buildOptionsList(),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getEmptyMessage() {
    final query = _textController.text.trim();
    if (widget.items.isEmpty) {
      return 'No items found';
    }
    if (query.isNotEmpty) {
      return 'No matches found for "$query"';
    }
    return 'No matches found';
  }

  Widget _buildOptionsList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_currentOptions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getEmptyMessage(),
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Flexible(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 4),
              shrinkWrap: true,
              itemCount: _currentOptions.length,
              itemBuilder: (BuildContext context, int index) {
                final option = _currentOptions[index];
                final isSelected = widget.selectedItem == option;
                final isHighlighted = _highlightedIndex == index;

                return InkWell(
                  onTap: () {
                    _selectOption(option);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: isHighlighted
                        ? const Color(0xFFEFF6FF)
                        : (isSelected
                              ? const Color(0xFFF1F5F9)
                              : Colors.transparent),
                    child: Row(
                      children: [
                        if (isSelected)
                          const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Color(0xFF0D3B82),
                          )
                        else
                          const SizedBox(width: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.itemLabel(option),
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF0D3B82)
                                  : const Color(0xFF1E293B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        if (widget.onAddNew != null && widget.addNewLabel != null) ...[
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          InkWell(
            onTap: () {
              _dismissOverlay();
              widget.onAddNew!();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: const Color(0xFFF8FAFC),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    size: 16,
                    color: Color(0xFF0D3B82),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.addNewLabel!,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D3B82),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Selection
  // ---------------------------------------------------------------------------

  void _selectOption(T option) {
    widget.onChanged(option);
    _textController.text = widget.itemLabel(option);
    _dismissOverlay();
    widget.nextFocusNode?.requestFocus();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isRequired ? '${widget.label} *' : widget.label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        CompositedTransformTarget(
          link: _layerLink,
          child: TextFormField(
            key: _fieldKey,
            controller: _textController,
            focusNode: _effectiveFocusNode,
            enabled: widget.enabled,
            textInputAction: TextInputAction.next,
            onTap: () {
              if (_overlayEntry == null) {
                _rebuildOptions(forceShow: true);
              }
            },
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Colors.grey.shade500,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: widget.enabled
                  ? Colors.white
                  : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF0D3B82),
                  width: 2.0,
                ),
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_textController.text.isNotEmpty && widget.enabled)
                    Tooltip(
                      message: 'Clear',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          _textController.clear();
                          _effectiveFocusNode.requestFocus();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.clear_rounded,
                            size: 16,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  Tooltip(
                    message: _overlayEntry != null ? 'Close' : 'Open',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: widget.enabled ? _toggleOverlay : null,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          _overlayEntry != null
                              ? Icons.arrow_drop_up_rounded
                              : Icons.arrow_drop_down_rounded,
                          color: widget.enabled
                              ? const Color(0xFF64748B)
                              : Colors.grey.shade300,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
            onFieldSubmitted: (value) {
              // Check if user pressed enter directly on an exact match or unique option
              final query = value.trim().toLowerCase();
              final matching = widget.items.where(
                (item) => widget.itemLabel(item).toLowerCase() == query,
              );
              if (matching.isNotEmpty) {
                _selectOption(matching.first);
              } else {
                final partial = widget.items.where(
                  (item) =>
                      widget.itemLabel(item).toLowerCase().contains(query),
                );
                if (partial.length == 1) {
                  _selectOption(partial.first);
                } else if (widget.selectedItem != null) {
                  _textController.text = widget.itemLabel(widget.selectedItem!);
                  widget.nextFocusNode?.requestFocus();
                } else {
                  widget.nextFocusNode?.requestFocus();
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
