import 'dart:io';
import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';

import '../../../services/http_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../models/poster.dart';

class PosterProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addPosterFormKey = GlobalKey<FormState>();
  TextEditingController posterNameCtrl = TextEditingController();
  Poster? posterForUpdate;


  File? selectedImage;
  XFile? imgXFile;


  PosterProvider(this._dataProvider);

  //TODO: should complete addPoster
  void addPoster() async{
    try{
      if(selectedImage==null){
        SnackBarHelper.showErrorSnackBar("Please choose an image!");  //like a toast
        return;
      }
      Map<String, dynamic> formDataMap = {
        'posterName' : posterNameCtrl.text,
        'image' : 'no_data' //image path will be added from the server side
      };

      final FormData form = await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final response = await service.addItem(endpointUrl: 'posters', itemData: form);  //send a post request to the server
      if(response.isOk){
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);  //The response body is parsed into an ApiResponse object 
        if(apiResponse.success==true){
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          _dataProvider.getAllPosters();
          print('poster added');
        }
        else{
          SnackBarHelper.showErrorSnackBar("Failed to add poster: ${apiResponse.message}");
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


  //TODO: should complete updatePoster
  void updatePoster() async{
    try{
      Map<String, dynamic> formDataMap = {
        'posterName' : posterNameCtrl.text,
        'image' : posterForUpdate?.imageUrl ?? '',
      };

      final FormData form = await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final response = await service.updateItem(endpointUrl: 'posters', 
                          itemId: posterForUpdate?.sId ?? '', itemData: form);
      if(response.isOk){
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if(apiResponse.success==true){
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          print("poster updated");
          _dataProvider.getAllPosters();
        }
        else{
          SnackBarHelper.showErrorSnackBar('Failed to add poster: ${apiResponse.message}');
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


  //TODO: should complete submitPoster
  void submitPoster(){
    if(posterForUpdate != null){
      updatePoster();
    }
    else{
      addPoster();
    }
  }




  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      imgXFile = image;
      notifyListeners();
    }
  }


  //TODO: should complete deletePoster
  void deletePoster(Poster poster) async{
    try{
      Response response = await service.deleteItem(endpointUrl: 'posters', itemId: poster.sId ?? '');
      if(response.isOk){
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if(apiResponse.success==true){
          SnackBarHelper.showSuccessSnackBar('Poster deleted successfully');
          _dataProvider.getAllPosters();
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



  setDataForUpdatePoster(Poster? poster) {
    if (poster != null) {
      clearFields();
      posterForUpdate = poster;
      posterNameCtrl.text = poster.posterName ?? '';
    } else {
      clearFields();
    }
  }

  Future<FormData> createFormData({required XFile? imgXFile, required Map<String, dynamic> formData}) async {
    if (imgXFile != null) {
      MultipartFile multipartFile;
      if (kIsWeb) {
        String fileName = imgXFile.name;
        Uint8List byteImg = await imgXFile.readAsBytes();
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

  clearFields() {
    posterNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    posterForUpdate = null;
  }
}
