import 'package:flutter/material.dart';
import 'upload_pdf_page.dart';
import 'upload_pages/aadhar_page.dart';
import 'upload_pages/bonafide_page.dart';
import 'upload_pages/inter_memo_page.dart';
import 'upload_pages/jee_hall_ticket_page.dart';
import 'upload_pages/jee_percentile_page.dart';
import 'upload_pages/study_certificates_page.dart';
import 'upload_pages/tc_page.dart';
import 'upload_pages/tenth_memo_page.dart';

class JeePage extends StatelessWidget {
  const JeePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> jeeDocuments = [
      {"title": "Aadhar card", "page": const AadharPage()},
      {"title": "Inter Memo", "page": const InterMemoPage()},
      {"title": "TC", "page": const TCPage()},
      {"title": "Study Certificates (6th - 12th)", "page": const StudyCertificatesPage()},
      {"title": "Bonafide", "page": const BonafidePage()},
      {"title": "10th memo", "page": const TenthMemoPage()},
      {"title": "JEE hall ticket", "page": const JeeHallTicketPage()},
      {"title": "JEE percentile document", "page": const JeePercentilePage()},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "JEE Documents",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlue.shade50, Colors.white],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Required Documents for JEE:",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.lightBlue.shade800,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.separated(
                    itemCount: jeeDocuments.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.grey,
                      indent: 10,
                      endIndent: 10,
                    ),
                    itemBuilder: (context, index) {
                      final doc = jeeDocuments[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => doc["page"]),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.description_outlined,
                                color: Colors.lightBlueAccent,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "• ${doc["title"]}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PDFPickerScreen()),
                  );
                },
                icon: const Icon(Icons.upload_file, color: Colors.white),
                label: const Text(
                  "Upload JEE Files",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
