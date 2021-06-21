/// Example of a time series chart using a bar renderer.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:field_stalker_client/models/package.dart';
import 'package:flutter/material.dart';

class TimeSeriesBar extends StatelessWidget {
  final List<charts.Series<TimeSeriesValues, DateTime>> seriesList;
  final bool animate;

  TimeSeriesBar(this.seriesList, {this.animate});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory TimeSeriesBar.withSampleData() {
    return new TimeSeriesBar(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  /// Creates a [TimeSeriesChart] with data loaded from the source code.
  factory TimeSeriesBar.withPackageData(List<Package> data, String type) {
    return new TimeSeriesBar(
      _getData(data, type),
      animate: true,
    );
  }
  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      // Set the default renderer to a bar renderer.
      // This can also be one of the custom renderers of the time series chart.
      defaultRenderer: new charts.BarRendererConfig<DateTime>(),
      // It is recommended that default interactions be turned off if using bar
      // renderer, because the line point highlighter is the default for time
      // series chart.
      defaultInteractions: false,
      // If default interactions were removed, optionally add select nearest
      // and the domain highlighter that are typical for bar charts.
      behaviors: [new charts.SelectNearest(), new charts.DomainHighlighter()],
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesValues, DateTime>> _createSampleData() {
    final data = [
      new TimeSeriesValues(new DateTime(2017, 9, 1), 5),
      new TimeSeriesValues(new DateTime(2017, 9, 2), 5),
      new TimeSeriesValues(new DateTime(2017, 9, 3), 25),
      new TimeSeriesValues(new DateTime(2017, 9, 4), 100),
      new TimeSeriesValues(new DateTime(2017, 9, 5), 75),
      new TimeSeriesValues(new DateTime(2017, 9, 6), 88),
      new TimeSeriesValues(new DateTime(2017, 9, 7), 65),
      new TimeSeriesValues(new DateTime(2017, 9, 8), 91),
      new TimeSeriesValues(new DateTime(2017, 9, 9), 100),
      new TimeSeriesValues(new DateTime(2017, 9, 10), 111),
      new TimeSeriesValues(new DateTime(2017, 9, 11), 90),
      new TimeSeriesValues(new DateTime(2017, 9, 12), 50),
      new TimeSeriesValues(new DateTime(2017, 9, 13), 40),
      new TimeSeriesValues(new DateTime(2017, 9, 14), 30),
      new TimeSeriesValues(new DateTime(2017, 9, 15), 40),
      new TimeSeriesValues(new DateTime(2017, 9, 16), 50),
      new TimeSeriesValues(new DateTime(2017, 9, 17), 30),
      new TimeSeriesValues(new DateTime(2017, 9, 18), 35),
      new TimeSeriesValues(new DateTime(2017, 9, 19), 40),
      new TimeSeriesValues(new DateTime(2017, 9, 20), 32),
      new TimeSeriesValues(new DateTime(2017, 9, 21), 31),
    ];

    return [
      new charts.Series<TimeSeriesValues, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.teal.shadeDefault,
        domainFn: (TimeSeriesValues values, _) => values.time,
        measureFn: (TimeSeriesValues values, _) => values.value,
        data: data,
      )
    ];
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesValues, DateTime>> _getData(
      List<Package> packages, String type) {
    List<TimeSeriesValues> data = [];
    packages.forEach((element) {
      switch (type) {
        case 'light':
          data.add(TimeSeriesValues(element.timestamp, element.light));
          break;
        case 'humidity':
          data.add(TimeSeriesValues(element.timestamp, element.humidity));
          break;
        default:
          print('error: no such type');
      }
    });
    return [
      new charts.Series<TimeSeriesValues, DateTime>(
        id: 'Value',
        colorFn: (_, __) => type == 'light'
            ? charts.MaterialPalette.yellow.shadeDefault
            : type == 'humidity'
                ? charts.MaterialPalette.red.shadeDefault
                : charts.MaterialPalette.teal.shadeDefault,
        domainFn: (TimeSeriesValues values, _) => values.time,
        measureFn: (TimeSeriesValues values, _) => values.value,
        data: data,
      )
    ];
  }
}

/// Sample time series data type.
class TimeSeriesValues {
  final DateTime time;
  final int value;

  TimeSeriesValues(this.time, this.value);
}
