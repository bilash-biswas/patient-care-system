import 'package:equatable/equatable.dart';

class AdminStatsEntity extends Equatable {
  final int totalUsers;
  final int activeUsers;
  final int totalPatients;
  final int totalDoctors;
  final int totalNurses;
  final int totalAppointments;
  final int upcomingAppointments;
  final double totalRevenue;
  final int paidInvoicesCount;
  final int unpaidInvoicesCount;

  const AdminStatsEntity({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalPatients,
    required this.totalDoctors,
    required this.totalNurses,
    required this.totalAppointments,
    required this.upcomingAppointments,
    required this.totalRevenue,
    required this.paidInvoicesCount,
    required this.unpaidInvoicesCount,
  });

  @override
  List<Object?> get props => [
        totalUsers,
        activeUsers,
        totalPatients,
        totalDoctors,
        totalNurses,
        totalAppointments,
        upcomingAppointments,
        totalRevenue,
        paidInvoicesCount,
        unpaidInvoicesCount,
      ];
}
