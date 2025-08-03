import 'package:civils_gpt/providers/PremiumProvider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/AppConstants.dart';
import '../services/helper.dart';

class CartPage extends StatefulWidget {
  Map<String, dynamic> data;

  CartPage({super.key, required this.data});

  @override
  CartPageState createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  TextEditingController couponCodeController = TextEditingController();
  bool discountLoading = false;
  int discount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColour,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(FontAwesomeIcons.arrowLeft, size: 24)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 50,
                          child: Center(
                            child: Text(
                              "Cart",
                              style: GoogleFonts.roboto(
                                  fontSize: 32, fontWeight: FontWeight.w900),
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 12),
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              height: 121,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppConstants.choosePlanColour,
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.1),
                                        blurRadius: 8,
                                        offset: Offset(0, 4))
                                  ]),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20, left: 20),
                                          child: Text(
                                            widget.data["title"],
                                            style: GoogleFonts.roboto(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, left: 20),
                                            child: Text(
                                              widget.data["sd1"],
                                              style: GoogleFonts.roboto(
                                                fontSize: 10,
                                              ),
                                            )),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, left: 20),
                                            child: Text(
                                              widget.data["sd2"],
                                              style: GoogleFonts.roboto(
                                                fontSize: 10,
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Text(
                                              "₹ ${widget.data["price"].toString()}",
                                              style: GoogleFonts.roboto(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            )),
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Text(
                                              widget.data["duration"],
                                              style: GoogleFonts.roboto(
                                                fontSize: 10,
                                              ),
                                            )),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 25, bottom: 25),
                          child: Text(
                            "Apply Coupon",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      onSubmitted: (_) async {
                        if (couponCodeController.text.trim().isNotEmpty) {
                          setState(() {
                            discountLoading = true;
                          });
                          final discountNumber = await PaymentHelper()
                              .checkDiscountCode(
                                  couponCodeController.text
                                      .toUpperCase()
                                      .trim(),
                                  widget.data["planID"]);
                          if (discountNumber == 0) {
                            couponCodeController.clear();
                          }
                          setState(() {
                            discountLoading = false;
                            discount = discountNumber;
                          });
                        }
                      },
                      controller: couponCodeController,
                      decoration: InputDecoration(
                        fillColor: AppConstants.primaryColour,
                        labelText: 'Enter coupon code',
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(24))),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 25, bottom: 25),
                          child: Text(
                            "Order Summary",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    if (discountLoading == true)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    if (discountLoading == false)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Price",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: AppConstants.finePrintsColour),
                                ),
                                Text(
                                  "₹ ${widget.data["price"].toString()}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: AppConstants.finePrintsColour),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Convenience Fees",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: AppConstants.finePrintsColour),
                                ),
                                Text(
                                  "₹ 0",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: AppConstants.finePrintsColour),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Discount",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: AppConstants.finePrintsColour),
                                ),
                                Text(
                                  "₹ ${(discount * -1).toString()}",
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            height: 1,
                            color: Colors.black38,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total",
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "₹ ${(widget.data["price"] - discount).toString()}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Consumer<PremiumProvider>(
              builder:
                  (BuildContext context, PremiumProvider value, Widget? child) {
                return GestureDetector(
                  onTap: () async {
                    // Show a loading indicator while payment is processing
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing payment...')),
                    );

                    // The doPayment method now handles updating the provider's state
                    bool status = await PaymentHelper().doPayment(
                        (widget.data["price"] - discount),
                        value, // Pass the provider to the helper
                        widget.data,
                        couponCodeController.text.toUpperCase().trim());

                    // Hide the loading indicator
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();

                    if (status == true && mounted) {
                      // On success, just navigate back. The provider is already updated.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Payment successful! Your plan is active.')),
                      );
                      // Pop twice to go back past the "Choose Plans" page
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    } else {
                      // Handle payment failure
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Payment failed. Please try again.")),
                        );
                      }
                    }
                  },
                  child: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 24),
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: AppConstants.secondaryColour),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Proceed to Pay",
                              style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
