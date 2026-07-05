// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:patient_management_app/domain/entities/admin_stats_entity.dart';

part 'admin_stats_model.freezed.dart';
part 'admin_stats_model.g.dart';

@freezed
class AdminStatsModel with _$AdminStatsModel {
  const AdminStatsModel._();

  const factory AdminStatsModel({
    required int totalUsers,
    required int activeUsers,
    required int totalPatients,
    required int totalDoctors,
    required int totalNurses,
    required int totalAppointments,
    required int upcomingAppointments,
    required double totalRevenue,
    required int paidInvoicesCount,
    required int unpaidInvoicesCount,
  }) = _AdminStatsModel;

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) =>
      _$AdminStatsModelFromJson(json);

  AdminStatsEntity toEntity() {
    return AdminStatsEntity(
      totalUsers: totalUsers,
      activeUsers: activeUsers,
      totalPatients: totalPatients,
      totalDoctors: totalDoctors,
      totalNurses: totalNurses,
      totalAppointments: totalAppointments,
      upcomingAppointments: upcomingAppointments,
      totalRevenue: totalRevenue,
      paidInvoicesCount: paidInvoicesCount,
      unpaidInvoicesCount: unpaidInvoicesCount,
    );
  }
}
