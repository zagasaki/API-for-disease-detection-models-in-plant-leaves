import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'prediction_result.dart';

class ImageUploader extends StatefulWidget {
  const ImageUploader({super.key});

  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  File? _image;
  final picker = ImagePicker();

  // Fungsi untuk memilih gambar
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Fungsi untuk mengirim gambar ke API dan navigasi ke halaman hasil prediksi
  Future<void> uploadImage() async {
    if (_image == null) return;

    final uri = Uri.parse(
        'https://unique-prosperity-production.up.railway.app/predict');
    var request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final jsonResponse = json.decode(respStr);

      // Mengambil hasil prediksi
      final predictionResult = jsonResponse['class'];
      final confidence = jsonResponse['confidence'];

      // Navigasi ke halaman PredictionResult
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PredictionResult(
            prediction: predictionResult,
            confidence: confidence,
          ),
        ),
      );
    } else {
      print('Failed to upload image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Image to API')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? const Text('No image selected.')
                : Image.file(_image!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: uploadImage,
              child: const Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
