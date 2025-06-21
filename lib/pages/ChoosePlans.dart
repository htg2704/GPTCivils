import 'package:civils_gpt/pages/CartPage.dart';
import 'package:civils_gpt/providers/PremiumProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/AppConstants.dart';

class ChoosePlans extends StatefulWidget {
  const ChoosePlans({super.key});

  @override
  ChoosePlansState createState() => ChoosePlansState();
}

class ChoosePlansState extends State<ChoosePlans> {
  int selectedPlan = -1;
  Map<String, dynamic> selectedData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColour,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(FontAwesomeIcons.arrowLeft, size: 24)),
        ),
      ),
      body: Consumer<PremiumProvider>(
        builder: (BuildContext context, PremiumProvider value, Widget? child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    SizedBox(
                      height: 50,
                      child: Center(
                        child: Text(
                          value.premium != "NO" ? "Current Plan" : "Choose Your Plan",
                          style: GoogleFonts.roboto(
                              fontSize: 32, fontWeight: FontWeight.w900),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("plans")
                        .snapshots(),
                    builder: (BuildContext context, final data) {
                      if (data.hasData) {
                        return ListView.builder(
                            itemCount: data.data!.size,
                            itemBuilder: (BuildContext context, int index) {
                              if ((value.premium != "NO" &&
                                      data.data!.docs[index].data()['planID'] ==
                                          value.planID) ||
                                  !(value.premium != "NO")) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      top: 12, bottom: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (!(value.premium != "NO")) {
                                        if (selectedPlan != index) {
                                          setState(() {
                                            selectedPlan = index;
                                            selectedData =
                                                data.data!.docs[index].data();
                                          });
                                        } else if (selectedPlan == index) {
                                          setState(() {
                                            selectedPlan = -1;
                                            selectedData = {};
                                          });
                                        }
                                      }
                                    },
                                    child: Stack(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 20, top: 12),
                                          child: Container(
                                            height: 121,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: AppConstants
                                                    .choosePlanColour,
                                                boxShadow: [
                                                  if (selectedPlan != index)
                                                    const BoxShadow(
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.1),
                                                        blurRadius: 8,
                                                        offset: Offset(0, 4))
                                                ]),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 20,
                                                                left: 20),
                                                        child: Text(
                                                          data.data!.docs[index]
                                                              .data()['title'],
                                                          style: GoogleFonts
                                                              .roboto(
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 10,
                                                                  left: 20),
                                                          child: Text(
                                                            data.data!
                                                                .docs[index]
                                                                .data()['sd1'],
                                                            style: GoogleFonts
                                                                .roboto(
                                                              fontSize: 10,
                                                            ),
                                                          )),
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 10,
                                                                  left: 20),
                                                          child: Text(
                                                            data.data!
                                                                .docs[index]
                                                                .data()['sd2'],
                                                            style: GoogleFonts
                                                                .roboto(
                                                              fontSize: 10,
                                                            ),
                                                          ))
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 5),
                                                          child: Text(
                                                            "₹ ${data.data!.docs[index].data()['price'].toString()}",
                                                            style: GoogleFonts
                                                                .roboto(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                            ),
                                                          )),
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 5),
                                                          child: Text(
                                                            data.data!
                                                                    .docs[index]
                                                                    .data()[
                                                                'duration'],
                                                            style: GoogleFonts
                                                                .roboto(
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
                                        if (selectedPlan == index)
                                          Positioned(
                                            top: 2,
                                            right: 6,
                                            child: Icon(
                                              Icons.verified,
                                              size: 32,
                                              color:
                                                  AppConstants.uploadTextColour,
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            });
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
              ),
              if (!(value.premium != "NO"))
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(
                            top: 12, bottom: 12, left: 20, right: 20),
                        child: Text(
                            "Coupons can be applied at the next screen, payment gateway to be selected. Proceed to checkout",
                            style: TextStyle(
                                color: AppConstants.finePrintsColour))),
                    GestureDetector(
                      onTap: () {
                        if (selectedPlan != -1) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => CartPage(
                                    data: selectedData,
                                  )));
                        }
                      },
                      child: Padding(
                          padding: const EdgeInsets.only(
                              top: 12, bottom: 24, left: 20, right: 20),
                          child: Container(
                            height: 70,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: AppConstants.secondaryColour),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Select Plan",
                                  style: GoogleFonts.roboto(
                                      color: selectedPlan == -1
                                          ? AppConstants.textBubbleColour
                                          : Colors.white,
                                      fontSize: selectedPlan == -1 ? 14 : 16,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          )),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
