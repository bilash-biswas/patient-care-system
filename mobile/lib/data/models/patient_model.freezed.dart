// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PatientModel _$PatientModelFromJson(Map<String, dynamic> json) {
  return _PatientModel.fromJson(json);
}

/// @nodoc
mixin _$PatientModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError;
  DateTime get dateOfBirth => throw _privateConstructorUsedError;
  String? get bloodGroup => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get emergencyContactName => throw _privateConstructorUsedError;
  String? get emergencyContactPhone => throw _privateConstructorUsedError;
  String? get insuranceProvider => throw _privateConstructorUsedError;
  String? get insurancePolicyNumber => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PatientModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PatientModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PatientModelCopyWith<PatientModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientModelCopyWith<$Res> {
  factory $PatientModelCopyWith(
    PatientModel value,
    $Res Function(PatientModel) then,
  ) = _$PatientModelCopyWithImpl<$Res, PatientModel>;
  @useResult
  $Res call({
    String id,
    String userId,
    String firstName,
    String lastName,
    String gender,
    DateTime dateOfBirth,
    String? bloodGroup,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$PatientModelCopyWithImpl<$Res, $Val extends PatientModel>
    implements $PatientModelCopyWith<$Res> {
  _$PatientModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PatientModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? gender = null,
    Object? dateOfBirth = null,
    Object? bloodGroup = freezed,
    Object? address = freezed,
    Object? emergencyContactName = freezed,
    Object? emergencyContactPhone = freezed,
    Object? insuranceProvider = freezed,
    Object? insurancePolicyNumber = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            lastName: null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String,
            gender: null == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String,
            dateOfBirth: null == dateOfBirth
                ? _value.dateOfBirth
                : dateOfBirth // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            bloodGroup: freezed == bloodGroup
                ? _value.bloodGroup
                : bloodGroup // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            emergencyContactName: freezed == emergencyContactName
                ? _value.emergencyContactName
                : emergencyContactName // ignore: cast_nullable_to_non_nullable
                      as String?,
            emergencyContactPhone: freezed == emergencyContactPhone
                ? _value.emergencyContactPhone
                : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            insuranceProvider: freezed == insuranceProvider
                ? _value.insuranceProvider
                : insuranceProvider // ignore: cast_nullable_to_non_nullable
                      as String?,
            insurancePolicyNumber: freezed == insurancePolicyNumber
                ? _value.insurancePolicyNumber
                : insurancePolicyNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PatientModelImplCopyWith<$Res>
    implements $PatientModelCopyWith<$Res> {
  factory _$$PatientModelImplCopyWith(
    _$PatientModelImpl value,
    $Res Function(_$PatientModelImpl) then,
  ) = __$$PatientModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String firstName,
    String lastName,
    String gender,
    DateTime dateOfBirth,
    String? bloodGroup,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$PatientModelImplCopyWithImpl<$Res>
    extends _$PatientModelCopyWithImpl<$Res, _$PatientModelImpl>
    implements _$$PatientModelImplCopyWith<$Res> {
  __$$PatientModelImplCopyWithImpl(
    _$PatientModelImpl _value,
    $Res Function(_$PatientModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PatientModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? gender = null,
    Object? dateOfBirth = null,
    Object? bloodGroup = freezed,
    Object? address = freezed,
    Object? emergencyContactName = freezed,
    Object? emergencyContactPhone = freezed,
    Object? insuranceProvider = freezed,
    Object? insurancePolicyNumber = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$PatientModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        lastName: null == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String,
        gender: null == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String,
        dateOfBirth: null == dateOfBirth
            ? _value.dateOfBirth
            : dateOfBirth // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        bloodGroup: freezed == bloodGroup
            ? _value.bloodGroup
            : bloodGroup // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        emergencyContactName: freezed == emergencyContactName
            ? _value.emergencyContactName
            : emergencyContactName // ignore: cast_nullable_to_non_nullable
                  as String?,
        emergencyContactPhone: freezed == emergencyContactPhone
            ? _value.emergencyContactPhone
            : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        insuranceProvider: freezed == insuranceProvider
            ? _value.insuranceProvider
            : insuranceProvider // ignore: cast_nullable_to_non_nullable
                  as String?,
        insurancePolicyNumber: freezed == insurancePolicyNumber
            ? _value.insurancePolicyNumber
            : insurancePolicyNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PatientModelImpl extends _PatientModel {
  const _$PatientModelImpl({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    this.bloodGroup,
    this.address,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.insuranceProvider,
    this.insurancePolicyNumber,
    required this.createdAt,
    this.updatedAt,
  }) : super._();

  factory _$PatientModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String gender;
  @override
  final DateTime dateOfBirth;
  @override
  final String? bloodGroup;
  @override
  final String? address;
  @override
  final String? emergencyContactName;
  @override
  final String? emergencyContactPhone;
  @override
  final String? insuranceProvider;
  @override
  final String? insurancePolicyNumber;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PatientModel(id: $id, userId: $userId, firstName: $firstName, lastName: $lastName, gender: $gender, dateOfBirth: $dateOfBirth, bloodGroup: $bloodGroup, address: $address, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone, insuranceProvider: $insuranceProvider, insurancePolicyNumber: $insurancePolicyNumber, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.bloodGroup, bloodGroup) ||
                other.bloodGroup == bloodGroup) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.emergencyContactName, emergencyContactName) ||
                other.emergencyContactName == emergencyContactName) &&
            (identical(other.emergencyContactPhone, emergencyContactPhone) ||
                other.emergencyContactPhone == emergencyContactPhone) &&
            (identical(other.insuranceProvider, insuranceProvider) ||
                other.insuranceProvider == insuranceProvider) &&
            (identical(other.insurancePolicyNumber, insurancePolicyNumber) ||
                other.insurancePolicyNumber == insurancePolicyNumber) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    firstName,
    lastName,
    gender,
    dateOfBirth,
    bloodGroup,
    address,
    emergencyContactName,
    emergencyContactPhone,
    insuranceProvider,
    insurancePolicyNumber,
    createdAt,
    updatedAt,
  );

  /// Create a copy of PatientModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientModelImplCopyWith<_$PatientModelImpl> get copyWith =>
      __$$PatientModelImplCopyWithImpl<_$PatientModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientModelImplToJson(this);
  }
}

abstract class _PatientModel extends PatientModel {
  const factory _PatientModel({
    required final String id,
    required final String userId,
    required final String firstName,
    required final String lastName,
    required final String gender,
    required final DateTime dateOfBirth,
    final String? bloodGroup,
    final String? address,
    final String? emergencyContactName,
    final String? emergencyContactPhone,
    final String? insuranceProvider,
    final String? insurancePolicyNumber,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$PatientModelImpl;
  const _PatientModel._() : super._();

  factory _PatientModel.fromJson(Map<String, dynamic> json) =
      _$PatientModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String get gender;
  @override
  DateTime get dateOfBirth;
  @override
  String? get bloodGroup;
  @override
  String? get address;
  @override
  String? get emergencyContactName;
  @override
  String? get emergencyContactPhone;
  @override
  String? get insuranceProvider;
  @override
  String? get insurancePolicyNumber;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of PatientModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PatientModelImplCopyWith<_$PatientModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
