import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:solveasy/homepage_view/crop_overlay.dart';
import 'package:solveasy/homepage_view/drawer_menu.dart';
import '../preview.dart';


class MainPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const MainPage({Key? key, required this.cameras}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late CameraController cameraController;
  late Future<void> cameraValue;
  bool isFlashOn = false;
  late Rect _cropRect;

  final double cropPadding = 16.0;

  @override
  void initState() {
    super.initState();
    startCamera(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        double cropWidth = screenSize.width - cropPadding * 2.5;
        double cropHeight = 160;
        double verticalOffset = screenSize.height * 0.35;
        _cropRect = Rect.fromCenter(
          center: Offset(screenSize.width / 2, verticalOffset),
          width: cropWidth,
          height: cropHeight,
        );
      });
    });
  }

  void startCamera(int camera) {
    cameraController = CameraController(
      widget.cameras[camera],
      ResolutionPreset.high,
      enableAudio: false,
    );
    cameraValue = cameraController.initialize();
  }

  void takePicture() async {
    if (cameraController.value.isTakingPicture || !cameraController.value.isInitialized) {
      return;
    }

    await cameraController.setFlashMode(isFlashOn ? FlashMode.torch : FlashMode.off);

    if (cameraController.value.flashMode == FlashMode.torch) {
      setState(() {
        cameraController.setFlashMode(FlashMode.off);
      });
    }

    XFile image = await cameraController.takePicture();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewPage(image: image, cropRect: _cropRect),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double topPadding = size.height * 0.10;

    return Scaffold(
      drawer: DrawerMenu(),
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Builder(
              builder: (context) => Padding(
                padding: EdgeInsets.fromLTRB(16.0, topPadding + 16, 0, 0),
                child: FloatingActionButton(
                  backgroundColor: Colors.black.withOpacity(0.1),
                  elevation: 0,
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  shape: const CircleBorder(),
                  child: const Icon(Icons.menu, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, topPadding + 16, 0, 32),
              child: FloatingActionButton(
                backgroundColor: Colors.black12.withOpacity(0.05),
                elevation: 0,
                onPressed: () {},
                shape: const CircleBorder(),
                child: Image.asset('assets/images/solvy_avatar.png'),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: 70.0,
              height: 70.0,
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: takePicture,
                shape: const CircleBorder(
                  side: BorderSide(color: Colors.white, width: 5.0),
                ),
                child: null,
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          FutureBuilder(
            future: cameraValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  width: size.width,
                  height: size.height,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 100,
                      child: CameraPreview(cameraController),
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          CropOverlay(cropRect: _cropRect),
          Positioned(
            top: _cropRect.bottom + 20,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Take the picture of a question',
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}