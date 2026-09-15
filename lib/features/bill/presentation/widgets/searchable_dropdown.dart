import 'package:flutter/material.dart';

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

class _SearchableDropdownState<T extends Object> extends State<SearchableDropdown<T>> {
  late final TextEditingController _textController;
  final GlobalKey _fieldKey = GlobalKey();
  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode => widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.selectedItem != null ? widget.itemLabel(widget.selectedItem!) : '',
    );
    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_effectiveFocusNode.hasFocus) {
      // Auto-select text on focus so typing immediately replaces it
      _textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _textController.text.length,
      );
    } else {
      // On blur, if text does not match any item, restore selected item label or clear
      if (widget.selectedItem != null) {
        final currentText = _textController.text.trim().toLowerCase();
        final selectedText = widget.itemLabel(widget.selectedItem!).toLowerCase();
        if (currentText != selectedText) {
          _textController.text = widget.itemLabel(widget.selectedItem!);
        }
      } else {
        _textController.clear();
      }
    }
  }

  @override
  void didUpdateWidget(covariant SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItem != oldWidget.selectedItem) {
      final newText = widget.selectedItem != null ? widget.itemLabel(widget.selectedItem!) : '';
      _textController.text = newText;
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    _textController.dispose();
    super.dispose();
  }

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
        RawAutocomplete<T>(
          textEditingController: _textController,
          focusNode: _effectiveFocusNode,
          displayStringForOption: widget.itemLabel,
          optionsBuilder: (TextEditingValue textEditingValue) {
            final query = textEditingValue.text.trim().toLowerCase();
            final selectedLabel =
                widget.selectedItem != null ? widget.itemLabel(widget.selectedItem!).toLowerCase() : '';

            // If empty or query equals current selected item label, show all items
            if (query.isEmpty || query == selectedLabel) {
              return widget.items;
            }

            return widget.items.where((item) {
              return widget.itemLabel(item).toLowerCase().contains(query);
            });
          },
          onSelected: (T option) {
            widget.onChanged(option);
            widget.nextFocusNode?.requestFocus();
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextFormField(
              key: _fieldKey,
              controller: controller,
              focusNode: focusNode,
              enabled: widget.enabled,
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: widget.enabled ? Colors.white : const Color(0xFFF8FAFC),
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
                  borderSide: const BorderSide(color: Color(0xFF0D3B82), width: 2.0),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.text.isNotEmpty && widget.enabled)
                      IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        color: Colors.grey.shade400,
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Clear',
                        onPressed: () {
                          controller.clear();
                          _effectiveFocusNode.requestFocus();
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: widget.enabled ? Colors.grey.shade600 : Colors.grey.shade300,
                        size: 20,
                      ),
                      visualDensity: VisualDensity.compact,
                      onPressed: widget.enabled
                          ? () {
                              _effectiveFocusNode.requestFocus();
                            }
                          : null,
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
                  widget.onChanged(matching.first);
                  widget.nextFocusNode?.requestFocus();
                } else {
                  final partial = widget.items.where(
                    (item) => widget.itemLabel(item).toLowerCase().contains(query),
                  );
                  if (partial.length == 1) {
                    widget.onChanged(partial.first);
                    controller.text = widget.itemLabel(partial.first);
                    widget.nextFocusNode?.requestFocus();
                  } else if (widget.selectedItem != null) {
                    controller.text = widget.itemLabel(widget.selectedItem!);
                    widget.nextFocusNode?.requestFocus();
                  } else {
                    onFieldSubmitted();
                  }
                }
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            final renderBox = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
            final fieldWidth = renderBox != null ? renderBox.size.width : 320.0;

            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                shadowColor: Colors.black.withValues(alpha: 0.15),
                child: Container(
                  width: fieldWidth,
                  constraints: const BoxConstraints(maxHeight: 280),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (options.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Text(
                            'No matches found',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        Flexible(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final option = options.elementAt(index);
                              final isSelected = widget.selectedItem == option;
                              final isHighlighted =
                                  AutocompleteHighlightedOption.of(context) == index;

                              return InkWell(
                                onTap: () {
                                  onSelected(option);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  color: isHighlighted
                                      ? const Color(0xFFEFF6FF)
                                      : (isSelected ? const Color(0xFFF1F5F9) : Colors.transparent),
                                  child: Row(
                                    children: [
                                      if (isSelected)
                                        const Icon(Icons.check_rounded, size: 16, color: Color(0xFF0D3B82))
                                      else
                                        const SizedBox(width: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          widget.itemLabel(option),
                                          style: TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 13,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
                            widget.onAddNew!();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                const Icon(Icons.add_circle_outline_rounded,
                                    size: 16, color: Color(0xFF0D3B82)),
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
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
