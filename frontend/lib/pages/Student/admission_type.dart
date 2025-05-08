class AdmissionTypePage extends StatelessWidget {
  final List<String> admissionTypes = [
    'TG-CET', 'Management', 'JEE', 'NRI'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Admission Type')),
      body: ListView.builder(
        itemCount: admissionTypes.length,
        itemBuilder: (ctx, index) => Card(
          child: ListTile(
            title: Text(admissionTypes[index]),
            onTap: () => Navigator.pushNamed(
              context, 
              '/document-upload',
              arguments: admissionTypes[index]
            ),
          ),
        ),
      ),
    );
  }
}