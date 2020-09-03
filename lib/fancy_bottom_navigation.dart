library fancy_bottom_navigation;

import 'package:fancy_bottom_navigation/internal/tab_item.dart';
import 'package:fancy_bottom_navigation/paint/half_clipper.dart';
import 'package:fancy_bottom_navigation/paint/half_painter.dart';
import 'package:flutter/material.dart';

class TabData {
  TabData({
    @required this.iconData, 
    @required this.title, 
    this.onClick
  });

  final UniqueKey key = UniqueKey();

  IconData iconData;
  String title;
  Function onClick;
}

class FancyBottomNavigation extends StatefulWidget {
  FancyBottomNavigation({
    @required this.tabs,
    @required this.onTabChanged,
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
  }): assert(onTabChanged != null),
      assert(tabs != null);

  final ValueChanged<int> onTabChanged;
  final Color circleColor;
  final Color activeIconColor;
  final Color inactiveIconColor;
  final Color textColor;
  final Color barBackgroundColor;
  final List<TabData> tabs;
  final int initialSelection;
  final double circleSize;
  final double arcHeight;
  final double arcWidth;
  final double circleOutline;
  final double shadowAllowance;
  final double barHeight;

  final Key key;

  @override
  FancyBottomNavigationState createState() => FancyBottomNavigationState();
}

class FancyBottomNavigationState extends State<FancyBottomNavigation> with TickerProviderStateMixin, RouteAware {
  IconData _nextIcon = Icons.search;
  IconData _activeIcon = Icons.search;
  int _currentSelected = 0;
  Color _circleColor;
  Color _activeIconColor;
  Color _inactiveIconColor;
  Color _barBackgroundColor;
  Color _textColor;
  double _circleAlignX = 0;
  double _circleIconAlpha = 1;
  bool _selectable = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _activeIcon = widget.tabs[_currentSelected].iconData;

    _circleColor = (widget.circleColor == null)
        ? (Theme.of(context).brightness == Brightness.dark)
            ? Colors.white
            : Theme.of(context).primaryColor
        : widget.circleColor;

    _activeIconColor = (widget.activeIconColor == null)
        ? (Theme.of(context).brightness == Brightness.dark)
            ? Colors.black54
            : Colors.white
        : widget.activeIconColor;

    _barBackgroundColor = (widget.barBackgroundColor == null)
        ? (Theme.of(context).brightness == Brightness.dark)
            ? Color(0xFF212121)
            : Colors.white
        : widget.barBackgroundColor;
    _textColor = (widget.textColor == null)
        ? (Theme.of(context).brightness == Brightness.dark)
            ? Colors.white
            : Colors.black54
        : widget.textColor;
    _inactiveIconColor = (widget.inactiveIconColor == null)
        ? (Theme.of(context).brightness == Brightness.dark)
            ? Colors.white
            : Theme.of(context).primaryColor
        : widget.inactiveIconColor;
  }

  @override
  void initState() {
    super.initState();
    _setSelected(widget.tabs[widget.initialSelection].key);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      overflow: Overflow.visible,
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

  void setTab(int tab) {
    widget.onTabChanged(tab);
    _setSelected(widget.tabs[tab].key);
    _initAnimationAndStart(_circleAlignX, 1);
    setState(() => _currentSelected = tab);
  }

  void setSelectable(bool selectable) {
    _selectable = selectable;
  }

  void _setSelected(UniqueKey key) {
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

  void _handleTabItemPressed(UniqueKey key) {
    if(_selectable) {
      int page = widget.tabs.indexWhere((tabData) => tabData.key == key);
      widget.onTabChanged(page);
      _setSelected(key);
      _initAnimationAndStart(_circleAlignX, 1);
    }
  }
}
