import 'package:expense/models/category.dart';
import 'package:expense/utils/category_encap.dart';
import 'package:expense/models/payment_method_data.dart';
import 'package:expense/view_model.dart/expense_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({Key? key, required this.scrollController})
      : super(key: key);

  final ScrollController scrollController;
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen>
    with AutomaticKeepAliveClientMixin {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseViewModel>(
      builder: (context, model, child) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: SfCircularChart(
                title: ChartTitle(text: "Category wise expense"),
                legend: Legend(
                    isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
                tooltipBehavior: _tooltipBehavior,
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
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
