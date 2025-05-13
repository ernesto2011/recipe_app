import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:recipe_app/sreens/recipe_detail.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<List<dynamic>> getRecipes() async {
    final url = Uri.parse('http://10.0.2.2:3003/recipes');
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    return data['recipes'];
  }
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
      future: getRecipes(), 
      builder: (context, snapshot){
        final recipes = snapshot.data;
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: recipes!.length,
          itemBuilder:(context, index){
            return _RecipesCard(context, recipes[index]);
          }

        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBotton(context);
        },
        backgroundColor: Colors.teal[300],
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }

  Future<void> _showBotton(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => SizedBox(
            height: 550,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(8),
              child: RecipeForm(),
            ),
          ),
          ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _RecipesCard(BuildContext context, dynamic recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> RecipeDetail(recipeName: recipe['name'])));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 125,
          child: Card(
            child: Row(
              children: <Widget>[
                SizedBox(
                  height: 125,
                  width: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      recipe['image_link'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace){
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(Icons.error, color: Colors.red),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 26),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      recipe['name'],
                      style: TextStyle(fontSize: 16, fontFamily: 'Quicksand'),
                    ),
                    Container(height: 2, width: 75, color: Colors.teal[300]),
                    SizedBox(height: 4),
                    Text(
                      recipe['author'],
                      style: TextStyle(fontSize: 12, fontFamily: 'Quicksand'),
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RecipeForm extends StatelessWidget {
  const RecipeForm({super.key});
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController instructionsController =
        TextEditingController();
    final TextEditingController imageURLController = TextEditingController();
    final TextEditingController authorController = TextEditingController();
    return Padding(
      padding: EdgeInsets.all(8),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add new recipe',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
                color: Colors.teal[300],
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: nameController,
              label: 'Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a recipe name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              maxLines: 4,
              controller: instructionsController,
              label: 'Instructions',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter instructions';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: imageURLController,
              label: 'Image URL',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an image URL';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: authorController,
              label: 'Author',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an author name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: (){
                  if(formKey.currentState!.validate()){
                  Navigator.pop(context);
                }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Add Recipe',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Quicksand',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontFamily: 'Quicksand', color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal[300]!, width: 1),
        ),
      ),
      controller: controller,
      validator: validator,
      maxLines: maxLines,
    );
  }
}
