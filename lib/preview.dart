import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:chiclet/chiclet.dart';
import 'package:flutter/material.dart';
import 'package:solveasy/api/api%20services.dart';
import 'package:solveasy/homepage_view/crop_overlay.dart';
import 'package:solveasy/widgets/loading_bottomsheet.dart';
import 'package:solveasy/widgets/no_question_bottomsheet.dart';
import 'package:solveasy/widgets/response_bottomsheet.dart';

import 'widgets/cropper.dart';
import 'widgets/scan_animation.dart';



class PreviewPage extends StatefulWidget {

  final XFile image;

  final Rect cropRect;



  const PreviewPage({Key? key, required this.image, required this.cropRect}) : super(key: key);



  @override

  _PreviewPageState createState() => _PreviewPageState();

}



class _PreviewPageState extends State<PreviewPage> {

  final GlobalKey<CropperState> _cropKey = GlobalKey<CropperState>();

  late Rect _cropRect;

  bool _isScanning = false;


  String _responseContent = '';

  Timer? _delayedTimer;

  DraggableScrollableController _draggableScrollableController = DraggableScrollableController();



  @override

  void initState() {

    super.initState();

    _cropRect = widget.cropRect;

  }



  void _showBottomSheetWithResponse(String question) {

    _draggableScrollableController = DraggableScrollableController();



    ResponseBottomSheet.show(

      context: context,

      controller: _draggableScrollableController,

      responseContent: _responseContent,

      question: question,

      cropRect: _cropRect,

    );

  }



  void _showLoadingBottomSheet() {

    LoadingBottomSheet.show(

        context: context,

        controller: _draggableScrollableController,

        delayedTimer: _delayedTimer

    );

  }



  void _showNoQuestionBottomSheet() {

    if (Navigator.of(context).canPop()) {

      Navigator.of(context).pop();

    }



    NoQuestionBottomSheet.show(

        context: context,

        controller: _draggableScrollableController

    );

  }



  Future<void> _uploadImageAndFetchResponse(String imageFilePath) async {

    // Implement the _uploadImageAndFetchResponse method in the service

    File croppedImage = await _cropKey.currentState!.cropImage();

    await ApiService.uploadImageAndFetchResponse(croppedImage, _sendImageToMathpix);

  }



  Future<void> _sendImageToMathpix(String imageUrl) async {

    final extractedText = await ApiService.sendImageToMathpix(imageUrl, _showNoQuestionBottomSheet);

    if (extractedText != null) {

      await _sendTextToConversationApi(extractedText);

    }

  }



  Future<void> _sendTextToConversationApi(String message) async {

    final responseContent = await ApiService.sendTextToConversationApi(message);



    if (responseContent != null) {

      setState(() {

        _responseContent = responseContent;


      });



      if (mounted) {

        Navigator.pop(context);

        _showBottomSheetWithResponse(message);

      }

    }

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      body: Stack(

        children: [

          Cropper(

            key: _cropKey,

            imagePath: widget.image.path,

            initialCropRect: _cropRect,

            onCropRectChanged: (rect) {

              setState(() {

                _cropRect = rect;

              });

            },

          ),

          CropOverlay(cropRect: _cropRect),

          if (_isScanning) ScanningAnimation(cropRect: _cropRect),

          Positioned(

            top: 50,

            left: 20,

            child: GestureDetector(

              onTap: () {

                Navigator.pop(context);

              },

              child: const CircleAvatar(

                radius: 20,

                backgroundColor: Colors.black12,

                child: Icon(Icons.close_outlined, color: Colors.white),

              ),

            ),

          ),

          Positioned(

            bottom: 32,

            left: 0,

            right: 0,

            child: Center(

              child: ChicletAnimatedButton(

                backgroundColor: Colors.redAccent.shade200,

                buttonColor: Colors.red.shade900,

                onPressed: () async {

                  setState(() {

                    _isScanning = true;

                  });

                  _uploadImageAndFetchResponse(widget.image.path);

                  await Future.delayed(const Duration(seconds: 1));

                  if (mounted) {

                    setState(() {

                      _isScanning = false;


                    });

                    _showLoadingBottomSheet();

                  }

                },

                height: 70,

                width: 70,

                buttonType: ChicletButtonTypes.circle,

                child: const Icon(Icons.send, color: Colors.white, size: 40),

              ),

            ),

          ),

        ],

      ),

    );

  }

}



