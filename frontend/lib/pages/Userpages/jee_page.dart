import 'package:flutter/material.dart';
import 'upload_pdf_page.dart'; // Import the Upload Files page

class JeePage extends StatelessWidget {
  const JeePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    itemCount:
                        const [
                          "Aadhar card",
                          "Inter Memo",
                          "TC",
                          "Study Certificates (6th - 12th)",
                          "Bonafide",
                          "10th memo",
                          "JEE hall ticket",
                          "JEE percentile document",
                        ].length,
                    separatorBuilder:
                        (context, index) => const Divider(
                          color: Colors.grey,
                          indent: 10,
                          endIndent: 10,
                        ),
                    itemBuilder: (context, index) {
                      return Padding(
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
                                "• ${const ["Aadhar card", "Inter Memo", "TC", "Study Certificates (6th - 12th)", "Bonafide", "10th memo", "Income Certificate", "Eamcet hall ticket", "Eamcet Rank document"][index]}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
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
