// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdminStatsModelImpl _$$AdminStatsModelImplFromJson(
  Map<String, dynamic> json,
) => _$AdminStatsModelImpl(
  totalUsers: (json['totalUsers'] as num).toInt(),
  activeUsers: (json['activeUsers'] as num).toInt(),
  totalPatients: (json['totalPatients'] as num).toInt(),
  totalDoctors: (json['totalDoctors'] as num).toInt(),
  totalNurses: (json['totalNurses'] as num).toInt(),
  totalAppointments: (json['totalAppointments'] as num).toInt(),
  upcomingAppointments: (json['upcomingAppointments'] as num).toInt(),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  paidInvoicesCount: (json['paidInvoicesCount'] as num).toInt(),
  unpaidInvoicesCount: (json['unpaidInvoicesCount'] as num).toInt(),
);

Map<String, dynamic> _$$AdminStatsModelImplToJson(
  _$AdminStatsModelImpl instance,
) => <String, dynamic>{
  'totalUsers': instance.totalUsers,
  'activeUsers': instance.activeUsers,
  'totalPatients': instance.totalPatients,
  'totalDoctors': instance.totalDoctors,
  'totalNurses': instance.totalNurses,
  'totalAppointments': instance.totalAppointments,
  'upcomingAppointments': instance.upcomingAppointments,
  'totalRevenue': instance.totalRevenue,
  'paidInvoicesCount': instance.paidInvoicesCount,
  'unpaidInvoicesCount': instance.unpaidInvoicesCount,
};
