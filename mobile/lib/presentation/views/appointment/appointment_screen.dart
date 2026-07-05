import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:patient_management_app/domain/entities/appointment_entity.dart';
import 'package:patient_management_app/presentation/providers/appointment_provider.dart';
import 'package:patient_management_app/presentation/theme/app_colors.dart';
import 'package:patient_management_app/presentation/theme/app_text_styles.dart';
import 'package:patient_management_app/core/widgets/loading_widget.dart';
import 'package:patient_management_app/presentation/providers/doctor_provider.dart';
import 'package:patient_management_app/presentation/providers/patient_provider.dart';
import 'package:patient_management_app/presentation/providers/auth_provider.dart';
import 'package:patient_management_app/core/network/dio_client.dart';

class AppointmentScreen extends ConsumerStatefulWidget {
  const AppointmentScreen({super.key});

  @override
  ConsumerState<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends ConsumerState<AppointmentScreen> {
  final List<String> _statusFilters = [
    'All',
    'Scheduled',
    'PendingPayment',
    'Completed',
    'Cancelled',
  ];
  String _selectedFilter = 'All';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appointmentViewModelProvider.notifier).fetchAppointments();
      final currentUser = ref.read(currentUserProvider);
      if (currentUser?.role != 'Patient') {
        ref.read(patientViewModelProvider.notifier).fetchPatients();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentViewModelProvider);
    final isLoading = ref.watch(appointmentLoadingProvider);
    final error = ref.watch(appointmentErrorProvider);

    List<AppointmentEntity> filteredAppointments = appointmentState.appointments
        .where((appointment) {
          final matchesStatus =
              _selectedFilter == 'All' || appointment.status == _selectedFilter;
          final matchesDate =
              _selectedDate == null ||
              appointment.appointmentDate.year == _selectedDate!.year &&
                  appointment.appointmentDate.month == _selectedDate!.month &&
                  appointment.appointmentDate.day == _selectedDate!.day;
          return matchesStatus && matchesDate;
        })
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 26, color: AppColors.primary),
            onPressed: () => _showCreateAppointmentDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(context),
          Expanded(
            child: _buildContent(
              isLoading: isLoading,
              error: error,
              appointments: filteredAppointments,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _statusFilters.length,
                    itemBuilder: (context, index) {
                      final filter = _statusFilters[index];
                      final isSelected = _selectedFilter == filter;
                      final filterColor = _getStatusColor(filter);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          showCheckmark: false,
                          label: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: isSelected ? filterColor : Colors.transparent,
                          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : (isDark ? AppColors.borderDark : AppColors.border),
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _selectedDate != null
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : (isDark ? AppColors.surfaceDark : AppColors.surface),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedDate != null
                          ? AppColors.primary
                          : (isDark ? AppColors.borderDark : AppColors.border),
                    ),
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: _selectedDate != null ? AppColors.primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          if (_selectedDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE, dd MMM yyyy').format(_selectedDate!),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = null;
                      });
                    },
                    child: const Icon(Icons.close, color: AppColors.primary, size: 16),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent({
    required bool isLoading,
    required String? error,
    required List<AppointmentEntity> appointments,
  }) {
    if (isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(appointmentViewModelProvider.notifier)
                    .fetchAppointments();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (appointments.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments found',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to schedule an appointment',
              style: AppTextStyles.bodyMedium.copyWith(
                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _AppointmentCard(appointment: appointment);
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showCreateAppointmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateAppointmentDialog(),
    );
  }
}

class _AppointmentCard extends ConsumerWidget {
  final AppointmentEntity appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor(appointment.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAppointmentDetails(context, appointment),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getStatusIcon(appointment.status), size: 14, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            appointment.status.toUpperCase(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      appointment.formattedTime,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  appointment.reason,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(Icons.person_outline, appointment.patientName),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.medical_services_outlined, appointment.doctorName),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.withValues(alpha: 0.1)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      appointment.formattedDate,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                  ],
                ),
                if (appointment.status == 'PendingPayment') ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.payment, size: 16),
                      label: const Text('Pay Now to Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () => _showPaymentDialog(context, appointment),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }



  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Scheduled':
        return Icons.schedule;
      case 'Completed':
        return Icons.check_circle;
      case 'Cancelled':
        return Icons.cancel;
      default:
        return Icons.calendar_today;
    }
  }

  void _showAppointmentDetails(BuildContext context, AppointmentEntity appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AppointmentDetailsSheet(
        appointment: appointment,
        onPayNowPressed: () {
          Navigator.pop(context);
          _showPaymentDialog(context, appointment);
        },
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, AppointmentEntity appointment) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PaymentDialog(appointment: appointment),
    );
  }
}

