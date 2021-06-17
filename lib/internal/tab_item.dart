import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

const double ICON_OFF = -3;
const double ICON_ON = 0;
const double TEXT_OFF = 3;
const double TEXT_ON = 1;
const double ALPHA_OFF = 0;
const double ALPHA_ON = 1;
const int ANIM_DURATION = 300;

class TabItem extends StatelessWidget {
  TabItem({
    required Key key,
    required this.selected,
    required this.iconData,
    required this.title,
    required this.onPressed,
    required this.textColor,
    required this.iconColor
  }): super(key: key);

  final String title;
  final IconData iconData;
  final bool selected;
  final Color textColor;
  final Color iconColor;
  final Function(Key key) onPressed;

  final double iconYAlign = ICON_ON;
  final double textYAlign = TEXT_OFF;
  final double iconAlpha = ALPHA_ON;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            child: AnimatedAlign(
              duration: Duration(milliseconds: ANIM_DURATION),
              alignment: Alignment(0, (selected) ? TEXT_ON : TEXT_OFF),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AutoSizeText(
                  title,
                  maxLines: 1,
                  minFontSize: 6,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor
                  ),
                ),
              )
            ),
          ),
          Container(
            height: double.infinity,
            width: double.infinity,
            child: AnimatedAlign(
              curve: Curves.easeIn,
              duration: Duration(milliseconds: ANIM_DURATION),
              alignment: Alignment(0, selected ? ICON_OFF : ICON_ON),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: ANIM_DURATION),
                opacity: selected ? ALPHA_OFF : ALPHA_ON,
                child: IconButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  padding: EdgeInsets.all(0),
                  alignment: Alignment(0, 0),
                  icon: Icon(
                    iconData,
                    color: iconColor,
                  ),
                  onPressed: () => onPressed.call(key!),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
