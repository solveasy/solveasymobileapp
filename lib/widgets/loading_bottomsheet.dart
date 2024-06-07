import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:lottie/lottie.dart';

class LoadingBottomSheet {
  static void show({
    required BuildContext context,
    required DraggableScrollableController controller,
    Timer? delayedTimer,
  }) {
    bool additionalTextVisible = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: true,
          controller: controller,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                // Reference the state which created the StatefulBuilder
                final bool isMounted = ModalRoute.of(context)?.isCurrent ?? true;

                delayedTimer = Timer(const Duration(seconds: 3), () {
                  if (isMounted) {
                    setState(() {
                      additionalTextVisible = true;
                    });
                  }
                });

                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Color(0xffdcb340),
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Understanding the question..',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Comfortaa',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        AnimatedSwitcher(
                          duration: const Duration(microseconds: 1),
                          child: additionalTextVisible
                              ? Column(
                            key: const ValueKey<int>(2),
                            children: [
                              FadeIn(
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 24,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Solveasy answering your question!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Lottie.asset(
                                'assets/animations/solvy_loading.json',
                                width: 275,
                                height: 275,
                              ),
                            ],
                          )
                              : Lottie.asset(
                            'assets/animations/solvy_loading_2.json',
                            key: const ValueKey<int>(1),
                            width: 275,
                            height: 275,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}