import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';

class ApiService {
  static const String baseUrl = "https://vehiclerental-is-cudwdmfdfefcexfa.northeurope-01.azurewebsites.net/api";

  static Future<List<Vehicle>> fetchAvailableVehicles() async {
    final response = await http.get(Uri.parse('$baseUrl/VehiclesApi/available'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Vehicle.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load vehicles");
    }
  } 
}

