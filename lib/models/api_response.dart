class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({required this.success, required this.message, this.data});

  factory ApiResponse.fromJson( //factory constructor for creating an instance of ApiResponse from a JSON response.
      Map<String, dynamic> json,  //the json data that comes from the api
      T Function(Object? json)? fromJsonT,  //converts json data into desired type T
      ) =>
      ApiResponse(
        success: json['success'] as bool,
        message: json['message'] as String,
        data: json['data'] != null ? fromJsonT!(json['data']) : null,
      );
}
