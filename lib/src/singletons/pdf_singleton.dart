import 'dart:io';
import 'package:flutter/material.dart';

class PdfSingleton {

   static PdfSingleton  _pdfSng = PdfSingleton._();
   PdfSingleton._();

  factory PdfSingleton() {
    return _pdfSng;
  }

  File pdf;
  Widget pfdWidget;

}