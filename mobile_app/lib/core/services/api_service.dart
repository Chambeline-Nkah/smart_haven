// // lib/core/services/api_service.dart
// import 'package:dio/dio.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// class ApiService {
//   late final Dio _dio;
//   static const String baseUrl = 'YOUR_API_BASE_URL';
//   static const String webSocketUrl = 'wss://your-websocket-url.com';
//   final FirebaseDatabase _database = FirebaseDatabase.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   static const String openAiUrl = 'https://api.openai.com/v1';
//   WebSocketChannel? _channel;

//   ApiService() {
//     _dio = Dio(BaseOptions(
//       baseUrl: baseUrl,
//       connectTimeout: const Duration(seconds: 5),
//       receiveTimeout: const Duration(seconds: 3),
//     ));
//   }

//   Future<Map<String, dynamic>> getPoultryState() async {
//     try {
//       final response = await _dio.get('/poultry/state');
//       return response.data;
//     } catch (e) {
//       throw Exception('Failed to fetch poultry state: $e');
//     }
//   }

//   Future<Map<String, dynamic>> getSensorData() async {
//     try {
//       final response = await _dio.get('/sensors/data');
//       return response.data;
//     } catch (e) {
//       throw Exception('Failed to fetch sensor data: $e');
//     }
//   }

//   Stream<List<double>> getAudioStream() {
//     // Firebase Realtime Database Implementation
//     /*
//     return _database
//         .ref('audio_data')
//         .onValue
//         .map((event) {
//           final data = event.snapshot.value as Map<dynamic, dynamic>?;
//           if (data != null) {
//             return List<double>.from(data['samples'] ?? []);
//           }
//           return <double>[];
//         });
//     */

//     // WebSocket Implementation
//     /*
//     if (_channel == null) {
//       _channel = WebSocketChannel.connect(
//         Uri.parse(webSocketUrl),
//       );

//       // Send initial configuration
//       _channel?.sink.add(jsonEncode({
//         'type': 'subscribe',
//         'channel': 'audio_feed',
//         'config': {
//           'sampleRate': 44100,
//           'bufferSize': 1024,
//         }
//       }));
//     }

//     return _channel!.stream.map((data) {
//       final jsonData = jsonDecode(data as String);
//       return List<double>.from(jsonData['samples']);
//     });
//     */

//     // Placeholder implementation
//     return Stream.periodic(
//       const Duration(milliseconds: 100),
//       (count) => List.generate(
//         100,
//         (index) => 0.5 + (DateTime.now().millisecondsSinceEpoch % 100) / 200,
//       ),
//     );
//   }

//   Future<List<Map<String, dynamic>>> getHistoryData() async {
//     try {
//       // Real Firebase implementation
//       /*
//       final snapshot = await _database.ref('history').get();
//       if (snapshot.exists) {
//         final data = snapshot.value as Map<dynamic, dynamic>;
//         return data.entries
//             .map((e) => Map<String, dynamic>.from(e.value as Map))
//             .toList();
//       }
//       return [];
//       */

//       // Dummy implementation
//       await Future.delayed(const Duration(seconds: 1));
//       return [
//         {
//           'title': 'Temperature Alert',
//           'description': 'Temperature exceeded normal range at 2:30 PM',
//           'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
//         },
//         {
//           'title': 'Humidity Warning',
//           'description': 'Humidity levels dropped below optimal range',
//           'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
//         },
//       ];
//     } catch (e) {
//       throw Exception('Failed to fetch history data: $e');
//     }
//   }

//    Future<String> uploadAudioRecording(List<int> audioData) async {
//     try {
//       // Real implementation
//       /*
//       // Upload to Firebase Storage
//       final fileName = 'recordings/${DateTime.now().millisecondsSinceEpoch}.wav';
//       final ref = _storage.ref().child(fileName);
//       await ref.putData(Uint8List.fromList(audioData));
//       final downloadUrl = await ref.getDownloadURL();

//       // Send to processing server
//       final response = await _dio.post(
//         '/process-audio',
//         data: {'audioUrl': downloadUrl},
//       );

//       return response.data['processedId'];
//       */

//       // Dummy implementation
//       await Future.delayed(const Duration(seconds: 2));
//       return 'dummy_processed_id';
//     } catch (e) {
//       throw Exception('Failed to upload audio: $e');
//     }
//   }

//   Future<String> getAiAnalysis(String processedAudioId) async {
//     try {
//       // Real implementation
//       /*
//       final response = await _dio.post(
//         '$openAiUrl/chat/completions',
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer YOUR_OPENAI_API_KEY',
//           },
//         ),
//         data: {
//           'model': 'gpt-4',
//           'messages': [
//             {
//               'role': 'system',
//               'content': 'You are analyzing poultry sounds.',
//             },
//             {
//               'role': 'user',
//               'content': 'Analyze this processed audio: $processedAudioId',
//             },
//           ],
//         },
//       );

//       return response.data['choices'][0]['message']['content'];
//       */

//       // Dummy implementation
//       await Future.delayed(const Duration(seconds: 1));
//       return 'The poultry sounds indicate normal behavior with consistent feeding patterns.';
//     } catch (e) {
//       throw Exception('Failed to get AI analysis: $e');
//     }
//   }