class _PaymentDialog extends ConsumerStatefulWidget {
  final AppointmentEntity appointment;
  const _PaymentDialog({required this.appointment});

  @override
  ConsumerState<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<_PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _cardNameController = TextEditingController();

  Map<String, dynamic>? _associatedInvoice;
  bool _isLoadingInvoice = true;
  String? _invoiceError;
  bool _isProcessing = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _cardNameController.text = widget.appointment.patientName;
    _fetchInvoice();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchInvoice() async {
    setState(() {
      _isLoadingInvoice = true;
      _invoiceError = null;
    });

    try {
      final res = await DioClient().get('/Billing/invoices');
      if (res.statusCode == 200) {
        final List<dynamic> data = res.data['data'] ?? [];
        final invoice = data.firstWhere(
          (inv) => inv['appointmentId'] == widget.appointment.id,
          orElse: () => null,
        );

        if (invoice != null) {
          setState(() {
            _associatedInvoice = invoice;
            _isLoadingInvoice = false;
          });
        } else {
          setState(() {
            _invoiceError = 'Invoice not found for this appointment.';
            _isLoadingInvoice = false;
          });
        }
      } else {
        setState(() {
          _invoiceError = 'Failed to fetch invoice. Status: ${res.statusCode}';
          _isLoadingInvoice = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _invoiceError = 'Could not load payment information.';
        _isLoadingInvoice = false;
      });
    }
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate() || _associatedInvoice == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 1500));

      final invoiceId = _associatedInvoice!['id'];
      final res = await DioClient().post('/Billing/invoices/$invoiceId/pay');

