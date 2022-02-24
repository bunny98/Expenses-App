import 'package:expense/models/category.dart';
import 'package:expense/models/month_to_expense.dart';
import 'package:expense/models/monthly_cat_expense.dart';
import 'package:expense/utils/category_encap.dart';
import 'package:expense/models/payment_method_data.dart';
import 'package:expense/view_model.dart/expense_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({Key? key, required this.scrollController})
      : super(key: key);

  final ScrollController scrollController;
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen>
    with AutomaticKeepAliveClientMixin {
  late TooltipBehavior _tooltipBehaviorPieChart;
  late TooltipBehavior _tooltipBehaviorSplineChart;
  late TooltipBehavior _tooltipBehaviorTotalExpense;

  @override
  void initState() {
    _tooltipBehaviorPieChart = TooltipBehavior(enable: true);
    _tooltipBehaviorSplineChart = TooltipBehavior(enable: true);
    _tooltipBehaviorTotalExpense = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseViewModel>(builder: (context, model, child) {
      CategoryEncapsulator categoryEncapsulator =
          model.getCategoryEncapsulator();
      return Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            const SliverToBoxAdapter(
                child: Center(
              child: Text("Touch the legends to simplify graphs",
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
            )),
            SliverToBoxAdapter(
              child: SfCircularChart(
                title: ChartTitle(text: "Category wise expense"),
                legend: Legend(
                    isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
                tooltipBehavior: _tooltipBehaviorPieChart,
                series: <CircularSeries>[
                  PieSeries<Category, String>(
                      dataSource: model.getAllCategories(),
                      xValueMapper: (datum, _) => datum.name,
                      yValueMapper: (datum, _) => datum.totalExpense,
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                      enableTooltip: true)
                ],
              ),
            ),
            SliverToBoxAdapter(
                child: SfCartesianChart(
                    title: ChartTitle(
                      text: "Total Monthly expenditure",
                    ),
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis: NumericAxis(
                      numberFormat:
                          NumberFormat.compactSimpleCurrency(locale: "en_IN"),
                    ),
                    tooltipBehavior: _tooltipBehaviorTotalExpense,
                    series: <ChartSeries>[
                  // Renders line chart
                  LineSeries<MonthToExpense, String>(
                      name: "Total Expense",
                      enableTooltip: true,
                      dataSource: categoryEncapsulator.getTotalMonthlyExpense(),
                      markerSettings: const MarkerSettings(isVisible: true),
                      xValueMapper: (datnum, _) => datnum.month,
                      yValueMapper: (datnum, _) => datnum.expense),
                ])),
            SliverToBoxAdapter(
                child: SfCartesianChart(
                    title: ChartTitle(
                      text: "Monthly Category expenditure",
                    ),
                    legend: Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                        overflowMode: LegendItemOverflowMode.wrap),
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis: NumericAxis(
                      numberFormat:
                          NumberFormat.compactSimpleCurrency(locale: "en_IN"),
                    ),
                    tooltipBehavior: _tooltipBehaviorSplineChart,
                    series: <ChartSeries>[
                  for (var monthlyCatExp
                      in categoryEncapsulator.getMonthlyCatExpense())
                    SplineSeries<MonthToExpense, String>(
                        enableTooltip: true,
                        dataSource: monthlyCatExp.getData(),
                        name: monthlyCatExp.categoryName,
                        markerSettings: const MarkerSettings(isVisible: true),
                        xValueMapper: (MonthToExpense item, _) => item.month,
                        yValueMapper: (MonthToExpense item, _) => item.expense),
                ])),
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
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                    ),
                  ]),
            )
          ],
        ),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
