import 'package:civils_gpt/pages/ChatPage.dart';
import 'package:civils_gpt/pages/ChoosePlans.dart';
import 'package:civils_gpt/pages/EvaluationPage.dart';
import 'package:civils_gpt/pages/LoginPage.dart';
import 'package:civils_gpt/pages/NotesPage.dart';
import 'package:civils_gpt/pages/PrelimsFlash.dart';
import 'package:civils_gpt/pages/QuestionsPage.dart';
import 'package:civils_gpt/providers/ConstantsProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/AppConstants.dart';
import '../providers/PremiumProvider.dart';
import '../services/helper.dart';
import 'DocumentPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user = FirebaseAuth.instance.currentUser;
  List listItems = ["Evaluation", "Answered", "ChatBot"];

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 30), () {
      LoginHelper().checkPremiumStatus(
          Provider.of<PremiumProvider>(context, listen: false));
    });
    super.initState();
  }
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppConstants.primaryColour,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(icon: const Icon(Icons.menu, size: 24), onPressed: () {
              scaffoldKey.currentState?.openDrawer();
            },),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 9, 40, 9),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: Text(
                          'Hi ${user != null ? user?.displayName : "User"}!',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppConstants.secondaryColour)))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: SizedBox(
                height: 64,
                child: SearchAnchor(builder:
                    (BuildContext searchContext, SearchController controller) {
                  return SearchBar(
                    hintText: "Search for any service",
                    elevation: const WidgetStatePropertyAll(0),
                    controller: controller,
                    onTap: () {
                      controller.openView();
                    },
                    onChanged: (_) {
                      controller.openView();
                    },
                    leading: const Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: Icon(
                        Icons.search,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }, suggestionsBuilder: (BuildContext suggestionContext,
                    SearchController controller) {
                  return [
                    if (controller.text.isEmpty ||
                        "Evaluation"
                            .toLowerCase()
                            .trim()
                            .contains(controller.text.toLowerCase()))
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DocumentPage(),
                              ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: SizedBox(
                            height: 64,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: AppConstants.secondaryColour),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12, right: 12),
                                      child: Icon(
                                        Icons.description,
                                        size: 35,
                                        color: AppConstants.iconColour,
                                      ),
                                    ),
                                    Text(
                                      "Evaluation",
                                      style: TextStyle(
                                          color: AppConstants.iconColour,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (controller.text.isEmpty ||
                        "Answered"
                            .toLowerCase()
                            .trim()
                            .contains(controller.text.toLowerCase()))
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EvaluationPage(),
                              ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: SizedBox(
                            height: 64,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: AppConstants.secondaryColour),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12, right: 12),
                                      child: Icon(
                                        Icons.check,
                                        size: 35,
                                        color: AppConstants.iconColour,
                                      ),
                                    ),
                                    Text(
                                      "Answered",
                                      style: TextStyle(
                                          color: AppConstants.iconColour,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (controller.text.isEmpty ||
                        "ChatBot"
                            .toLowerCase()
                            .trim()
                            .contains(controller.text.toLowerCase()))
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChatPage(),
                              ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: SizedBox(
                            height: 64,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: AppConstants.secondaryColour),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12, right: 12),
                                      child: Icon(
                                        Icons.chat,
                                        size: 35,
                                        color: AppConstants.iconColour,
                                      ),
                                    ),
                                    Text(
                                      "ChatBot",
                                      style: TextStyle(
                                          color: AppConstants.iconColour,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // if (controller.text.isEmpty ||
                    //     "Notes"
                    //         .toLowerCase()
                    //         .trim()
                    //         .contains(controller.text.toLowerCase()))
                    //   GestureDetector(
                    //     onTap: () {
                    //       Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => NotesPage(),
                    //           ));
                    //     },
                    //     child: Padding(
                    //       padding: const EdgeInsets.symmetric(vertical: 10),
                    //       child: SizedBox(
                    //         height: 64,
                    //         child: Padding(
                    //           padding: const EdgeInsets.symmetric(horizontal: 10),
                    //           child: Container(
                    //             height: 50,
                    //             decoration: BoxDecoration(
                    //                 borderRadius: BorderRadius.circular(20),
                    //                 color: AppConstants.secondaryColour),
                    //             child: Row(
                    //               crossAxisAlignment: CrossAxisAlignment.center,
                    //               children: [
                    //                 Padding(
                    //                   padding: const EdgeInsets.only(
                    //                       left: 12, right: 12),
                    //                   child: Icon(
                    //                     Icons.note_add,
                    //                     size: 35,
                    //                     color: AppConstants.iconColour,
                    //                   ),
                    //                 ),
                    //                 Text(
                    //                   "Notes",
                    //                   style: TextStyle(
                    //                       color: AppConstants.iconColour,
                    //                       fontSize: 16,
                    //                       fontWeight: FontWeight.w600),
                    //                 )
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    if (controller.text.isEmpty ||
                        "Questions"
                            .toLowerCase()
                            .trim()
                            .contains(controller.text.toLowerCase()))
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QuestionsPage(),
                              ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: SizedBox(
                            height: 64,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: AppConstants.secondaryColour),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12, right: 12),
                                      child: Icon(
                                        Icons.question_mark_rounded,
                                        size: 35,
                                        color: AppConstants.iconColour,
                                      ),
                                    ),
                                    Text(
                                      "Questions",
                                      style: TextStyle(
                                          color: AppConstants.iconColour,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ];
                }),
              ),
            ),
            SizedBox(height: 40, width: MediaQuery.of(context).size.width),
            SizedBox(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 8, 40, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Text('Services',
                            style: TextStyle(
                                fontSize: 16,
                                letterSpacing: 0.15,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.onSurfaceColour)))
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DocumentPage(),
                              )),
                          child: Container(
                            decoration: BoxDecoration(
                                color: AppConstants.secondaryColour,
                                borderRadius: BorderRadius.circular(10)),
                            height: 60,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 12, right: 12),
                                  child: Icon(
                                    Icons.description,
                                    size: 35,
                                    color: AppConstants.iconColour,
                                  ),
                                ),
                                Text(
                                  "Evaluation",
                                  style: TextStyle(
                                      color: AppConstants.iconColour,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                        height: 60,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EvaluationPage(),
                              )),
                          child: Container(
                            decoration: BoxDecoration(
                                color: AppConstants.secondaryColour,
                                borderRadius: BorderRadius.circular(10)),
                            height: 60,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 12, right: 12),
                                  child: Icon(
                                    Icons.check,
                                    size: 35,
                                    color: AppConstants.iconColour,
                                  ),
                                ),
                                Text(
                                  "Answered",
                                  style: TextStyle(
                                      color: AppConstants.iconColour,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 1,
                    height: 20,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChatPage(),
                                ));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: AppConstants.secondaryColour,
                                borderRadius: BorderRadius.circular(10)),
                            height: 60,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 12, right: 12),
                                  child: Icon(
                                    Icons.chat,
                                    size: 35,
                                    color: AppConstants.iconColour,
                                  ),
                                ),
                                Text(
                                  "ChatBot",
                                  style: TextStyle(
                                      color: AppConstants.iconColour,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                        height: 60,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PrelimsFlashPage(),
                                ));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: AppConstants.secondaryColour,
                                borderRadius: BorderRadius.circular(10)),
                            height: 60,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 12, right: 12),
                                  child: Icon(
                                    Icons.note_add,
                                    size: 35,
                                    color: AppConstants.iconColour,
                                  ),
                                ),
                                Text(
                                  "Notes",
                                  style: TextStyle(
                                      color: AppConstants.iconColour,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 1,
                    height: 20,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const QuestionsPage(),
                                ));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: AppConstants.secondaryColour,
                                borderRadius: BorderRadius.circular(10)),
                            height: 60,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 12, right: 12),
                                  child: Icon(
                                    Icons.question_mark_rounded,
                                    size: 35,
                                    color: AppConstants.iconColour,
                                  ),
                                ),
                                Text(
                                  "Questions",
                                  style: TextStyle(
                                      color: AppConstants.iconColour,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                        height: 60,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChoosePlans(),
                                ));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: AppConstants.secondaryColour,
                                borderRadius: BorderRadius.circular(10)),
                            height: 60,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 12, right: 12),
                                  child: Icon(
                                    Icons.workspace_premium,
                                    size: 35,
                                    color: AppConstants.iconColour,
                                  ),
                                ),
                                Text(
                                  "Premium",
                                  style: TextStyle(
                                      color: AppConstants.iconColour,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
        drawer: Drawer(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 300,
                      child: Image.asset(
                        "assets/images/logo.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async{
                      if(Provider.of<ConstantsProvider>(context).values.containsKey("feedback_link")){
                        final Uri url = Uri.parse(Provider.of<ConstantsProvider>(context).values['feedback_link']);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      }
                    },
                    child: Container(
                        padding: const EdgeInsets.all(15.0),
                        child: const Text("Feedback", style: TextStyle(fontSize: 16.0))),
                  ),
                  GestureDetector(
                    onTap: () async{
                      if(Provider.of<ConstantsProvider>(context).values.containsKey("privacy_policy_link")){
                        final Uri url = Uri.parse(Provider.of<ConstantsProvider>(context).values['privacy_policy_link']);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      }
                    },
                    child: Container(
                        padding: const EdgeInsets.all(15.0),
                        child: const Text("Privacy Policy", style: TextStyle(fontSize: 16.0))),
                  ),
                  GestureDetector(
                    onTap: () {
                      showAboutDialog(
                          context: context, applicationName: "CivilsGPT");
                    },
                    child:  Container(
                        padding:const EdgeInsets.all(15.0),
                        child: const Text("Licenses", style: TextStyle(fontSize: 16.0))),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet<void>(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (BuildContext bc) => Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: AppConstants.modelColor,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(40.0),
                                  topRight: Radius.circular(40.0)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  alignment: Alignment.topCenter,
                                  child: const Text(
                                    "About Us",
                                    style: TextStyle(
                                        fontSize: 20,),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minHeight: 100
                                  ),
                                  child: Container(

                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      Provider.of<ConstantsProvider>(context).values['about_us'] ?? '',
                                      style: const TextStyle(

                                          fontSize: 15),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ));
                    },
                    child: Container(
                        padding: const EdgeInsets.all(15.0),
                        child: const Text("About Us", style: TextStyle(fontSize: 16.0))),
                  ),
                  const SizedBox(height: 45),
                  const Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right : 16.0),
                        child: Icon(Icons.people, size: 28.0),
                      ),
                      Text("Contact Us:", style: TextStyle(fontSize: 20.0)),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if(Provider.of<ConstantsProvider>(context).values.containsKey("instagram_link"))
                      GestureDetector(
                        onTap: () async {
                          final Uri url = Uri.parse(Provider.of<ConstantsProvider>(context).values['instagram_link']);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Image.asset(
                            "assets/instagram.png",
                            height: 25.0,
                            width: 25.0,
                          ),
                        ),
                      ),
                      if(Provider.of<ConstantsProvider>(context).values.containsKey("mail_link"))
                      GestureDetector(
                        onTap: () async {
                          final Uri emailUri = Uri(
                            scheme: 'mailto',
                            path: Provider.of<ConstantsProvider>(context).values['mail_link'],
                          );
                          if (await canLaunchUrl(emailUri)) {
                            await launchUrl(emailUri);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Image.asset(
                            "assets/gmail.png",
                            height: 25.0,
                            width: 25.0,
                          ),
                        ),
                      ),
                      if(Provider.of<ConstantsProvider>(context).values.containsKey("twitter_link"))
                      GestureDetector(
                        onTap: () async {
                          final Uri twitterUrl = Uri.parse(Provider.of<ConstantsProvider>(context).values['twitter_link']);
                          if (await canLaunchUrl(twitterUrl)) {
                            await launchUrl(twitterUrl);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Image.asset(
                            "assets/twitter.png",
                            height: 25.0,
                            width: 25.0,
                          ),
                        ),
                      ),
                      if(Provider.of<ConstantsProvider>(context).values.containsKey("whatsapp_link"))
                      GestureDetector(
                        onTap: () async {
                          final Uri whatsappUrl = Uri.parse(Provider.of<ConstantsProvider>(context).values['whatsapp_link']);
                          if (await canLaunchUrl(whatsappUrl)) {
                            await launchUrl(whatsappUrl);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Image.asset(
                            "assets/whatsapp.png",
                            height: 25.0,
                            width: 25.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginPage()));
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 16.0),
                            child: Icon(Icons.logout),
                          ),
                          Text(
                            "Sign Out",
                            style: TextStyle( fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        )
      ),
    );
  }
}