      if (res.statusCode == 200 || res.statusCode == 204) {
        setState(() {
          _isSuccess = true;
        });

        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          Navigator.pop(context);
          ref.read(appointmentViewModelProvider.notifier).fetchAppointments();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed. Status: ${res.statusCode}')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment processing error. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInvoice) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Retrieving billing details...', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    if (_invoiceError != null || _associatedInvoice == null) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                _invoiceError ?? 'Invoice not found.',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final double amount = (_associatedInvoice!['amount'] as num).toDouble();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: _isSuccess
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Payment Successful!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your appointment has been confirmed.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SECURE CHECKOUT',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Pay Invoice',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _isProcessing ? null : () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Card Preview
                      Container(
                        height: 180,
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2E2A75), Color(0xFF1E6E77)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'CLINICAL CARE PAY',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const Icon(Icons.credit_card, color: Colors.white, size: 24),
                              ],
                            ),
                            ListenableBuilder(
                              listenable: _cardNumberController,
                              builder: (context, _) {
                                final text = _cardNumberController.text;
                                return Text(
                                  text.isEmpty ? '•••• •••• •••• ••••' : text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    letterSpacing: 2,
                                    fontFamily: 'monospace',
                                  ),
                                );
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CARD HOLDER',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      ListenableBuilder(
                                        listenable: _cardNameController,
                                        builder: (context, _) {
                                          final text = _cardNameController.text;
                                          return Text(
                                            text.isEmpty ? 'JOHN PATIENT' : text.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'EXPIRES',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    ListenableBuilder(
                                      listenable: _cardExpiryController,
                                      builder: (context, _) {
                                        final text = _cardExpiryController.text;
                                        return Text(
                                          text.isEmpty ? 'MM/YY' : text,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Card Number',
                          prefixIcon: const Icon(Icons.credit_card_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        maxLength: 19,
                        buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                        validator: (value) => value == null || value.length < 16 ? 'Invalid Card Number' : null,
                        onChanged: (value) {
                          final digits = value.replaceAll(RegExp(r'\D'), '');
                          final formatted = RegExp(r'.{1,4}').allMatches(digits).map((m) => m.group(0)).join(' ');
                          if (formatted != _cardNumberController.text) {
                            _cardNumberController.text = formatted;
                            _cardNumberController.selection = TextSelection.fromPosition(
                              TextSelection.fromPosition(TextPosition(offset: formatted.length)).base,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cardExpiryController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Expiry Date',
                                hintText: 'MM/YY',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              maxLength: 5,
                              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                              validator: (value) => value == null || value.length < 5 ? 'Required' : null,
                              onChanged: (value) {
                                final digits = value.replaceAll(RegExp(r'\D'), '');
                                String formatted = digits;
                                if (digits.length > 2) {
                                  formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
                                }
                                if (formatted != _cardExpiryController.text) {
                                  _cardExpiryController.text = formatted;
                                  _cardExpiryController.selection = TextSelection.fromPosition(
                                    TextSelection.fromPosition(TextPosition(offset: formatted.length)).base,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _cardCvvController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'CVV Code',
                                hintText: '123',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              maxLength: 3,
                              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                              validator: (value) => value == null || value.length < 3 ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _cardNameController,
                        decoration: InputDecoration(
                          labelText: 'Cardholder Name',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _submitPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Confirm \$${amount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class CreateAppointmentDialog extends ConsumerStatefulWidget {
  final String? patientId;
  final String? doctorId;
  const CreateAppointmentDialog({super.key, this.patientId, this.doctorId});

  @override
  ConsumerState<CreateAppointmentDialog> createState() =>
      _CreateAppointmentDialogState();
}

class _CreateAppointmentDialogState
    extends ConsumerState<CreateAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  
  String? _selectedDoctorId;
  String? _selectedPatientId;

  List<dynamic> _availableSlots = [];
  bool _isLoadingSlots = false;
  String? _slotError;
  int? _selectedSlotIndex;
  int _currentStep = 0; // 0 = Date & Slot, 1 = Reason & Notes

  Future<void> _fetchAvailableSlots() async {
    if (_selectedDoctorId == null || _selectedDate == null) return;
    
    setState(() {
      _isLoadingSlots = true;
      _slotError = null;
      _availableSlots = [];
      _selectedSlotIndex = null;
      _selectedStartTime = null;
      _selectedEndTime = null;
    });

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final res = await DioClient().get('/doctors/$_selectedDoctorId/slots', queryParameters: {'date': formattedDate});
      if (res.statusCode == 200) {
        final data = res.data['data'] as List<dynamic>;
        setState(() {
          _availableSlots = data;
        });
      } else {
        setState(() => _slotError = 'Failed to load slots');
      }
    } catch (e) {
      print(e);
      setState(() => _slotError = 'Error fetching slots');
    } finally {
      setState(() => _isLoadingSlots = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.patientId;
    _selectedDoctorId = widget.doctorId;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(appointmentViewModelProvider.notifier).clearError();
        if (_selectedDoctorId != null && _selectedDate != null) {
          _fetchAvailableSlots();
        }
      }
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _createAppointment() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedStartTime != null &&
        _selectedEndTime != null &&
        _selectedDoctorId != null &&
        _selectedPatientId != null) {
      
      final appointment = CreateAppointmentEntity(
        doctorId: _selectedDoctorId!,
        patientId: _selectedPatientId!,
        reason: _reasonController.text,
        appointmentDate: _selectedDate!,
        startTime: _selectedStartTime!,
        endTime: _selectedEndTime!,
        notes: _notesController.text,
      );

      await ref
          .read(appointmentViewModelProvider.notifier)
          .createAppointment(appointment);
      
      if (mounted) {
        final error = ref.read(appointmentErrorProvider);
        if (error == null) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorsProvider);
    final patientState = ref.watch(patientViewModelProvider);
    final currentUser = ref.watch(currentUserProvider);
    final myProfileAsync = ref.watch(myPatientProfileProvider);
    final error = ref.watch(appointmentErrorProvider);
    final isLoading = ref.watch(appointmentLoadingProvider);

    if (currentUser?.role == 'Doctor' && _selectedDoctorId == null) {
      _selectedDoctorId = currentUser?.id;
    }

    if (currentUser?.role == 'Patient' && _selectedPatientId == null) {
      myProfileAsync.whenData((profile) {
        setState(() => _selectedPatientId = profile.id);
      });
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule Slot',
                          style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentStep == 0 ? 'Step 1: Choose Slot' : 'Step 2: Patient Info',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Sleek progress bar indicator
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _currentStep == 1 
                              ? AppColors.primary 
                              : (isDark ? AppColors.borderDark : AppColors.border),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Step 0: Select Doctor, Date, and Available Slots
                if (_currentStep == 0) ...[
                  if (currentUser?.role != 'Doctor' && widget.doctorId == null) ...[
                    doctorsAsync.when(
                      data: (doctors) => DropdownButtonFormField<String>(
                        value: _selectedDoctorId,
                        decoration: InputDecoration(
                          labelText: 'Doctor',
                          prefixIcon: const Icon(Icons.medical_services_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        items: doctors.map((d) => DropdownMenuItem(
                          value: d.id,
                          child: Text('Dr. ${d.lastName}'),
                        )).toList(),
                        onChanged: (val) {
                          setState(() => _selectedDoctorId = val);
                          _fetchAvailableSlots();
                        },
                        validator: (val) => val == null ? 'Required' : null,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, s) => const Text('Error loading doctors'),
                    ),
                    const SizedBox(height: 20),
                  ],

                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Select Date',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    controller: TextEditingController(
                      text: _selectedDate != null ? DateFormat('EEEE, MMM d, yyyy').format(_selectedDate!) : '',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => _selectedDate = date);
                        _fetchAvailableSlots();
                      }
                    },
                    validator: (val) => _selectedDate == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),

                  _buildSlotsSection(),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_selectedDate != null && _selectedSlotIndex != null)
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _currentStep = 1);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Next: Patient Details', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],

                // Step 1: Reason and Other info
                if (_currentStep == 1) ...[
                  TextFormField(
                    controller: _reasonController,
                    decoration: InputDecoration(
                      labelText: 'Reason',
                      hintText: 'e.g. Regular Checkup',
                      prefixIcon: const Icon(Icons.info_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),

                  if (currentUser?.role != 'Doctor' && currentUser?.role != 'Patient' && widget.patientId == null) ...[
                    DropdownButtonFormField<String>(
                      value: _selectedPatientId,
                      decoration: InputDecoration(
                        labelText: 'Patient',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      items: patientState.patients.map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.fullName),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedPatientId = val),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (currentUser?.role == 'Patient') ...[
                    myProfileAsync.when(
                      data: (profile) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Patient', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                                Text(profile.fullName, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, s) => const Text('Error loading profile'),
                    ),
                    const SizedBox(height: 20),
                  ],

                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      prefixIcon: const Icon(Icons.notes_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _currentStep = 0),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, size: 16),
                              SizedBox(width: 8),
                              Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _createAppointment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Confirm Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlotsSection() {
    if (_selectedDoctorId == null || _selectedDate == null) {
      return const SizedBox.shrink();
    }

    if (_isLoadingSlots) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_slotError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          _slotError!,
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      );
    }

    if (_availableSlots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'No available slots on this day. Please choose another date.',
          style: TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Slots',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_availableSlots.length, (index) {
            final slot = _availableSlots[index];
            final startTimeStr = slot['startTime'] as String;
            final endTimeStr = slot['endTime'] as String;
            final isAvailable = slot['isAvailable'] as bool;
            
            // Format start and end times to 12-hour AM/PM format (e.g. 9:00 AM)
            final startParts = startTimeStr.split(':');
            final endParts = endTimeStr.split(':');
            final startHour = int.parse(startParts[0]);
            final startMinute = int.parse(startParts[1]);
            final endHour = int.parse(endParts[0]);
            final endMinute = int.parse(endParts[1]);
            
            final startPeriod = startHour >= 12 ? 'PM' : 'AM';
            final displayStartHour = startHour > 12 ? startHour - 12 : (startHour == 0 ? 12 : startHour);
            final startFormatted = '$displayStartHour:${startMinute.toString().padLeft(2, '0')} $startPeriod';

            final endPeriod = endHour >= 12 ? 'PM' : 'AM';
            final displayEndHour = endHour > 12 ? endHour - 12 : (endHour == 0 ? 12 : endHour);
            final endFormatted = '$displayEndHour:${endMinute.toString().padLeft(2, '0')} $endPeriod';

            final slotLabel = '$startFormatted - $endFormatted';
            final isSelected = _selectedSlotIndex == index;

            return ChoiceChip(
              showCheckmark: false,
              label: Text(
                slotLabel,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isAvailable ? AppColors.primary : Colors.grey),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: isAvailable 
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected 
                      ? Colors.transparent 
                      : (isAvailable ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent),
                ),
              ),
              onSelected: isAvailable ? (selected) {
                setState(() {
                  if (selected) {
                    _selectedSlotIndex = index;
                    _selectedStartTime = TimeOfDay(hour: startHour, minute: startMinute);
                    _selectedEndTime = TimeOfDay(hour: endHour, minute: endMinute);
                  } else {
                    _selectedSlotIndex = null;
                    _selectedStartTime = null;
                    _selectedEndTime = null;
                  }
                });
              } : null,
            );
          }),
        ),
      ],
    );
  }
}

class _AppointmentDetailsSheet extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback onPayNowPressed;

  const _AppointmentDetailsSheet({
    required this.appointment,
    required this.onPayNowPressed,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(appointment.status);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Appointment Details',
                    style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.status,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildDetailSection(
              Icons.info_outline,
              'Reason',
              appointment.reason,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildDetailSection(
                    Icons.calendar_today_outlined,
                    'Date',
                    appointment.formattedDate,
                  ),
                ),
                Expanded(
                  child: _buildDetailSection(
                    Icons.access_time_outlined,
                    'Time',
                    '${appointment.formattedTime} - ${appointment.endTime.format(context)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailSection(
              Icons.person_outline,
              'Patient',
              appointment.patientName,
            ),
            const SizedBox(height: 24),
            _buildDetailSection(
              Icons.medical_services_outlined,
              'Doctor',
              appointment.doctorName,
            ),
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildDetailSection(
                Icons.notes_outlined,
                'Notes',
                appointment.notes!,
              ),
            ],
            Row(
              children: [
                if (appointment.status == 'Scheduled') ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Implement cancel
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (appointment.status == 'PendingPayment') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.payment),
                      label: const Text('Pay Now to Confirm'),
                      onPressed: onPayNowPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

Color _getStatusColor(String status) {
  switch (status) {
    case 'Scheduled':
      return AppColors.warning;
    case 'Completed':
      return AppColors.success;
    case 'Cancelled':
      return AppColors.error;
    default:
      return AppColors.textSecondary;
  }
}
