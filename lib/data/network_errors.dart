import 'package:dio/dio.dart';

String friendlyErrorMessage(Object error) {
  if (error is! DioException) {
    return 'Something went wrong. Please try again.';
  }

  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => 'The API took too long to respond. Check that it is running and try again.',
    DioExceptionType.connectionError =>
      'Could not reach the API. Start the backend and try again.',
    DioExceptionType.badResponse =>
      'The API returned an error. Please try again later.',
    _ => 'Something went wrong. Please try again.',
  };
}
