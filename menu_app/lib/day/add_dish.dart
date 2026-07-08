import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/gsheets_api.dart';

Future<void> showAddDishDialog(BuildContext context) async {
  // stuff to get access to inputs
  final TextEditingController foodName = TextEditingController();
  final TextEditingController from = TextEditingController();

  List<String> assignedPrefixes = [];
  List<String> carbs = ["bread", "roti", "rice", "quinoa", "parantha", "dimsums", "poha", "amaranth", "pulao"];
  List<String> nonveg = ["chicken", "fish", "mutton", "prawn", "egg", "omelette"];
  List<String> drinks = ["smoothie", "drink", "juice"];
  List<String> sweets = ["ice cream", "cream", "ice"];
  List<String> fruit = ["watermelon", "mango", "blueberry", "pear", "apple", "custard apple", "banana"];
  int maxNumber = 0;

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

  // as the function name suggests,
  autoFoodPrefixNumber(String prefix) {
    maxNumber = 0;
    // 1. Use your existing API function to get ONLY the foods matching this prefix
    // e.g., if prefix is "c", this returns only items containing "c01", "c02", etc.
    final matchedFoods = GoogleSheetsApi.getFoodOptionsByPrefix([prefix]);
    
    // 2. Find the highest number among those matching items
    for (var food in matchedFoods) {
      // Split the ID string in case it's a joined cell like "c01,nv02"
      List<String> individualIds = food.id.toLowerCase().split(',');

      for (String id in individualIds) {
        String cleanId = id.trim();
        
        if (cleanId.startsWith(prefix)) {
          // Strip out the prefix letters to get the pure number string
          String numericPart = cleanId.substring(prefix.length);
          int? currentNum = int.tryParse(numericPart);
          
          if (currentNum != null && currentNum > maxNumber) {
            maxNumber = currentNum;
          }
        }
      }
    }

    // 3. Return the next logical number in the sequence
    maxNumber += 1;
  }

  // as the function name suggests,
  autoFoodPrefixLetter() {
    String inputDish = foodName.text.toLowerCase(); // "chicken fried rice"
    // Split by spaces into individual words: ["chicken", "fried", "rice"]
    List<String> dishWords = inputDish.split(' '); 

    // Check for matches
    for (String word in dishWords) {
      if (carbs.contains(word) && !assignedPrefixes.contains("c")) {
        autoFoodPrefixNumber("c");
        assignedPrefixes.add("c$maxNumber");
      }
      if (nonveg.contains(word) && !assignedPrefixes.contains("nv")) {
        autoFoodPrefixNumber("nv");
        assignedPrefixes.add("nv$maxNumber");
      }
      if (drinks.contains(word) && !assignedPrefixes.contains("d")) {
        autoFoodPrefixNumber("d");
        assignedPrefixes.add("d$maxNumber");
      }
      if (sweets.contains(word) && !assignedPrefixes.contains("s")) {
        autoFoodPrefixNumber("s");
        assignedPrefixes.add("s$maxNumber");
      }
      if (fruit.contains(word) && !assignedPrefixes.contains("f")) {
        autoFoodPrefixNumber("f");
        assignedPrefixes.add("f$maxNumber");
      }
    }

    // If it doesn't match anything, give it a default prefix (e.g., "v" for veg / general)
    if (assignedPrefixes.isEmpty) {
      autoFoodPrefixNumber("v"); 
      assignedPrefixes.add("v$maxNumber");
    }
  }

  // things that happen when you tap enter
  void tapEnter() {
    HapticFeedback.lightImpact();
                            
    // if (foodName.text.trim().isEmpty || from.text.trim().isEmpty) {
    if (foodName.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all required fields")));
    } else {

      Navigator.of(context).pop();
      autoFoodPrefixLetter();

      // enter food item
      GoogleSheetsApi.addFoodItem(
        assignedPrefixes,
        foodName.text,
        "please add this soon",
      );

      // clear text fields
      foodName.clear();
      from.clear();
      assignedPrefixes.clear();
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
              color: const Color(0xFF2b2b2b),
              border: Border.all(color: accent),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                    
                Text(
                  "New Food Item",
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
                        controller: foodName,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(color: Colors.white),
                        decoration: buildInputDecoration("Name"),
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(two);
                        },
                      ),
                    
                      SizedBox(height: 15),
                    
                      TextFormField(
                        focusNode: two,
                        controller: from,
                        style: TextStyle(color: Colors.white),
                        decoration: buildInputDecoration("Ingredients"),
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
                      
                            foodName.clear();
                            from.clear();
                          },
                          splashColor: Colors.white12,
                          highlightColor: Colors.white10,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            alignment: Alignment.center,
                            child: const Text(
                              "Cancel",
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
                              "Add",
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
