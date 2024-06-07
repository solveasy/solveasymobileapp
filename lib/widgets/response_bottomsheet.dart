import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:solveasy/utils/response_utils.dart';

class ResponseBottomSheet {
  static void show({
    required BuildContext context,
    required DraggableScrollableController controller,
    required String responseContent,
    required String question,
    required Rect cropRect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.95,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          controller: controller,
          builder: (context, scrollController) {
            final screenWidth = MediaQuery.of(context).size.width;
            String finalAnswer = ResponseUtils.extractFinalAnswer(responseContent);
            String processedResponse = ResponseUtils.processResponseAndRemoveFinalAnswer(responseContent, finalAnswer);
            ProcessedQuestion processedQuestion = ResponseUtils.processQuestionText(question);

            return Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _titleSection(Icons.question_mark_outlined, 'You:', Colors.indigoAccent),
                      const SizedBox(height: 10),
                      _questionContainer(screenWidth, processedQuestion.questionText, processedQuestion.options),
                      const SizedBox(height: 20),
                      _titleSection(Icons.lightbulb_outline, 'Solution:', Colors.orangeAccent),
                      const SizedBox(height: 10),
                      _textContainer(screenWidth, processedResponse),
                      const SizedBox(height: 20),
                      if (finalAnswer.isNotEmpty)
                        Container(
                          width: screenWidth,
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(13)),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            child: TeXView(
                              renderingEngine: const TeXViewRenderingEngine.mathjax(),
                              child: TeXViewDocument(
                                finalAnswer,
                                style: const TeXViewStyle.fromCSS("font-family: 'Comfortaa'; font-size: 18px; color: #ffffff;"),
                              ),
                              style: const TeXViewStyle(borderRadius: TeXViewBorderRadius.all(10)),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _titleSection(IconData icon, String text, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Comfortaa',
            ),
          ),
        ),
      ],
    );
  }

  static Widget _textContainer(double width, String text) {
    final comfortaaCss = "font-family: 'Comfortaa'; font-size: 18px; color: #333333;";
    return Container(
      width: width,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(width: 3, color: Colors.white70),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TeXView(
          renderingEngine: const TeXViewRenderingEngine.mathjax(),
          child: TeXViewDocument(
            text,
            style: TeXViewStyle.fromCSS(comfortaaCss),
          ),
          style: const TeXViewStyle(
            borderRadius: TeXViewBorderRadius.all(10),
          ),
        ),
      ),
    );
  }

  static Widget _questionContainer(double width, String questionText, List<String> options) {
    final comfortaaCss = "font-family: 'Comfortaa'; font-size: 18px; color: #333333;";
    final processedQuestionText = convertTabularToHtml(questionText);

    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(width: 3, color: Colors.white70),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeXView(
            renderingEngine: const TeXViewRenderingEngine.mathjax(),
            child: TeXViewDocument(
              processedQuestionText,
              style: TeXViewStyle.fromCSS(comfortaaCss),
            ),
            style: const TeXViewStyle(
              borderRadius: TeXViewBorderRadius.all(10),
            ),
          ),
          if (options.isNotEmpty)
            ExpansionTile(
              title: const Text(
                'Multiple Choice',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontFamily: 'Comfortaa',
                  fontWeight: FontWeight.w500,
                ),
              ),
              children: options.map((option) {
                final formattedOption = r'$$' + option + r'$$';
                return Container(
                  padding: const EdgeInsets.all(4),
                  child: TeXView(
                    renderingEngine: const TeXViewRenderingEngine.mathjax(),
                    child: TeXViewDocument(
                      formattedOption,
                      style: TeXViewStyle.fromCSS(comfortaaCss),
                    ),
                    style: const TeXViewStyle(
                      borderRadius: TeXViewBorderRadius.all(10),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  static String convertTabularToHtml(String tex) {
    String html = tex;
    html = html.replaceAllMapped(RegExp(r'\\begin{tabular}{\|l\|l\|}'), (match) => "<table style=\"width: 100%; border-collapse: collapse;\">");
    html = html.replaceAllMapped(RegExp(r'\\end{tabular}'), (match) => "</table>");
    html = html.replaceAllMapped(RegExp(r'\\hline'), (match) => "<en>");
    html = html.replaceAllMapped(RegExp(r'\\\\'), (match) => "</en>");
    html = html.replaceAllMapped(RegExp(r'&'), (match) => "<td style=\"border: 1px solid;\">");
    html = html.replaceAllMapped(RegExp(r'\s+'), (match) => " ");
    html = html.replaceAll(RegExp(r'</en><td'), '</td><tr><td');
    return html;
  }
}