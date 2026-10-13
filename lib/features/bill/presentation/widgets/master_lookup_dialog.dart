import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Describes one column of a [MasterLookupDialog] table.
class MasterLookupColumn<T extends Object> {
  const MasterLookupColumn({
    required this.title,
    required this.value,
    this.flex = 1,
    this.align = TextAlign.left,
    this.bold = false,
  });

  /// Column heading, rendered upper-case.
  final String title;

  /// Cell text for [item].
  final String Function(T item) value;

  /// Relative width. The serial column is narrower than this so a code or name
  /// never gets squeezed out by a short identifier column.
  final int flex;

  final TextAlign align;

  /// Renders the cell in a heavier weight, used to emphasise the human
  /// readable description next to its numeric code.
  final bool bold;
}

/// A legacy-style master table picker.
///
/// The legacy weighbridge software never used a dropdown for master lookups: it
/// opened a titled grid with an `S.No.` column, a filter box and a scrollable
/// body, and the operator picked a whole row. This dialog reproduces that shape
/// so the ticket screen behaves the way operators already expect, while keeping
/// the surrounding screen's typography and palette.
///
/// It is deliberately generic so the same dialog serves the material master and
/// the customer master - only the title, columns and search terms differ.
class MasterLookupDialog<T extends Object> extends StatefulWidget {
  const MasterLookupDialog({
    super.key,
    required this.title,
    required this.items,
    required this.columns,
    this.showSerialNumber = true,
    this.serialNumberTitle = 'S.No.',
    this.selectedItem,
    this.searchHint,
    this.searchTerms,
    this.emptyMessage = 'No records found',
    this.width = 560,
    this.maxBodyHeight = 380,
  });

  final String title;
  final List<T> items;
  final List<MasterLookupColumn<T>> columns;

  /// Prepends the `S.No.` column that the legacy grids always carried.
  final bool showSerialNumber;
  final String serialNumberTitle;

  /// Pre-highlighted row. The legacy grids marked the current value, so the
  /// operator can see where the form already stands before changing it.
  final T? selectedItem;

  final String? searchHint;

  /// Extra values folded into the filter that no column displays, so a customer
  /// can be found by mobile number or GST number without those becoming
  /// visible columns.
  final Iterable<String> Function(T item)? searchTerms;

  final String emptyMessage;
  final double width;
  final double maxBodyHeight;

  /// Opens the picker and resolves to the picked row, or `null` if the
  /// operator closed it without choosing.
  static Future<T?> show<T extends Object>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required List<MasterLookupColumn<T>> columns,
    bool showSerialNumber = true,
    String serialNumberTitle = 'S.No.',
    T? selectedItem,
    String? searchHint,
    Iterable<String> Function(T item)? searchTerms,
    String emptyMessage = 'No records found',
    double width = 560,
    double maxBodyHeight = 380,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.45),
      builder: (_) => MasterLookupDialog<T>(
        title: title,
        items: items,
        columns: columns,
        showSerialNumber: showSerialNumber,
        serialNumberTitle: serialNumberTitle,
        selectedItem: selectedItem,
        searchHint: searchHint,
        searchTerms: searchTerms,
        emptyMessage: emptyMessage,
        width: width,
        maxBodyHeight: maxBodyHeight,
      ),
    );
  }

  @override
  State<MasterLookupDialog<T>> createState() => _MasterLookupDialogState<T>();
}

