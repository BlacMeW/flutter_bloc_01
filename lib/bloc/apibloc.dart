import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

/// EVENTS
abstract class ApiEvent {}

class FetchData extends ApiEvent {
  final String url;
  final String method;
  final Map<String, String>? headers;
  final dynamic body;

  FetchData({required this.url, this.method = 'GET', this.headers, this.body});
}

/// STATE
class ApiState {
  final String data;
  final String error;
  final bool loading;

  ApiState({this.data = '', this.error = '', this.loading = false});
}

/// BLOC
class ApiBloc extends Bloc<ApiEvent, ApiState> {
  ApiBloc() : super(ApiState()) {
    on<FetchData>(_onFetchData);
  }

  Future<void> _onFetchData(FetchData event, Emitter<ApiState> emit) async {
    emit(ApiState(loading: true));
    try {
      http.Response response;

      final uri = Uri.parse(event.url);
      final headers = event.headers ?? {'Content-Type': 'application/json'};

      switch (event.method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: event.body);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: event.body);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported method: ${event.method}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        emit(ApiState(data: response.body, loading: false));
      } else {
        emit(
          ApiState(
            error: 'HTTP ${response.statusCode}: ${response.body}',
            loading: false,
          ),
        );
      }
    } catch (e) {
      emit(ApiState(error: e.toString(), loading: false));
    }
  }
}
