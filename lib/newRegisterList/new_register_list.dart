import 'package:flutter/material.dart';

import '../model/user.dart';

class NewRegisterList extends StatefulWidget {
  const NewRegisterList({super.key});

  @override
  State<NewRegisterList> createState() => _NewRegisterListState();
}

class _NewRegisterListState extends State<NewRegisterList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Register>>(
      stream: CloudRegister().getNewRegisters(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Register> registerList = snapshot.data!;
          registerList.sort((a, b) => a.regdate.compareTo(b.regdate)); // Sort the list in ascending order of regdate
          return ListView.builder(
            itemCount: registerList.length,
            itemBuilder: (context, index) {
              Register register = registerList[index];
              return Card(
                child: ListTile(
                  leading: Text('${index + 1}'), // Display the order in the leading section
                  title: Text(register.name),
                  subtitle: Text(register.regdate.toString()),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const SizedBox.shrink(); // Hide the progress bar by default
        }
      },
    );
  }
  
}