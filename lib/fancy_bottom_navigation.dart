import 'package:flutter/material.dart';

import 'internal/tab_item.dart';
import 'paint/half_clipper.dart';
import 'paint/half_painter.dart';

typedef TabChangedCallback = void Function(int tab, Map<String, dynamic> args);

class TabData {
  TabData({
    Key? key,
    required this.title, 
    required this.iconData, 
    this.onClick
  }): key = key ?? UniqueKey();

  final Key key;
  final String title;
  final IconData iconData;
  final VoidCallback? onClick;
}

class FancyBottomNavigation extends StatefulWidget {
  FancyBottomNavigation({
    required this.tabs,
    required this.onTabChanged,
    this.key,
    this.initialSelection = 0,
    this.circleSize = 60,
    this.arcHeight = 70,
    this.arcWidth = 90,
    this.circleOutline = 10,
    this.shadowAllowance = 20,
    this.barHeight = 60,
    this.circleColor,
    this.activeIconColor,
    this.inactiveIconColor,
    this.textColor,
    this.barBackgroundColor
  });

  final TabChangedCallback onTabChanged;
  final Color? circleColor;
  final Color? activeIconColor;
  final Color? inactiveIconColor;
  final Color? textColor;
  final Color? barBackgroundColor;
  final List<TabData> tabs;
  final int initialSelection;
  final double circleSize;
  final double arcHeight;
  final double arcWidth;
  final double circleOutline;
  final double shadowAllowance;
  final double barHeight;

  final Key? key;

  @override
  FancyBottomNavigationState createState() => FancyBottomNavigationState();
}

class FancyBottomNavigationState extends State<FancyBottomNavigation> with TickerProviderStateMixin, RouteAware {
  late Color _textColor;
  late Color _circleColor;
  late Color _activeIconColor;
  late Color _inactiveIconColor;
  late Color _barBackgroundColor;

  IconData _nextIcon = Icons.search;
  IconData _activeIcon = Icons.search;
  int _currentSelected = 0;
  double _circleAlignX = 0;
  double _circleIconAlpha = 1;
  bool _selectable = true;

  @override
  void initState() {
    super.initState();
    _setSelected(widget.tabs[widget.initialSelection].key);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    _activeIcon = widget.tabs[_currentSelected].iconData;

    _circleColor = widget.circleColor ?? (isDarkMode ? Colors.white : primaryColor);
    _activeIconColor = widget.activeIconColor ?? (isDarkMode ? Colors.black54 : Colors.white);
    _barBackgroundColor = widget.barBackgroundColor ?? (isDarkMode ? Color(0xFF212121) : Colors.white);
    _textColor = widget.textColor ?? (isDarkMode ? Colors.white : Colors.black54);
    _inactiveIconColor = widget.inactiveIconColor ?? (isDarkMode ? Colors.white : primaryColor);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          height: widget.barHeight,
          decoration: BoxDecoration(
            color: _barBackgroundColor, 
            boxShadow: [
              BoxShadow(
                color: Colors.black12, 
                offset: Offset(0, -1),
                blurRadius: 8
              )
            ]
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widget.tabs.map(_buildTabItem).toList(),
          ),
        ),
        Positioned.fill(
          top: -(widget.circleSize + widget.circleOutline + widget.shadowAllowance) / 2,
          child: Container(
            child: AnimatedAlign(
              duration: Duration(milliseconds: ANIM_DURATION),
              curve: Curves.easeOut,
              alignment: Alignment(_circleAlignX, 1),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: FractionallySizedBox(
                  widthFactor: 1 / widget.tabs.length,
                  child: GestureDetector(
                    onTap: widget.tabs[_currentSelected].onClick,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: widget.circleSize + widget.circleOutline + widget.shadowAllowance,
                          width: widget.circleSize + widget.circleOutline + widget.shadowAllowance,
                          child: ClipRect(
                            clipper: HalfClipper(),
                            child: Container(
                              child: Center(
                                child: Container(
                                  width: widget.circleSize + widget.circleOutline,
                                  height: widget.circleSize + widget.circleOutline,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8
                                      )
                                    ]
                                  )
                                ),
                              ),
                            )
                          ),
                        ),
                        SizedBox(
                          height: widget.arcHeight,
                          width: widget.arcWidth,
                          child: CustomPaint(painter: HalfPainter(_barBackgroundColor))
                        ),
                        SizedBox(
                          height: widget.circleSize,
                          width: widget.circleSize,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, 
                              color: _circleColor
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: AnimatedOpacity(
                                duration: Duration(milliseconds: ANIM_DURATION ~/ 5),
                                opacity: _circleIconAlpha,
                                child: Icon(
                                  _activeIcon,
                                  color: _activeIconColor,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildTabItem(TabData data) {
    return TabItem(
      key: data.key,
      selected: data.key == widget.tabs[_currentSelected].key,
      iconData: data.iconData,
      title: data.title,
      iconColor: _inactiveIconColor,
      textColor: _textColor,
      onPressed: _handleTabItemPressed
    );
  }

  void setTab(int tab, {Map<String, dynamic> args = const {}}) {
    widget.onTabChanged(tab, args);
    _setSelected(widget.tabs[tab].key);
    _initAnimationAndStart(_circleAlignX, 1);
    setState(() => _currentSelected = tab);
  }

  void setSelectable(bool selectable) {
    _selectable = selectable;
  }

  void _setSelected(Key key) {
    int selected = widget.tabs.indexWhere((tabData) => tabData.key == key);

    if(mounted) {
      setState(() {
        _currentSelected = selected;
        _nextIcon = widget.tabs[selected].iconData;
        _circleAlignX = -1 + (2 / (widget.tabs.length - 1) * selected);
      });
    }
  }

  void _initAnimationAndStart(double from, double to) {
    _circleIconAlpha = 0;

    Future.delayed(Duration(milliseconds: ANIM_DURATION ~/ 5), () => setState(() => _activeIcon = _nextIcon)).then((_) {
      Future.delayed(Duration(milliseconds: (ANIM_DURATION ~/ 5 * 3)), () => setState(() => _circleIconAlpha = 1));
    });
  }

  void _handleTabItemPressed(Key key) {
    if(_selectable) {
      int page = widget.tabs.indexWhere((tabData) => tabData.key == key);
      widget.onTabChanged(page, const {});
      _setSelected(key);
      _initAnimationAndStart(_circleAlignX, 1);
    }
  }
}
