import 'package:flutter/material.dart';

import 'package:flutter_range_slider/flutter_range_slider.dart';

class SkillsShowcase extends StatelessWidget {
  static final GlobalKey sliderKey = GlobalObjectKey("sliderKey");

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Padding(
        padding: EdgeInsets.only(top: 35.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[]
              ..add(Column(
                  key: sliderKey,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[]
                    ..add(Text("Communication",
                        style: textTheme.body1
                            .copyWith(color: Colors.white70, fontSize: 16.0)))
                    ..add(
                      RangeSlider(
                        min: 0.0,
                        max: 100.0,
                        lowerValue: 0.0,
                        upperValue: 70.0,
                        divisions: 10,
                        showValueIndicator: true,
                        valueIndicatorMaxDecimals: 1,
                        onChanged:
                            (double newLowerValue, double newUpperValue) {},
                      ),
                    )))
              ..add(Text("Decision Making",
                  style: textTheme.body1
                      .copyWith(color: Colors.white70, fontSize: 16.0)))
              ..add(
                RangeSlider(
                  min: 0.0,
                  max: 100.0,
                  lowerValue: 0.0,
                  upperValue: 90.0,
                  divisions: 10,
                  showValueIndicator: true,
                  valueIndicatorMaxDecimals: 1,
                  onChanged: (double newLowerValue, double newUpperValue) {},
                ),
              )
              ..add(Text("Leadership",
                  style: textTheme.body1
                      .copyWith(color: Colors.white70, fontSize: 16.0)))
              ..add(
                RangeSlider(
                  min: 0.0,
                  max: 100.0,
                  lowerValue: 0.0,
                  upperValue: 30.0,
                  divisions: 10,
                  showValueIndicator: true,
                  valueIndicatorMaxDecimals: 1,
                  onChanged: (double newLowerValue, double newUpperValue) {},
                ),
              )));
  }
}
