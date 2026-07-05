// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppointmentModel _$AppointmentModelFromJson(Map<String, dynamic> json) {
  return _AppointmentModel.fromJson(json);
}

/// @nodoc
mixin _$AppointmentModel {
  String get id => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  String get patientName => throw _privateConstructorUsedError;
  String get doctorId => throw _privateConstructorUsedError;
  String get doctorName => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  DateTime get appointmentDate => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  String get endTime => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AppointmentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppointmentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppointmentModelCopyWith<AppointmentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppointmentModelCopyWith<$Res> {
  factory $AppointmentModelCopyWith(
    AppointmentModel value,
    $Res Function(AppointmentModel) then,
  ) = _$AppointmentModelCopyWithImpl<$Res, AppointmentModel>;
  @useResult
  $Res call({
    String id,
    String patientId,
    String patientName,
    String doctorId,
    String doctorName,
    String reason,
    DateTime appointmentDate,
    String startTime,
    String endTime,
    String status,
    String? notes,
    DateTime createdAt,
  });
}

/// @nodoc
class _$AppointmentModelCopyWithImpl<$Res, $Val extends AppointmentModel>
    implements $AppointmentModelCopyWith<$Res> {
  _$AppointmentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppointmentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? patientName = null,
    Object? doctorId = null,
    Object? doctorName = null,
    Object? reason = null,
    Object? appointmentDate = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? status = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            patientId: null == patientId
                ? _value.patientId
                : patientId // ignore: cast_nullable_to_non_nullable
                      as String,
            patientName: null == patientName
                ? _value.patientName
                : patientName // ignore: cast_nullable_to_non_nullable
                      as String,
            doctorId: null == doctorId
                ? _value.doctorId
                : doctorId // ignore: cast_nullable_to_non_nullable
                      as String,
            doctorName: null == doctorName
                ? _value.doctorName
                : doctorName // ignore: cast_nullable_to_non_nullable
                      as String,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
            appointmentDate: null == appointmentDate
                ? _value.appointmentDate
                : appointmentDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as String,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppointmentModelImplCopyWith<$Res>
    implements $AppointmentModelCopyWith<$Res> {
  factory _$$AppointmentModelImplCopyWith(
    _$AppointmentModelImpl value,
    $Res Function(_$AppointmentModelImpl) then,
  ) = __$$AppointmentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String patientId,
    String patientName,
    String doctorId,
    String doctorName,
    String reason,
    DateTime appointmentDate,
    String startTime,
    String endTime,
    String status,
    String? notes,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$AppointmentModelImplCopyWithImpl<$Res>
    extends _$AppointmentModelCopyWithImpl<$Res, _$AppointmentModelImpl>
    implements _$$AppointmentModelImplCopyWith<$Res> {
  __$$AppointmentModelImplCopyWithImpl(
    _$AppointmentModelImpl _value,
    $Res Function(_$AppointmentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppointmentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? patientName = null,
    Object? doctorId = null,
    Object? doctorName = null,
    Object? reason = null,
    Object? appointmentDate = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? status = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$AppointmentModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        patientId: null == patientId
            ? _value.patientId
            : patientId // ignore: cast_nullable_to_non_nullable
                  as String,
        patientName: null == patientName
            ? _value.patientName
            : patientName // ignore: cast_nullable_to_non_nullable
                  as String,
        doctorId: null == doctorId
            ? _value.doctorId
            : doctorId // ignore: cast_nullable_to_non_nullable
                  as String,
        doctorName: null == doctorName
            ? _value.doctorName
            : doctorName // ignore: cast_nullable_to_non_nullable
                  as String,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
        appointmentDate: null == appointmentDate
            ? _value.appointmentDate
            : appointmentDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as String,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppointmentModelImpl extends _AppointmentModel {
  const _$AppointmentModelImpl({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.reason,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    required this.createdAt,
  }) : super._();

  factory _$AppointmentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppointmentModelImplFromJson(json);

  @override
  final String id;
  @override
  final String patientId;
  @override
  final String patientName;
  @override
  final String doctorId;
  @override
  final String doctorName;
  @override
  final String reason;
  @override
  final DateTime appointmentDate;
  @override
  final String startTime;
  @override
  final String endTime;
  @override
  final String status;
  @override
  final String? notes;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'AppointmentModel(id: $id, patientId: $patientId, patientName: $patientName, doctorId: $doctorId, doctorName: $doctorName, reason: $reason, appointmentDate: $appointmentDate, startTime: $startTime, endTime: $endTime, status: $status, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppointmentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.patientName, patientName) ||
                other.patientName == patientName) &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.doctorName, doctorName) ||
                other.doctorName == doctorName) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.appointmentDate, appointmentDate) ||
                other.appointmentDate == appointmentDate) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    patientId,
    patientName,
    doctorId,
    doctorName,
    reason,
    appointmentDate,
    startTime,
    endTime,
    status,
    notes,
    createdAt,
  );

  /// Create a copy of AppointmentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppointmentModelImplCopyWith<_$AppointmentModelImpl> get copyWith =>
      __$$AppointmentModelImplCopyWithImpl<_$AppointmentModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AppointmentModelImplToJson(this);
  }
}

abstract class _AppointmentModel extends AppointmentModel {
  const factory _AppointmentModel({
    required final String id,
    required final String patientId,
    required final String patientName,
    required final String doctorId,
    required final String doctorName,
    required final String reason,
    required final DateTime appointmentDate,
    required final String startTime,
    required final String endTime,
    required final String status,
    final String? notes,
    required final DateTime createdAt,
  }) = _$AppointmentModelImpl;
  const _AppointmentModel._() : super._();

  factory _AppointmentModel.fromJson(Map<String, dynamic> json) =
      _$AppointmentModelImpl.fromJson;

  @override
  String get id;
  @override
  String get patientId;
  @override
  String get patientName;
  @override
  String get doctorId;
  @override
  String get doctorName;
  @override
  String get reason;
  @override
  DateTime get appointmentDate;
  @override
  String get startTime;
  @override
  String get endTime;
  @override
  String get status;
  @override
  String? get notes;
  @override
  DateTime get createdAt;

  /// Create a copy of AppointmentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppointmentModelImplCopyWith<_$AppointmentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
