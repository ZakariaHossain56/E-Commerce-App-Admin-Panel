import 'dart:io';
import 'dart:math';
import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/material.dart';

import '../../../services/http_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addCategoryFormKey = GlobalKey<FormState>();  //GlobalKey provides direct access to the FormState without needing the context. FormState provides methods like validate(), save(), reset()
  TextEditingController categoryNameCtrl = TextEditingController();
  Category? categoryForUpdate;


  File? selectedImage;
  XFile? imgXFile;  //for picking image or video from the gallery or camera.


  CategoryProvider(this._dataProvider);

  //TODO: should complete addCategory
  void addCategory() async{
    try{
      if(selectedImage==null){
        SnackBarHelper.showErrorSnackBar("Please choose an image!");  //like a toast
        return;
      }
      Map<String, dynamic> formDataMap = {
        'name' : categoryNameCtrl.text,
        'image' : 'no_data' //image path will be added from the server side
      };

      final FormData form = await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final response = await service.addItem(endpointUrl: 'categories', itemData: form);  //send a post request to the server
      if(response.isOk){
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);  //The response body is parsed into an ApiResponse object 
        if(apiResponse.success==true){
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          _dataProvider.getAllCategory();
          print('category added');
        }
        else{
          SnackBarHelper.showErrorSnackBar("Failed to add category: ${apiResponse.message}");
        }
      }
      else{
        SnackBarHelper.showErrorSnackBar("Error ${response.body?['message'] ?? response.statusText}");
      }
    }
    catch(e){
      print(e);
      SnackBarHelper.showErrorSnackBar("An error occurred: $e");
      rethrow;  //rethrow is used to send the error back up to the function or method that called addCategory for further processing if needed
    }
  }

  //TODO: should complete updateCategory
  void updateCategory() async{
    try{
      Map<String, dynamic> formDataMap = {
        'name' : categoryNameCtrl.text,
        'image' : categoryForUpdate?.image ?? '',
      };

      final FormData form = await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final response = await service.updateItem(endpointUrl: 'categories', itemId: categoryForUpdate?.sId ?? '', itemData: form);
      if(response.isOk){
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if(apiResponse.success==true){
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          print("category added");
          _dataProvider.getAllCategory();
        }
        else{
          SnackBarHelper.showErrorSnackBar('Failed to add category: ${apiResponse.message}');
        }
      }
      else{
        SnackBarHelper.showErrorSnackBar("Error ${response.body?['message'] ?? response.statusCode}");
      }
    }
    catch(e){
      print(e);
      SnackBarHelper.showErrorSnackBar('An error occured $e');
      rethrow;
    }
  }

  //TODO: should complete submitCategory
  void submitCategory(){
    if(categoryForUpdate!=null){
      updateCategory();
    }
    else{
      addCategory();
    }
  }


  

  //TODO: should complete deleteCategory
  void deleteCategory(Category category) async{
    try{
      Response response = await service.deleteItem(endpointUrl: 'categories', itemId: category.sId ?? '');
      if(response.isOk){
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if(apiResponse.success==true){
          SnackBarHelper.showSuccessSnackBar('Category deleted successfully');
          _dataProvider.getAllCategory();
        }
      }
      else{
        SnackBarHelper.showErrorSnackBar('Error ${response.body?['message'] ?? response.statusText}');
      }
    }
    catch(e){
      print(e);
      rethrow;
    }
  }





  //? to create form data for sending image with body
  Future<FormData> createFormData({required XFile? imgXFile, required Map<String, dynamic> formData}) async {
    if (imgXFile != null) {
      MultipartFile multipartFile;
      if (kIsWeb) { //A constant that checks if the app is running on the web.
        String fileName = imgXFile.name;
        Uint8List byteImg = await imgXFile.readAsBytes(); //read the file as bytes(raw binary data of the file) On web platforms, you cannot directly use a file path like on mobile or desktop.
                                                          //Instead, the file must be read as binary data (Uint8List) to prepare it for upload.
        multipartFile = MultipartFile(byteImg, filename: fileName);
      } else {  
        String fileName = imgXFile.path.split('/').last;
        multipartFile = MultipartFile(imgXFile.path, filename: fileName);
      }
      formData['img'] = multipartFile;
    }
    final FormData form = FormData(formData);
    return form;
  }

  //TODO: should complete setDataForUpdateCategory
  setDataForUpdateCategory(Category? category) {
    if (category != null) {
      clearFields();
      categoryForUpdate = category;
      categoryNameCtrl.text = category.name ?? '';
    } else {
      clearFields();
    }
  }

  //image picker
  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path); //Converts the XFile object to a File object for compatibility with APIs or widgets
      imgXFile = image;
      notifyListeners();
    }
  }

  //? to clear text field and images after adding or update category
  clearFields() {
    categoryNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    categoryForUpdate = null;
  }
}
