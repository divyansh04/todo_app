import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:todo_app/helpers/console_message_helper.dart';
import 'package:todo_app/helpers/toast_message_helper.dart';

import 'network_constant.dart';
import 'network_flag.dart';

class ApiProvider {
  // ignore: non_constant_identifier_names
  String BASE_URL = NetworkConstant.BASE_URL;

// ignore: slash_for_doc_comments
/**
 * This method will call get api method on provide $endPoint Route.
 * 
 * [endPoint] Pass Route url.
 */
  Future<dynamic> getBeforeAuth({required String endPoint}) async {
    try {
      var response = await http.get(Uri.parse('$BASE_URL$endPoint'));
      if (response.statusCode == 200) {
        Console.log(response.body);
        return json.decode(response.body);
      }
    } catch (e) {
      Console.log(e);
      ToastMessage.error(message: e.toString());
      return NetworkFlag.API_CALLING_fAILED;
    }
  }

// ignore: slash_for_doc_comments
/**
 * This method will call get api method which pass auth token in header section on provide $endPoint Route.
 * 
 * [endPoint] Pass Route url.
 */
  Future<dynamic> getAfterAuth({required String endPoint}) async {
    String authToken = '';
    try {
      var response = await http.get(Uri.parse('$BASE_URL$endPoint'), headers: {
        'Content-Type': 'application/json',
        'Authentication': 'Bearer $authToken'
      });
      if (response.statusCode == 200) {
        Console.log(response.body);
        return json.decode(response.body);
      }
    } catch (e) {
      Console.log(e);
      ToastMessage.error(message: e.toString());
      return NetworkFlag.API_CALLING_fAILED;
    }
  }

// ignore: slash_for_doc_comments
/**
 * This method will call Post method on provide $endPoint Route.
 * 
 * [endPoint] Pass Route url.
 * [parameters] pass all paramter as a Map<dynamic,String>. 
 */
  Future<dynamic> postBeforeAuth(
      {required String endPoint, required dynamic parameters}) async {
    try {
      var response = await http.post(Uri.parse('$BASE_URL$endPoint'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: parameters);
      if (response.statusCode == 200) {
        Console.log(response.body);
        return json.decode(response.body);
      }
    } catch (e) {
      Console.log(e);
      ToastMessage.error(message: e.toString());
      return NetworkFlag.API_CALLING_fAILED;
    }
  }



// ignore: slash_for_doc_comments
/**
 * This method will call Post method on provide $endPoint Route and will pass auth token in header secsion.
 * 
 * [endPoint] Pass Route url.
 * [parameters] pass all paramter as a Map<dynamic,String>. 
 */
  Future<dynamic> postAfterAuth({required String endPoint, required dynamic parameters}) async {
    String authToken = '';
    try {
      var response = await http.post(Uri.parse('$BASE_URL$endPoint'),
      
       headers: {
        'Content-Type': 'application/json',
        'Authentication': 'Bearer $authToken'
      },
      body: parameters
      );
      if (response.statusCode == 200) {
        Console.log(response.body);
        return json.decode(response.body);
      }
    } catch (e) {
      Console.log(e);
      ToastMessage.error(message: e.toString());
      return NetworkFlag.API_CALLING_fAILED;
    }
  }



}
