import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_app/constants/colours.dart';

Future<void> showAddFundsDialog(BuildContext context) async {
  // stuff to get access to inputs
  final TextEditingController amount = TextEditingController();
  final TextEditingController from = TextEditingController();

  // focus nodes for text fields to go from one to two
  final FocusNode one = FocusNode();
  final FocusNode two = FocusNode();

  // formatting text fields 
  InputDecoration buildInputDecoration(String hintText) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: fadedGrey),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
      hintText: hintText,
      hintStyle: TextStyle(color: fadedGrey),
    );
  }

  // things that happen when you tap enter
  void tapEnter() {
    HapticFeedback.lightImpact();
                            
    if (amount.text.trim().isEmpty || from.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all required fields")));
    } else {

      Navigator.of(context).pop();  
      

      // clear text fields
      amount.clear();
      from.clear();
    }
  }

  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Container(
            decoration: BoxDecoration(
              color: mainBg,
              border: Border.all(color: fundGreen),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                    
                Text(
                  "Add Funds",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textHeightBehavior: TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                ),
                    
                SizedBox(height: 20),
                    
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      TextFormField(
                        autofocus: true,
                        focusNode: one,
                        controller: amount,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(color: Colors.white),
                        decoration: buildInputDecoration("Amount"),
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(two);
                        },
                      ),
                    
                      SizedBox(height: 15),
                    
                      TextFormField(
                        focusNode: two,
                        controller: from,
                        style: TextStyle(color: Colors.white),
                        decoration: buildInputDecoration("From"),
                        onFieldSubmitted: (value) {                            
                          tapEnter();
                        },
                      ),
                    ],
                  ),
                ),
                    
                SizedBox(height: 25),
                    
                Divider(height: 2, color: fadedGrey),
                    
                Row(
                  children: [

                    // close button
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                      
                            amount.clear();
                            from.clear();
                          },
                          splashColor: Colors.white12,
                          highlightColor: Colors.white10,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            alignment: Alignment.center,
                            child: const Text(
                              "Close",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    Container(width: 1, height: 57, color: fadedGrey),

                    // enter button
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            tapEnter();
                          },
                          splashColor: Colors.white12,
                          highlightColor: Colors.white10,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            alignment: Alignment.center,
                            child: const Text(
                              "Enter",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
