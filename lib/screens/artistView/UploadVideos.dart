import 'dart:io';

import 'package:artsphere/controller/artist/artistVideoController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class UploadVideoPage extends StatefulWidget {
  @override
  _UploadVideoPageState createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  final ArtistVideoController controller = Get.put(ArtistVideoController());
  final titleController = TextEditingController();
  final descController = TextEditingController();

  XFile? thumbnailFile;
  File? videoFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Video')),
      body: SingleChildScrollView(
        child: Obx(
          () =>
              controller.isLoading.value
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(labelText: 'Title'),
                        ),
                        TextField(
                          controller: descController,
                          decoration: InputDecoration(labelText: 'Description'),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final picked = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                            );
                            if (picked != null)
                              setState(() => thumbnailFile = picked);
                          },
                          child: Text(
                            thumbnailFile == null
                                ? 'Pick Thumbnail'
                                : 'Thumbnail Selected',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.video,
                            );
                            if (result != null)
                              setState(
                                () => videoFile = File(result.files.single.path!),
                              );
                          },
                          child: Text(
                            videoFile == null ? 'Pick Video' : 'Video Selected',
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (thumbnailFile == null || videoFile == null) {
                              Get.snackbar(
                                'Error',
                                'Please select both thumbnail and video',
                              );
                              return;
                            }
                            if (titleController.text.isEmpty ||
                                descController.text.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Please enter title and description',
                              );
                              return;
                            }
        
                            await controller.uploadVideo(
                              title: titleController.text,
                              description: descController.text,
                              thumbnail: thumbnailFile!,
                              videoFile: videoFile!,
                            );
        
                            // Clear form after upload
                            if (!controller.isLoading.value) {
                              titleController.clear();
                              descController.clear();
                              setState(() {
                                thumbnailFile = null;
                                videoFile = null;
                              });
                            }
                          },
                          child: Text('Upload'),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
