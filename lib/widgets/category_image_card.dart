import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CategoryImageCard extends StatelessWidget {
  final String labelText;
  final String? imageUrlForUpdateImage;
  final File? imageFile;
  final VoidCallback onTap;

  const CategoryImageCard({
    super.key,
    required this.labelText,
    this.imageFile,
    required this.onTap,
    this.imageUrlForUpdateImage,
  });

  @override
  Widget build(BuildContext context) {
    print(imageFile);
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          height: 130,
          width: size.width * 0.12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (imageFile != null)  //display an image file if it exists
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: kIsWeb
                      ? Image.network(  //for web
                          imageFile?.path ?? '',  //usually a URL for web images
                          width: double.infinity, // The image spans the full width of its parent
                          height: 80,
                          fit: BoxFit.cover,  //Scales the image to cover the given space, cropping if necessary.
                        )
                      : Image.file( //for non-web
                          imageFile!,
                          width: double.infinity,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                )
              else if ( imageUrlForUpdateImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrlForUpdateImage ?? '',
                    width: double.infinity,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                )
              else  //display a camera icon when no image is available
                Icon(Icons.camera_alt, size: 50, color: Colors.grey[600]),
              SizedBox(height: 8),
              Text(
                labelText,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
