import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response_model.freezed.dart';
part 'api_response_model.g.dart';

@Freezed(genericArgumentFactories: true)
class ApiResponseModel<T> with _$ApiResponseModel<T> {
  const factory ApiResponseModel({
    required bool success,
    String? message,
    required T data,
  }) = _ApiResponseModel<T>;

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseModelFromJson(json, fromJsonT);
}
