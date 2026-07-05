// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AuthResponseModel {
  UserModel get user => throw _privateConstructorUsedError;
  String get token => throw _privateConstructorUsedError;
  @JsonKey(name: 'tokenExpires')
  DateTime get tokenExpires => throw _privateConstructorUsedError;
  @JsonKey(name: 'refreshToken')
  String get refreshToken => throw _privateConstructorUsedError;
  @JsonKey(name: 'refreshTokenExpires')
  DateTime get refreshTokenExpires => throw _privateConstructorUsedError;

  /// Create a copy of AuthResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResponseModelCopyWith<AuthResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResponseModelCopyWith<$Res> {
  factory $AuthResponseModelCopyWith(
    AuthResponseModel value,
    $Res Function(AuthResponseModel) then,
  ) = _$AuthResponseModelCopyWithImpl<$Res, AuthResponseModel>;
  @useResult
  $Res call({
    UserModel user,
    String token,
    @JsonKey(name: 'tokenExpires') DateTime tokenExpires,
    @JsonKey(name: 'refreshToken') String refreshToken,
    @JsonKey(name: 'refreshTokenExpires') DateTime refreshTokenExpires,
  });

  $UserModelCopyWith<$Res> get user;
}

/// @nodoc
class _$AuthResponseModelCopyWithImpl<$Res, $Val extends AuthResponseModel>
    implements $AuthResponseModelCopyWith<$Res> {
  _$AuthResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? token = null,
    Object? tokenExpires = null,
    Object? refreshToken = null,
    Object? refreshTokenExpires = null,
  }) {
    return _then(
      _value.copyWith(
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as UserModel,
            token: null == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String,
            tokenExpires: null == tokenExpires
                ? _value.tokenExpires
                : tokenExpires // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            refreshToken: null == refreshToken
                ? _value.refreshToken
                : refreshToken // ignore: cast_nullable_to_non_nullable
                      as String,
            refreshTokenExpires: null == refreshTokenExpires
                ? _value.refreshTokenExpires
                : refreshTokenExpires // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of AuthResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get user {
    return $UserModelCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthResponseModelImplCopyWith<$Res>
    implements $AuthResponseModelCopyWith<$Res> {
  factory _$$AuthResponseModelImplCopyWith(
    _$AuthResponseModelImpl value,
    $Res Function(_$AuthResponseModelImpl) then,
  ) = __$$AuthResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    UserModel user,
    String token,
    @JsonKey(name: 'tokenExpires') DateTime tokenExpires,
    @JsonKey(name: 'refreshToken') String refreshToken,
    @JsonKey(name: 'refreshTokenExpires') DateTime refreshTokenExpires,
  });

  @override
  $UserModelCopyWith<$Res> get user;
}

/// @nodoc
class __$$AuthResponseModelImplCopyWithImpl<$Res>
    extends _$AuthResponseModelCopyWithImpl<$Res, _$AuthResponseModelImpl>
    implements _$$AuthResponseModelImplCopyWith<$Res> {
  __$$AuthResponseModelImplCopyWithImpl(
    _$AuthResponseModelImpl _value,
    $Res Function(_$AuthResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? token = null,
    Object? tokenExpires = null,
    Object? refreshToken = null,
    Object? refreshTokenExpires = null,
  }) {
    return _then(
      _$AuthResponseModelImpl(
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as UserModel,
        token: null == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String,
        tokenExpires: null == tokenExpires
            ? _value.tokenExpires
            : tokenExpires // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        refreshToken: null == refreshToken
            ? _value.refreshToken
            : refreshToken // ignore: cast_nullable_to_non_nullable
                  as String,
        refreshTokenExpires: null == refreshTokenExpires
            ? _value.refreshTokenExpires
            : refreshTokenExpires // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$AuthResponseModelImpl extends _AuthResponseModel {
  const _$AuthResponseModelImpl({
    required this.user,
    required this.token,
    @JsonKey(name: 'tokenExpires') required this.tokenExpires,
    @JsonKey(name: 'refreshToken') required this.refreshToken,
    @JsonKey(name: 'refreshTokenExpires') required this.refreshTokenExpires,
  }) : super._();

  @override
  final UserModel user;
  @override
  final String token;
  @override
  @JsonKey(name: 'tokenExpires')
  final DateTime tokenExpires;
  @override
  @JsonKey(name: 'refreshToken')
  final String refreshToken;
  @override
  @JsonKey(name: 'refreshTokenExpires')
  final DateTime refreshTokenExpires;

  @override
  String toString() {
    return 'AuthResponseModel(user: $user, token: $token, tokenExpires: $tokenExpires, refreshToken: $refreshToken, refreshTokenExpires: $refreshTokenExpires)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResponseModelImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.tokenExpires, tokenExpires) ||
                other.tokenExpires == tokenExpires) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.refreshTokenExpires, refreshTokenExpires) ||
                other.refreshTokenExpires == refreshTokenExpires));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    user,
    token,
    tokenExpires,
    refreshToken,
    refreshTokenExpires,
  );

  /// Create a copy of AuthResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResponseModelImplCopyWith<_$AuthResponseModelImpl> get copyWith =>
      __$$AuthResponseModelImplCopyWithImpl<_$AuthResponseModelImpl>(
        this,
        _$identity,
      );
}

abstract class _AuthResponseModel extends AuthResponseModel {
  const factory _AuthResponseModel({
    required final UserModel user,
    required final String token,
    @JsonKey(name: 'tokenExpires') required final DateTime tokenExpires,
    @JsonKey(name: 'refreshToken') required final String refreshToken,
    @JsonKey(name: 'refreshTokenExpires')
    required final DateTime refreshTokenExpires,
  }) = _$AuthResponseModelImpl;
  const _AuthResponseModel._() : super._();

  @override
  UserModel get user;
  @override
  String get token;
  @override
  @JsonKey(name: 'tokenExpires')
  DateTime get tokenExpires;
  @override
  @JsonKey(name: 'refreshToken')
  String get refreshToken;
  @override
  @JsonKey(name: 'refreshTokenExpires')
  DateTime get refreshTokenExpires;

  /// Create a copy of AuthResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResponseModelImplCopyWith<_$AuthResponseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
