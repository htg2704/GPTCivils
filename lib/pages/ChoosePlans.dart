// lib/pages/ChoosePlans.dart

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
  int selectedPlanIndex = -1;
  Map<String, dynamic> selectedPlanData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(FontAwesomeIcons.arrowLeft, size: 24, color: Colors.black87)),
      ),
      body: Consumer<PremiumProvider>(
        builder: (BuildContext context, PremiumProvider premiumProvider, Widget? child) {

          // Show a loading indicator while the premium status is being checked
          if (premiumProvider.state == PremiumState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    premiumProvider.isPremium ? "Your Current Plan" : "Choose Your Plan",
                    style: GoogleFonts.poppins(
                        fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black87),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection("plans").snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No plans available right now."));
                        }

                        final allPlans = snapshot.data!.docs;
                        List<DocumentSnapshot> plansToShow;

                        if (premiumProvider.isPremium) {
                          // Filter to show only the user's current plan
                          plansToShow = allPlans.where((doc) {
                            final plan = doc.data() as Map<String, dynamic>;
                            return plan['planID'] == premiumProvider.planID;
                          }).toList();
                        } else {
                          plansToShow = allPlans;
                        }

                        if (plansToShow.isEmpty && premiumProvider.isPremium) {
                          return const Center(child: Text("Your current plan details could not be loaded."));
                        }

                        return ListView.builder(
                            itemCount: plansToShow.length,
                            itemBuilder: (BuildContext context, int index) {
                              final plan = plansToShow[index].data() as Map<String, dynamic>;
                              final bool isSelected = selectedPlanIndex == index;

                              return _buildPlanCard(plan, isSelected, index, !premiumProvider.isPremium);
                            });
                      }),
                ),
                if (!premiumProvider.isPremium) ...[
                  _buildProceedButton(),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, bool isSelected, int index, bool isSelectable) {
    return GestureDetector(
      onTap: isSelectable ? () {
        setState(() {
          if (isSelected) {
            selectedPlanIndex = -1;
            selectedPlanData = {};
          } else {
            selectedPlanIndex = index;
            selectedPlanData = plan;
          }
        });
      } : null, // Disable tap if the user is already premium
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppConstants.cardColour,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppConstants.secondaryColour : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan['title'] ?? 'Plan',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "₹${plan['price']?.toString() ?? '0'}",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.secondaryColour,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              plan['sd1'] ?? '',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              plan['sd2'] ?? '',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                plan['duration'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProceedButton() {
    bool isPlanSelected = selectedPlanIndex != -1;
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isPlanSelected
              ? () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CartPage(data: selectedPlanData)));
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.secondaryColour,
            disabledBackgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            'Proceed to Cart',
            style: GoogleFonts.poppins(
                fontSize: 18,
                color: isPlanSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}