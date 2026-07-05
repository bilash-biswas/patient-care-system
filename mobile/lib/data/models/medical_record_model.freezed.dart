// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medical_record_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MedicalRecordModel _$MedicalRecordModelFromJson(Map<String, dynamic> json) {
  return _MedicalRecordModel.fromJson(json);
}

/// @nodoc
mixin _$MedicalRecordModel {
  String get id => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  String get patientName => throw _privateConstructorUsedError;
  String? get doctorId => throw _privateConstructorUsedError;
  String? get doctorName => throw _privateConstructorUsedError;
  String get diagnosis => throw _privateConstructorUsedError;
  String get symptoms => throw _privateConstructorUsedError;
  String get treatment => throw _privateConstructorUsedError;
  String? get prescription => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get visitDate => throw _privateConstructorUsedError;
  DateTime? get nextVisitDate => throw _privateConstructorUsedError;
  String? get recordType => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MedicalRecordModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MedicalRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MedicalRecordModelCopyWith<MedicalRecordModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicalRecordModelCopyWith<$Res> {
  factory $MedicalRecordModelCopyWith(
    MedicalRecordModel value,
    $Res Function(MedicalRecordModel) then,
  ) = _$MedicalRecordModelCopyWithImpl<$Res, MedicalRecordModel>;
  @useResult
  $Res call({
    String id,
    String patientId,
    String patientName,
    String? doctorId,
    String? doctorName,
    String diagnosis,
    String symptoms,
    String treatment,
    String? prescription,
    String? notes,
    DateTime visitDate,
    DateTime? nextVisitDate,
    String? recordType,
    DateTime createdAt,
  });
}

/// @nodoc
class _$MedicalRecordModelCopyWithImpl<$Res, $Val extends MedicalRecordModel>
    implements $MedicalRecordModelCopyWith<$Res> {
  _$MedicalRecordModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MedicalRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? patientName = null,
    Object? doctorId = freezed,
    Object? doctorName = freezed,
    Object? diagnosis = null,
    Object? symptoms = null,
    Object? treatment = null,
    Object? prescription = freezed,
    Object? notes = freezed,
    Object? visitDate = null,
    Object? nextVisitDate = freezed,
    Object? recordType = freezed,
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
            doctorId: freezed == doctorId
                ? _value.doctorId
                : doctorId // ignore: cast_nullable_to_non_nullable
                      as String?,
            doctorName: freezed == doctorName
                ? _value.doctorName
                : doctorName // ignore: cast_nullable_to_non_nullable
                      as String?,
            diagnosis: null == diagnosis
                ? _value.diagnosis
                : diagnosis // ignore: cast_nullable_to_non_nullable
                      as String,
            symptoms: null == symptoms
                ? _value.symptoms
                : symptoms // ignore: cast_nullable_to_non_nullable
                      as String,
            treatment: null == treatment
                ? _value.treatment
                : treatment // ignore: cast_nullable_to_non_nullable
                      as String,
            prescription: freezed == prescription
                ? _value.prescription
                : prescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            visitDate: null == visitDate
                ? _value.visitDate
                : visitDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            nextVisitDate: freezed == nextVisitDate
                ? _value.nextVisitDate
                : nextVisitDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            recordType: freezed == recordType
                ? _value.recordType
                : recordType // ignore: cast_nullable_to_non_nullable
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
abstract class _$$MedicalRecordModelImplCopyWith<$Res>
    implements $MedicalRecordModelCopyWith<$Res> {
  factory _$$MedicalRecordModelImplCopyWith(
    _$MedicalRecordModelImpl value,
    $Res Function(_$MedicalRecordModelImpl) then,
  ) = __$$MedicalRecordModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String patientId,
    String patientName,
    String? doctorId,
    String? doctorName,
    String diagnosis,
    String symptoms,
    String treatment,
    String? prescription,
    String? notes,
    DateTime visitDate,
    DateTime? nextVisitDate,
    String? recordType,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$MedicalRecordModelImplCopyWithImpl<$Res>
    extends _$MedicalRecordModelCopyWithImpl<$Res, _$MedicalRecordModelImpl>
    implements _$$MedicalRecordModelImplCopyWith<$Res> {
  __$$MedicalRecordModelImplCopyWithImpl(
    _$MedicalRecordModelImpl _value,
    $Res Function(_$MedicalRecordModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MedicalRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? patientName = null,
    Object? doctorId = freezed,
    Object? doctorName = freezed,
    Object? diagnosis = null,
    Object? symptoms = null,
    Object? treatment = null,
    Object? prescription = freezed,
    Object? notes = freezed,
    Object? visitDate = null,
    Object? nextVisitDate = freezed,
    Object? recordType = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$MedicalRecordModelImpl(
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
        doctorId: freezed == doctorId
            ? _value.doctorId
            : doctorId // ignore: cast_nullable_to_non_nullable
                  as String?,
        doctorName: freezed == doctorName
            ? _value.doctorName
            : doctorName // ignore: cast_nullable_to_non_nullable
                  as String?,
        diagnosis: null == diagnosis
            ? _value.diagnosis
            : diagnosis // ignore: cast_nullable_to_non_nullable
                  as String,
        symptoms: null == symptoms
            ? _value.symptoms
            : symptoms // ignore: cast_nullable_to_non_nullable
                  as String,
        treatment: null == treatment
            ? _value.treatment
            : treatment // ignore: cast_nullable_to_non_nullable
                  as String,
        prescription: freezed == prescription
            ? _value.prescription
            : prescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        visitDate: null == visitDate
            ? _value.visitDate
            : visitDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        nextVisitDate: freezed == nextVisitDate
            ? _value.nextVisitDate
            : nextVisitDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        recordType: freezed == recordType
            ? _value.recordType
            : recordType // ignore: cast_nullable_to_non_nullable
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
class _$MedicalRecordModelImpl extends _MedicalRecordModel {
  const _$MedicalRecordModelImpl({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.doctorId,
    this.doctorName,
    required this.diagnosis,
    required this.symptoms,
    required this.treatment,
    this.prescription,
    this.notes,
    required this.visitDate,
    this.nextVisitDate,
    this.recordType,
    required this.createdAt,
  }) : super._();

  factory _$MedicalRecordModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicalRecordModelImplFromJson(json);

  @override
  final String id;
  @override
  final String patientId;
  @override
  final String patientName;
  @override
  final String? doctorId;
  @override
  final String? doctorName;
  @override
  final String diagnosis;
  @override
  final String symptoms;
  @override
  final String treatment;
  @override
  final String? prescription;
  @override
  final String? notes;
  @override
  final DateTime visitDate;
  @override
  final DateTime? nextVisitDate;
  @override
  final String? recordType;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'MedicalRecordModel(id: $id, patientId: $patientId, patientName: $patientName, doctorId: $doctorId, doctorName: $doctorName, diagnosis: $diagnosis, symptoms: $symptoms, treatment: $treatment, prescription: $prescription, notes: $notes, visitDate: $visitDate, nextVisitDate: $nextVisitDate, recordType: $recordType, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicalRecordModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.patientName, patientName) ||
                other.patientName == patientName) &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.doctorName, doctorName) ||
                other.doctorName == doctorName) &&
            (identical(other.diagnosis, diagnosis) ||
                other.diagnosis == diagnosis) &&
            (identical(other.symptoms, symptoms) ||
                other.symptoms == symptoms) &&
            (identical(other.treatment, treatment) ||
                other.treatment == treatment) &&
            (identical(other.prescription, prescription) ||
                other.prescription == prescription) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.visitDate, visitDate) ||
                other.visitDate == visitDate) &&
            (identical(other.nextVisitDate, nextVisitDate) ||
                other.nextVisitDate == nextVisitDate) &&
            (identical(other.recordType, recordType) ||
                other.recordType == recordType) &&
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
    diagnosis,
    symptoms,
    treatment,
    prescription,
    notes,
    visitDate,
    nextVisitDate,
    recordType,
    createdAt,
  );

  /// Create a copy of MedicalRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicalRecordModelImplCopyWith<_$MedicalRecordModelImpl> get copyWith =>
      __$$MedicalRecordModelImplCopyWithImpl<_$MedicalRecordModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicalRecordModelImplToJson(this);
  }
}

