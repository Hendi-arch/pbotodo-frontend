import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo/services/shared_pref_service.dart';
import 'package:todo/models/task.dart';
import 'package:todo/shared/globals.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<void> logout() async {
    final url = Uri.parse('$baseURL/auth/logout');
    final token = await SharedPrefService().getToken();

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    debugPrint(response.body);
    await SharedPrefService().removeCredentials();
  }

  Future<void> signin(String username, String password) async {
    final deviceId = await SharedPrefService().getDeviceId();
    final data = {
      "password": password,
      "username": username,
      "deviceId": deviceId,
    };
    debugPrint(data.toString());
    final body = json.encode(data);
    final url = Uri.parse('$baseURL/auth/signin');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    final responseMap = jsonDecode(response.body);
    await SharedPrefService()
        .saveCredentials(responseMap["user"], responseMap["token"]);
  }

  Future<void> signup(String username, String password) async {
    final deviceId = await SharedPrefService().getDeviceId();
    final data = {
      "password": password,
      "username": username,
      "deviceId": deviceId,
    };
    final body = json.encode(data);
    final url = Uri.parse('$baseURL/auth/signup');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    debugPrint(response.body);
    final responseMap = jsonDecode(response.body);
    await SharedPrefService()
        .saveCredentials(responseMap["user"], responseMap["token"]);
  }

  Future<Task> addTask(Task task) async {
    final username = await SharedPrefService().getUsername();
    final token = await SharedPrefService().getToken();
    task.username = username!;

    final body = json.encode(task.toJson());
    final url = Uri.parse('$baseURL/tasks/add');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );
    debugPrint(response.body);
    final responseMap = jsonDecode(response.body);
    final responseTask = Task.fromMap(responseMap);

    return responseTask;
  }

  Future<Task> updateTask(Task task) async {
    final username = await SharedPrefService().getUsername();
    final token = await SharedPrefService().getToken();
    task.username = username!;

    final body = json.encode(task.toJsonUpdate());
    final url = Uri.parse('$baseURL/tasks/update');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );
    debugPrint(response.body);
    final responseMap = jsonDecode(response.body);
    final responseTask = Task.fromMap(responseMap);

    return responseTask;
  }

  Future<List<Task>> getTasks() async {
    final username = await SharedPrefService().getUsername();
    final token = await SharedPrefService().getToken();
    final url = Uri.parse('$baseURL/tasks/get?username=$username');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    debugPrint(response.body);
    final responseList = jsonDecode(response.body);
    final tasks =
        responseList.map<Task>((taskMap) => Task.fromMap(taskMap)).toList();
    return tasks;
  }

  Future<http.Response> updateTaskProgress(int id) async {
    final username = await SharedPrefService().getUsername();
    final token = await SharedPrefService().getToken();
    final url = Uri.parse('$baseURL/tasks/update/$id/$username');
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    debugPrint(response.body);
    return response;
  }

  Future<http.Response> deleteTask(int id) async {
    final username = await SharedPrefService().getUsername();
    final token = await SharedPrefService().getToken();
    final url = Uri.parse('$baseURL/tasks/delete/$id/$username');
    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    debugPrint(response.body);
    return response;
  }
}
