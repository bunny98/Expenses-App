import 'package:expense/models/category_expense_data.dart';
import 'package:expense/models/payment_method_data.dart';
import 'package:expense/view_model.dart/expense_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({Key? key}) : super(key: key);

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseViewModel>(
      builder: (context, model, child) => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SfCircularChart(
              title: ChartTitle(text: "Category wise expense"),
              legend: Legend(
                  isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
              tooltipBehavior: _tooltipBehavior,
              series: <CircularSeries>[
                PieSeries<CategoryExpenseData, String>(
                    dataSource: model.getCategoryExpenseData(),
                    xValueMapper: (datum, _) => datum.category,
                    yValueMapper: (datum, _) => datum.expense,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    enableTooltip: true)
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SfCartesianChart(
                title: ChartTitle(text: "Payment method wise expense count"),
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(
                    decimalPlaces: 1,
                    title: AxisTitle(text: "Count"),
                    edgeLabelPlacement: EdgeLabelPlacement.shift),
                series: <ChartSeries<PaymentMethodData, String>>[
                  BarSeries<PaymentMethodData, String>(
                    // Bind data source
                    dataSource: model.getPaymentMethodCountData(),
                    xValueMapper: (datum, _) => datum.paymentMethod,
                    yValueMapper: (datum, _) => datum.count,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ]),
          )
        ],
      ),
    );
  }
}