abstract class _MedicalRecordModel extends MedicalRecordModel {
  const factory _MedicalRecordModel({
    required final String id,
    required final String patientId,
    required final String patientName,
    final String? doctorId,
    final String? doctorName,
    required final String diagnosis,
    required final String symptoms,
    required final String treatment,
    final String? prescription,
    final String? notes,
    required final DateTime visitDate,
    final DateTime? nextVisitDate,
    final String? recordType,
    required final DateTime createdAt,
  }) = _$MedicalRecordModelImpl;
  const _MedicalRecordModel._() : super._();

  factory _MedicalRecordModel.fromJson(Map<String, dynamic> json) =
      _$MedicalRecordModelImpl.fromJson;

  @override
  String get id;
  @override
  String get patientId;
  @override
  String get patientName;
  @override
  String? get doctorId;
  @override
  String? get doctorName;
  @override
  String get diagnosis;
  @override
  String get symptoms;
  @override
  String get treatment;
  @override
  String? get prescription;
  @override
  String? get notes;
  @override
  DateTime get visitDate;
  @override
  DateTime? get nextVisitDate;
  @override
  String? get recordType;
  @override
  DateTime get createdAt;

  /// Create a copy of MedicalRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MedicalRecordModelImplCopyWith<_$MedicalRecordModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
