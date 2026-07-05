// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApiResponseModelImpl<T> _$$ApiResponseModelImplFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _$ApiResponseModelImpl<T>(
  success: json['success'] as bool,
  message: json['message'] as String?,
  data: fromJsonT(json['data']),
);

Map<String, dynamic> _$$ApiResponseModelImplToJson<T>(
  _$ApiResponseModelImpl<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': toJsonT(instance.data),
};
