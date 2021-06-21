/// Timeseries chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import '../models/package.dart';

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleTimeSeriesChart(this.seriesList, {this.animate});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory SimpleTimeSeriesChart.withSampleData() {
    return new SimpleTimeSeriesChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  /// Creates a [TimeSeriesChart] with data loaded from the source.
  factory SimpleTimeSeriesChart.withPackageData(List<Package> data,
      {String type = 'all'}) {
    return new SimpleTimeSeriesChart(
      type == 'temperature' ? _getData(data) : _getAllData(data),
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesTemp, DateTime>> _createSampleData() {
    final data = [
      new TimeSeriesTemp(new DateTime(2017, 9, 19), 35),
      new TimeSeriesTemp(new DateTime(2017, 9, 26), 28),
      new TimeSeriesTemp(new DateTime(2017, 10, 3), 32),
      new TimeSeriesTemp(new DateTime(2017, 10, 10), 18),
    ];

    return [
      new charts.Series<TimeSeriesTemp, DateTime>(
        id: 'Temperatures',
        colorFn: (_, __) => charts.MaterialPalette.teal.shadeDefault,
        domainFn: (TimeSeriesTemp temp, _) => temp.time,
        measureFn: (TimeSeriesTemp temp, _) => temp.temp,
        data: data,
      )
    ];
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesTemp, DateTime>> _getData(
      List<Package> packages) {
    List<TimeSeriesTemp> data = [];
    packages.forEach((element) {
      data.add(TimeSeriesTemp(element.timestamp, element.temp));
    });

    return [
      new charts.Series<TimeSeriesTemp, DateTime>(
        id: 'Temperatures',
        colorFn: (_, __) => charts.MaterialPalette.teal.shadeDefault,
        domainFn: (TimeSeriesTemp temp, _) => temp.time,
        measureFn: (TimeSeriesTemp temp, _) => temp.temp,
        data: data,
      )
    ];
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeries, DateTime>> _getAllData(
      List<Package> packages) {
    List<TimeSeries> data = [];
    packages.forEach((element) {
      data.add(TimeSeries(
          element.timestamp, element.temp, element.light, element.humidity));
    });

    return [
      new charts.Series<TimeSeries, DateTime>(
        id: 'Temperatures',
        colorFn: (_, __) => charts.MaterialPalette.teal.shadeDefault,
        domainFn: (TimeSeries val, _) => val.time,
        measureFn: (TimeSeries val, _) => val.temp,
        data: data,
      ),
      new charts.Series<TimeSeries, DateTime>(
        id: 'Light',
        colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        domainFn: (TimeSeries val, _) => val.time,
        measureFn: (TimeSeries val, _) => val.light,
        data: data,
      ),
      new charts.Series<TimeSeries, DateTime>(
        id: 'Humidity',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (TimeSeries val, _) => val.time,
        measureFn: (TimeSeries val, _) => val.humidity,
        data: data,
      )
    ];
  }
}

/// Sample time series data type.
class TimeSeriesTemp {
  final DateTime time;
  final int temp;

  TimeSeriesTemp(this.time, this.temp);
}

class TimeSeries {
  final DateTime time;
  final int temp;
  final int light;
  final int humidity;

  TimeSeries(this.time, this.temp, this.light, this.humidity);
}
