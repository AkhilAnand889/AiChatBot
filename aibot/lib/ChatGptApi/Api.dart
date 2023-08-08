import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;


// chatbot api function

Future<Map<String, dynamic>> sendMessageToBackend(String message) async {
  try {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'idToken');

    if (token == null) {
      throw Exception('Token not found');
    }

    final subdata = await fetchUserAttributes().then((response) {
      final sub = response['sub'] ?? '';
      return sub;
    });

    final response = await http.post(
      Uri.parse(
          'https://hmwx95k5yi.execute-api.ap-south-1.amazonaws.com/dev/controller/chatbot'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'message': message, 'userId': subdata}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Failed to send message: $error');
  }
}

// to get all users messages

Future<List<Map<String, dynamic>>> getAllMessages() async {
  try {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'idToken');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse(
          'https://hmwx95k5yi.execute-api.ap-south-1.amazonaws.com/dev/controller/getmessages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      final messages = responseData['messages'] as List<dynamic>;

      final List<Map<String, dynamic>> formattedMessages = messages
          .map<Map<String, dynamic>>(
              (dynamic message) => message as Map<String, dynamic>)
          .toList();

      return formattedMessages;
    } else {
      print('Failed to get messages: ${response.statusCode}');
      throw Exception('Failed to get messages: ${response.statusCode}');
    }
  } catch (error) {
    print('Failed to get messages: $error');
    throw Exception('Failed to get messages: $error');
  }
}


//To fetch user attributes

Future<Map<String, dynamic>> fetchUserAttributes() async {
  final url =
      'https://hmwx95k5yi.execute-api.ap-south-1.amazonaws.com/dev/controller/getuseratt';
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'accessToken');
  final headers = <String, String>{'Authorization': token ?? ''};

  try {
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData.containsKey('userAttributes')) {
        final userAttributes = responseData['userAttributes'];

        final Map<String, dynamic> attributeMap = {};

        for (var attribute in userAttributes) {
          final attributeName = attribute['Name'];
          final attributeValue = attribute['Value'];

          attributeMap[attributeName] = attributeValue;
        }

        return attributeMap;
      } else {
        print('Response does not contain userAttributes');
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (error) {
    print('An error occurred: $error');
  }

  return {};
}


//retriving messages by user

Future<Map<String, dynamic>> retrieveUserMessages() async {
  try {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'idToken');

    if (token == null) {
      throw Exception('Token not found');
    }

    final id = await fetchUserAttributes().then((response) {
      final sub = response['sub'] ?? '';
      return sub;
    });

    final response = await http.get(
      Uri.parse(
          'https://hmwx95k5yi.execute-api.ap-south-1.amazonaws.com/dev/controller/retrieveMessages/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final filteredItems = responseData['filteredItems'] as List<dynamic>?;
      final responseItems = responseData['responseItems'] as List<dynamic>?;

      if (filteredItems != null && responseItems != null) {
        final List<Map<String, dynamic>> formattedFilteredItems = filteredItems
            .map<Map<String, dynamic>>(
                (dynamic message) => message as Map<String, dynamic>)
            .toList();

        final List<Map<String, dynamic>> formattedResponseItems = responseItems
            .map<Map<String, dynamic>>(
                (dynamic message) => message as Map<String, dynamic>)
            .toList();

        // Sort the messages based on the 'id' property
        formattedFilteredItems.sort((a, b) {
          final DateTime dateTimeA = DateTime.parse(a['id']);
          final DateTime dateTimeB = DateTime.parse(b['id']);
          return dateTimeB.compareTo(dateTimeA);
        });

        return {
          'filteredItems': formattedFilteredItems,
          'responseItems': formattedResponseItems,
        };
      } else {
        return {
          'filteredItems': [],
          'responseItems': [],
        };
      }
    } else {
      print('Failed to get messages: ${response.statusCode}');
      throw Exception('Failed to get messages: ${response.statusCode}');
    }
  } catch (error) {
    print('Failed to get messages: $error');
    throw Exception('Failed to get messages: $error');
  }
}


// user logout

Future<Map<String, dynamic>> userLogOut() async {
  final url =
      'https://hmwx95k5yi.execute-api.ap-south-1.amazonaws.com/dev/user/globalSignOut';
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'accessToken');
  final headers = <String, String>{'Authorization': token ?? ''};

  try {
    final response = await http.post(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
    print('user globalsignOut successfull');
    const Text('Logout successfully comopleted');
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (error) {
    print('An error occurred: $error');
  }

  return {};
}