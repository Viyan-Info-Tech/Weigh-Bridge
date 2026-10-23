import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A modern, keyboard-first searchable dropdown component for desktop weighbridge workflow.
///
/// Supports:
/// - Vertically centered, beautifully styled input field with hint & selected state
/// - Direct keyboard typing to filter options (when [enableSearch] is true)
/// - Arrow Up / Arrow Down keyboard navigation with auto-scrolling
/// - Enter to select and advance to [nextFocusNode]
/// - Escape to dismiss the popup
/// - Clean elevated floating popup aligned with the field shell
/// - Visual category icons, selected indicators, and hover effects
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

  /// Whether to render the small caption above the field. Set false when the
  /// dropdown is embedded in a field shell that already labels the row.
  final bool showLabel;

  /// When true the field renders without a filled outline border, so it can
  /// sit flush inside [BillFormFieldShell] like the other form fields.
  final bool borderless;

  /// When false the field becomes selection-only.
  ///
  /// Typing, the text caret and text selection are all disabled, so the only
  /// way to set a value is by choosing one of [items] from the popup.
  final bool enableSearch;

  /// Message shown in the popup when [items] is empty.
  final String? emptyItemsMessage;

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
    this.showLabel = true,
    this.borderless = false,
    this.enableSearch = true,
    this.emptyItemsMessage,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T extends Object>
    extends State<SearchableDropdown<T>> {
  late final TextEditingController _textController;
  final GlobalKey _fieldKey = GlobalKey();
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

      if (widget.enableSearch) {
        _textController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _textController.text.length,
        );
      }

      _rebuildOptions();
      return;
    }

    // Defer dismissal so that mouse clicks inside the overlay on Windows desktop
    // register before the overlay is removed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_effectiveFocusNode.hasFocus) return;

      if (mounted) setState(() {});

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
          _highlightedIndex * 46.0,
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
    if (!widget.enableSearch) {
      return widget.items;
    }

    final query = _textController.text.trim().toLowerCase();
    final selectedLabel = widget.selectedItem != null
        ? widget.itemLabel(widget.selectedItem!).toLowerCase()
        : '';

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

  /// Builds the elevated popup overlay.
  ///
  /// Anchors directly under the field shell and spans its full width so the
  /// dropdown looks unified with the input box.
  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (context) {
        final renderBox =
            _fieldKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox == null) return const SizedBox.shrink();

        // Search for the enclosing field shell to span the full width if embedded.
        RenderBox anchorBox = renderBox;
        RenderObject? parent = renderBox.parent;
        while (parent != null) {
          if (parent is RenderBox &&
              parent.size.height >= 40 &&
              parent.size.width > anchorBox.size.width) {
            anchorBox = parent;
            break;
          }
          parent = parent.parent;
        }

        final fieldSize = anchorBox.size;
        final fieldTopLeft = anchorBox.localToGlobal(Offset.zero);
        final screen = MediaQuery.sizeOf(context);

        const gap = 6.0;
        const screenMargin = 12.0;
        const desiredMaxHeight = 280.0;

        final spaceBelow =
            screen.height -
            (fieldTopLeft.dy + fieldSize.height) -
            gap -
            screenMargin;
        final spaceAbove = fieldTopLeft.dy - gap - screenMargin;

        final openDown = spaceBelow >= 160.0 || spaceBelow >= spaceAbove;
        final available = openDown ? spaceBelow : spaceAbove;
        final maxHeight = available.clamp(120.0, desiredMaxHeight);

        return Positioned(
          left: fieldTopLeft.dx,
          width: fieldSize.width,
          top: openDown ? fieldTopLeft.dy + fieldSize.height + gap : null,
          bottom: openDown ? null : (screen.height - fieldTopLeft.dy + gap),
          child: Material(
            elevation: 0,
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(maxHeight: maxHeight),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A0F172A),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Color(0x0A0F172A),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildOptionsList(),
            ),
          ),
        );
      },
    );
  }

  String _getEmptyMessage() {
    final query = _textController.text.trim();
    if (widget.items.isEmpty) {
      return widget.emptyItemsMessage ?? 'No items found';
    }
    if (query.isNotEmpty && widget.enableSearch) {
      return 'No matches found for "$query"';
    }
    return 'No matches found';
  }

  Widget _buildOptionsList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Elegant header banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            border: Border(
              bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.layers_outlined,
                size: 13,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              const Text(
                'SELECT MATERIAL',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_currentOptions.length}',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        ),

        // List of options or empty state
        if (_currentOptions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 20,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _getEmptyMessage(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )
        else
          Flexible(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 4),
              shrinkWrap: true,
              itemCount: _currentOptions.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 0.6,
                color: Color(0xFFF8FAFC),
                indent: 14,
                endIndent: 14,
              ),
              itemBuilder: (BuildContext context, int index) {
                final option = _currentOptions[index];
                final isSelected = widget.selectedItem == option;
                final isHighlighted = _highlightedIndex == index;
                final label = widget.itemLabel(option);

                final Color rowBg;
                if (isHighlighted) {
                  rowBg = const Color(0xFFF1F5F9);
                } else if (isSelected) {
                  rowBg = const Color(0xFFF0FDF4);
                } else {
                  rowBg = Colors.transparent;
                }

                return InkWell(
                  onTap: () => _selectOption(option),
                  onHover: (hovering) {
                    if (hovering && _highlightedIndex != index) {
                      setState(() => _highlightedIndex = index);
                      _overlayEntry?.markNeedsBuild();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: rowBg,
                      border: Border(
                        left: BorderSide(
                          color: isSelected
                              ? const Color(0xFF10B981)
                              : (isHighlighted
                                    ? const Color(0xFFCBD5E1)
                                    : Colors.transparent),
                          width: 3.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon / indicator
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            isSelected
                                ? Icons.check_rounded
                                : Icons.inventory_2_outlined,
                            size: 15,
                            color: isSelected
                                ? const Color(0xFF10B981)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Label
                        Expanded(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        // Add new button footer
        if (widget.onAddNew != null && widget.addNewLabel != null) ...[
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
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
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.addNewLabel!,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
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
    final fieldWidget = SizedBox(
      height: 44,
      child: TextFormField(
        key: _fieldKey,
        controller: _textController,
        focusNode: _effectiveFocusNode,
        enabled: widget.enabled,
        readOnly: !widget.enableSearch,
        showCursor: widget.enableSearch ? null : false,
        enableInteractiveSelection: widget.enableSearch ? null : false,
        textInputAction: TextInputAction.next,
        textAlignVertical: TextAlignVertical.center,
        onTap: () {
          if (!widget.enabled) return;
          _effectiveFocusNode.requestFocus();
          if (_overlayEntry == null) {
            _rebuildOptions(forceShow: true);
          }
        },
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
          overflow: TextOverflow.ellipsis,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: widget.borderless
              ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: Colors.grey.shade400,
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
          ),
          filled: widget.borderless ? _effectiveFocusNode.hasFocus : true,
          fillColor: widget.borderless
              ? (_effectiveFocusNode.hasFocus
                    ? const Color(0xFFF8FAFC)
                    : Colors.transparent)
              : (widget.enabled ? Colors.white : const Color(0xFFF8FAFC)),
          border: widget.borderless
              ? InputBorder.none
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
          enabledBorder: widget.borderless
              ? InputBorder.none
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
          disabledBorder: widget.borderless
              ? InputBorder.none
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
          focusedBorder: widget.borderless
              ? InputBorder.none
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF10B981),
                    width: 1.5,
                  ),
                ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.enableSearch &&
                    _textController.text.isNotEmpty &&
                    widget.enabled)
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
                    borderRadius: BorderRadius.circular(6),
                    onTap: widget.enabled ? _toggleOverlay : null,
                    child: AnimatedRotation(
                      turns: _overlayEntry != null ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _overlayEntry != null
                              ? const Color(0xFFE2E8F0)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: widget.enabled
                              ? (_effectiveFocusNode.hasFocus
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF64748B))
                              : Colors.grey.shade300,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onFieldSubmitted: (value) {
          final query = value.trim().toLowerCase();
          final matching = widget.items.where(
            (item) => widget.itemLabel(item).toLowerCase() == query,
          );
          if (matching.isNotEmpty) {
            _selectOption(matching.first);
          } else {
            final partial = widget.items.where(
              (item) => widget.itemLabel(item).toLowerCase().contains(query),
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
    );

    if (!widget.showLabel) {
      return fieldWidget;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
        fieldWidget,
      ],
    );
  }
}
