import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:secpucp/model/menu_item.dart';
import 'package:secpucp/screens/profile.dart';
import 'package:secpucp/screens/welcome.dart';

class menuItems {
  static const items = [itemProfile, itemSignout];
  static const itemProfile = menuItem(text: "Perfil", icon: Icons.person);
  static const itemSignout =
      menuItem(text: "Cerrar Sesión", icon: Icons.exit_to_app);
}

Image logoWidget(String imageName, double w, double h) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: w,
    height: h,
  );
}

TextField reusableTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller, bool _validate, String error) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.white,
    decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color.fromARGB(255, 0, 90, 141)),
        labelText: text,
        labelStyle: TextStyle(color: Color.fromARGB(255, 0, 90, 141)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(width: 0, style: BorderStyle.none))),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

AppBar secPUCPAppbar2(BuildContext context) {
  return AppBar(
    backgroundColor: Color.fromARGB(252, 0, 32, 71),
    elevation: 0,
    title: logoWidget("assets/images/secpucpLogo.png", 60, 60),
    centerTitle: true,
    actions: [
      PopupMenuButton<menuItem>(
        onSelected: (item) => seleccionarOpcion(context, item),
        itemBuilder: (context) => [...menuItems.items.map(buildItem).toList()],
      ),
    ],
  );
}

AppBar secPUCPAppbar(BuildContext context) {
  return AppBar(
    backgroundColor: Color.fromARGB(252, 0, 32, 71),
    elevation: 0,
    title: logoWidget("assets/images/secpucpLogo.png", 60, 60),
    centerTitle: true,
    automaticallyImplyLeading: false,
    actions: [
      PopupMenuButton<menuItem>(
        onSelected: (item) => seleccionarOpcion(context, item),
        itemBuilder: (context) => [...menuItems.items.map(buildItem).toList()],
      ),
    ],
  );
}

PopupMenuItem<menuItem> buildItem(menuItem item) => PopupMenuItem<menuItem>(
    value: item,
    child: Row(
      children: [
        Icon(item.icon, color: Colors.black, size: 20),
        const SizedBox(width: 12),
        Text(item.text)
      ],
    ));
void seleccionarOpcion(BuildContext context, menuItem item) {
  switch (item) {
    case menuItems.itemSignout:
      FirebaseAuth.instance.signOut().then((value) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
      });
      break;
    case menuItems.itemProfile:
      String profileKey = FirebaseAuth.instance.currentUser!.uid;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Profile(
                    profileKey: profileKey,
                  )));
      break;
  }
}
