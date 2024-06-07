import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';

class ResponseUtils {
  static String extractFinalAnswer(String responseContent) {
    final regex = RegExp(r'final answer(.+)', caseSensitive: false);
    final match = regex.firstMatch(responseContent);
    return match?.group(0) ?? '';
  }

  static String processResponseAndRemoveFinalAnswer(String responseContent, String finalAnswer) {
    String contentWithoutFinalAnswer = responseContent.replaceAll(finalAnswer, '');
    final stepRegex = RegExp(r'(Step \d+:)', caseSensitive: false);
    Iterable<RegExpMatch> matches = stepRegex.allMatches(contentWithoutFinalAnswer);

    if (matches.isEmpty) {
      return contentWithoutFinalAnswer;
    }

    StringBuffer processedContent = StringBuffer();
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start != lastMatchEnd) {
        processedContent.write(contentWithoutFinalAnswer.substring(lastMatchEnd, match.start).trim());
        processedContent.write('\n\n');
      }

      if (processedContent.isNotEmpty && !processedContent.toString().endsWith('\n\n')) {
        processedContent.write('\n\n');
      }

      processedContent.write("<b>${match.group(0)}</b>");
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < contentWithoutFinalAnswer.length) {
      processedContent.write('\n\n' + contentWithoutFinalAnswer.substring(lastMatchEnd).trim());
    }

    return processedContent.toString().trim();
  }

  static ProcessedQuestion processQuestionText(String question) {
    final choiceRegex = RegExp(r'([A-E][).]|[(][A-E][)])\s*([^[(A-E)]*[\s\S]*?)(?=\s+[A-E][.).]|[(][A-E][)]\s*|\s*$)', caseSensitive: false);
    Iterable<RegExpMatch> matches = choiceRegex.allMatches(question);

    if (matches.isEmpty) {
      return ProcessedQuestion(question.trim(), []);
    }

    StringBuffer processedQuestion = StringBuffer();
    List<String> choices = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start != lastMatchEnd) {
        processedQuestion.write(question.substring(lastMatchEnd, match.start));
      }

      String choice = match.group(0)!.replaceAll('\\', ' ').trim();
      choices.add(choice);
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < question.length) {
      processedQuestion.write(question.substring(lastMatchEnd));
    }

    return ProcessedQuestion(processedQuestion.toString().trim(), choices);
  }
}

class ProcessedQuestion {
  final String questionText;
  final List<String> options;

  ProcessedQuestion(this.questionText, this.options);
}