//   Future<void> saveToHistory(String audioUrl, String analysis) async {
//     try {
//       // Real implementation
//       /*
//       final historyRef = _database.ref('history').push();
//       await historyRef.set({
//         'title': 'Audio Analysis',
//         'description': analysis,
//         'audioUrl': audioUrl,
//         'timestamp': DateTime.now().toIso8601String(),
//       });
//       */

//       // Dummy implementation
//       await Future.delayed(const Duration(milliseconds: 500));
//     } catch (e) {
//       throw Exception('Failed to save to history: $e');
//     }
//   }

//   void dispose() {
//     _channel?.sink.close();
//     _channel = null;
//   }

//   void disposeAudioStream() {
//     _channel?.sink.close();
//     _channel = null;
//   }
// }

// lib/core/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  late final Dio _dio;
  final supabase = Supabase.instance.client;
  static final String baseUrl = dotenv.env['SUPABASE_URL'] ?? '';

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10), // Increased timeout
      receiveTimeout: const Duration(seconds: 10),
      // Add retry options
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ));

    // Add interceptor for logging
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (object) {
            debugPrint(object.toString()); // This will show in debug console
          }));
    }
  }


  Future<Map<String, dynamic>> getPoultryState() async {
    try {
      final response = await supabase
          .from('poultry_state')
          .select()
          .order('created_at', ascending: false) // Order by the most recent
          .limit(1) // Limit to one row
          .maybeSingle();

      if (response == null) {
        throw Exception('No poultry state data found');
      }

      return response;
    } catch (e) {
      debugPrint(
          'Error fetching poultry state data: $e'); // This will show in debug console
      if (e is PostgrestException) {
        throw Exception('Database error: ${e.message}');
      } else {
        throw Exception('Network error: Please check your connection');
      }
    }
  }

  Future<Map<String, dynamic>> getSensorData() async {
    try {
      final response = await supabase
          .from('sensor_data')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle(); // Use maybeSingle() if you expect possibly no results

      if (response == null) {
        throw Exception('No sensor data found');
      }

      return response;
    } catch (e) {
      debugPrint('Error fetching sensor data: $e');
      if (e is PostgrestException) {
        throw Exception('Database error: ${e.message}');
      }
      throw Exception('Network error: Please check your connection');
    }
  }

  Stream<List<double>> getAudioStream() {
    // Using Supabase Realtime
    return supabase.from('audio_data').stream(primaryKey: ['id']).map((data) {
      if (data.isNotEmpty) {
        return List<double>.from(data.first['samples'] ?? []);
      }
      return <double>[];
    });
  }

  Stream<bool> getAudioStreamStatus() {
    return supabase
        .from('audio_stream_status')
        .stream(primaryKey: ['id']).map((data) {
      if (data.isNotEmpty) {
        return data.first['is_active'] as bool;
      }
      return false;
    });
  }

  Future<List<Map<String, dynamic>>> getHistoryData() async {
    try {
      final response = await supabase
          .from('history')
          .select()
          .order('timestamp', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch history data: $e');
    }
  }

  Future<String> uploadAudioRecording(List<int> audioData) async {
    try {
      final fileName =
          'recordings/${DateTime.now().millisecondsSinceEpoch}.wav';

      // Upload to Supabase Storage
      await supabase.storage
          .from('audio-recordings')
          .uploadBinary(fileName, Uint8List.fromList(audioData));

      // Get public URL
      final String publicUrl =
          supabase.storage.from('audio-recordings').getPublicUrl(fileName);

      // Create record in recordings table
      final response = await supabase
          .from('recordings')
          .insert({
            'url': publicUrl,
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String()
          })
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to upload audio: $e');
    }
  }

  Future<String> getAiAnalysis(String processedAudioId) async {
    try {
      // Using Supabase Edge Functions
      final response = await supabase.functions.invoke(
        'get-poultry-advice'
        
      );

      if (response.status != 200) {
        throw Exception('Failed to analyze audio');
      }

      return response.data['analysis'] as String;
    } catch (e) {
      throw Exception('Failed to get AI analysis: $e');
    }
  }

  Future<void> saveToHistory(String audioUrl, String analysis) async {
    try {
      await supabase.from('history').insert({
        'title': 'Audio Analysis',
        'description': analysis,
        'audio_url': audioUrl,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save to history: $e');
    }
  }

  Future<Map<String, dynamic>> getPoultryAdvice({
    required String temperature,
    required String humidity,
    required String farmState,
  }) async {
    try {
      final response = await supabase.functions.invoke(
        'get-poultry-advice',
        body: {
          'temperature': temperature,
          'humidity': humidity,
          'farm_state': farmState,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to get advice');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get poultry advice: $e');
    }
  }

  void disposeAudioStream() {
    // For Supabase Realtime, you need to remove the subscription
    supabase.removeAllChannels();
  }

  void ensureAuthenticated() {
    if (supabase.auth.currentUser == null) {
      throw Exception('User not authenticated. Please sign in.');
    }
  }
}