class _MasterLookupDialogState<T extends Object>
    extends State<MasterLookupDialog<T>> {
  static const double _rowHeight = 38;

  static const Color _brand = Color(0xFF0D3B82);
  static const Color _accent = Color(0xFF2563EB);
  static const Color _gridLine = Color(0xFFE2E8F0);
  static const Color _rowLine = Color(0xFFF1F5F9);
  static const Color _selectedRow = Color(0xFFDBEAFE);

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  String _query = '';
  int _highlightedIndex = 0;
  int _hoveredIndex = -1;

  @override
  void initState() {
    super.initState();
    _highlightedIndex = _initialIndexFor(widget.selectedItem);
    _searchFocusNode.onKeyEvent = _handleKeyEvent;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Filtering
  // ---------------------------------------------------------------------------

  /// Matches the query against every visible column plus [MasterLookupDialog.searchTerms].
  bool _matches(T item, String needle) {
    for (final column in widget.columns) {
      if (column.value(item).toLowerCase().contains(needle)) return true;
    }
    final extra = widget.searchTerms;
    if (extra != null) {
      for (final term in extra(item)) {
        if (term.toLowerCase().contains(needle)) return true;
      }
    }
    return false;
  }

  List<T> get _filteredItems {
    final needle = _query.trim().toLowerCase();
    if (needle.isEmpty) return widget.items;
    return widget.items.where((item) => _matches(item, needle)).toList();
  }

  /// Row index of [item] within [items], or 0 when it is absent.
  int _initialIndexFor(T? item) {
    if (item == null) return 0;
    final index = widget.items.indexOf(item);
    return index < 0 ? 0 : index;
  }

  // ---------------------------------------------------------------------------
  // Keyboard navigation
  // ---------------------------------------------------------------------------

  void _onSearchChanged(String value) {
    final filtered = _filteredItems;
    setState(() {
      _query = value;
      // Keep the operator on a row so Enter always has a target. Land on the
      // current selection when the filter still contains it, else the first hit.
      final selected = widget.selectedItem;
      final keepIndex = selected == null ? -1 : filtered.indexOf(selected);
      _highlightedIndex = keepIndex >= 0 ? keepIndex : 0;
    });
    _scrollHighlightIntoView();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final filtered = _filteredItems;

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (filtered.isEmpty) return KeyEventResult.handled;
      setState(() {
        _highlightedIndex = (_highlightedIndex + 1) % filtered.length;
      });
      _scrollHighlightIntoView();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (filtered.isEmpty) return KeyEventResult.handled;
      setState(() {
        _highlightedIndex =
            (_highlightedIndex - 1 + filtered.length) % filtered.length;
      });
      _scrollHighlightIntoView();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (filtered.isNotEmpty && _highlightedIndex < filtered.length) {
        _select(filtered[_highlightedIndex]);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Scrolls the highlighted row into view.
  ///
  /// The body uses a fixed [itemExtent], so the row's top edge is a plain
  /// multiplication rather than a measured layout, and the result is clamped so
  /// the body never ends up over-scrolled past its last row.
  void _scrollHighlightIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_highlightedIndex < 0) return;

      final position = _scrollController.position;
      final rowTop = _highlightedIndex * _rowHeight;
      final rowBottom = rowTop + _rowHeight;
      final viewTop = position.pixels;
      final viewBottom = viewTop + position.viewportDimension;

      double? target;
      if (rowTop < viewTop) {
        target = rowTop;
      } else if (rowBottom > viewBottom) {
        target = rowBottom - position.viewportDimension;
      }
      if (target == null) return;

      final clamped = target.clamp(0.0, position.maxScrollExtent);
      if (clamped == position.pixels) return;
      _scrollController.jumpTo(clamped);
    });
  }

  // ---------------------------------------------------------------------------
  // Selection
  // ---------------------------------------------------------------------------

  void _select(T item) {
    Navigator.of(context).pop(item);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.width),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _gridLine),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F0F172A),
                blurRadius: 32,
                offset: Offset(0, 16),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitleBar(),
              _buildSearchRow(filtered.length),
              _buildTableHeader(),
              Flexible(child: _buildBody(filtered)),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      height: 44,
      color: _brand,
      padding: const EdgeInsets.only(left: 16, right: 6),
      child: Row(
        children: [
          const SizedBox(width: 28),
          Expanded(
            child: Text(
              widget.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 28),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.close_rounded,
                size: 19,
                color: Color(0xCCFFFFFF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow(int visibleCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(bottom: BorderSide(color: _gridLine)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                key: const Key('master_lookup_search'),
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: widget.searchHint ?? 'Type to filter',
                  hintStyle: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF94A3B8),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 17,
                    color: Color(0xFF64748B),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 34,
                    minHeight: 34,
                  ),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : InkWell(
                          onTap: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.clear_rounded,
                              size: 15,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: _gridLine),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: _gridLine),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: _accent, width: 1.5),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            visibleCount == 1 ? '1 record' : '$visibleCount records',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFFE2E8F0),
        border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1))),
      ),
      child: Row(
        children: [
          if (widget.showSerialNumber)
            Expanded(
              flex: 2,
              child: _headerCell(widget.serialNumberTitle, center: true),
            ),
          for (final column in widget.columns)
            Expanded(
              flex: column.flex,
              child: _headerCell(column.title, align: column.align),
            ),
        ],
      ),
    );
  }

  Widget _headerCell(String title, {bool center = false, TextAlign? align}) {
    return Container(
      alignment: center ? Alignment.center : Alignment.centerLeft,
      padding: EdgeInsets.only(left: center ? 0 : 12, right: 12),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFFCBD5E1))),
      ),
      child: Text(
        title.toUpperCase(),
        textAlign: align ?? (center ? TextAlign.center : TextAlign.left),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildBody(List<T> filtered) {
    if (filtered.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        child: Text(
          widget.emptyMessage,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.maxBodyHeight),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ListView.builder(
          key: const Key('master_lookup_list'),
          controller: _scrollController,
          itemExtent: _rowHeight,
          padding: EdgeInsets.zero,
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return _buildRow(filtered[index], index, filtered);
          },
        ),
      ),
    );
  }

  Widget _buildRow(T item, int index, List<T> filtered) {
    final isSelected = widget.selectedItem == item;
    final isHighlighted = _highlightedIndex == index;
    final isHovered = _hoveredIndex == index;

    Color background;
    if (isSelected) {
      background = _selectedRow;
    } else if (isHighlighted || isHovered) {
      background = const Color(0xFFF1F5F9);
    } else {
      background = Colors.white;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      child: InkWell(
        key: Key('master_lookup_row_$index'),
        onTap: () => _select(item),
        onDoubleTap: () => _select(item),
        child: Container(
          height: _rowHeight,
          color: background,
          child: Row(
            children: [
              if (widget.showSerialNumber)
                Expanded(
                  flex: 2,
                  child: _cell(
                    Text(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12.5,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: isSelected ? _brand : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              for (final column in widget.columns)
                Expanded(
                  flex: column.flex,
                  child: _cell(
                    Text(
                      column.value(item),
                      textAlign: column.align,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: column.bold || isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected ? _brand : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell(Widget child) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: _rowLine),
          bottom: BorderSide(color: _rowLine),
        ),
      ),
      child: child,
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: _gridLine)),
      ),
      child: Center(
        child: TextButton(
          key: const Key('master_lookup_close'),
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF64748B),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Close',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
