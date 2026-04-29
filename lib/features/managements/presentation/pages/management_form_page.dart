import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:sync_app/core/theme/app_colors.dart';
import 'package:sync_app/core/widgets/app_primary_button.dart';
import 'package:sync_app/features/managements/application/cubit/management_form_cubit.dart';
import 'package:sync_app/features/managements/application/cubit/management_form_state.dart';

class ManagementFormPage extends StatefulWidget {
  final String? localId;

  const ManagementFormPage({super.key, this.localId});

  @override
  State<ManagementFormPage> createState() => _ManagementFormPageState();
}

class _ManagementFormPageState extends State<ManagementFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  DateTime? _selectedDate;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    if (widget.localId != null) {
      BlocProvider.of<ManagementFormCubit>(context).loadForEdit(widget.localId!);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryDark,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una fecha.')),
      );
      return;
    }
    BlocProvider.of<ManagementFormCubit>(context).save(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          date: _selectedDate!,
          amount: double.parse(_amountCtrl.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.localId != null;

    return BlocListener<ManagementFormCubit, ManagementFormState>(
      listener: (context, state) {
        if (state is ManagementFormLoaded && !_prefilled) {
          _prefilled = true;
          _titleCtrl.text = state.management.title;
          _descCtrl.text = state.management.description;
          _amountCtrl.text =
              state.management.amount.toStringAsFixed(2);
          setState(() => _selectedDate = state.management.date);
        } else if (state is ManagementFormSuccess) {
          Modular.to.pop();
        } else if (state is ManagementFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.statusFailed,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.primaryDark, size: 20),
            onPressed: () => Modular.to.pop(),
          ),
          title: Text(
            isEditing ? 'Editar gestión' : 'Nueva gestión',
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocBuilder<ManagementFormCubit, ManagementFormState>(
          builder: (context, state) {
            final isLoading = state is ManagementFormLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField(
                      controller: _titleCtrl,
                      label: 'Título',
                      hint: 'Ej. Reunión con cliente',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _descCtrl,
                      label: 'Descripción',
                      hint: 'Detalla la gestión...',
                      maxLines: 3,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    _DateField(
                      selectedDate: _selectedDate,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _amountCtrl,
                      label: 'Monto',
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        final n = double.tryParse(v.trim());
                        if (n == null || n <= 0) {
                          return 'Ingresa un monto mayor a 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    AppPrimaryButton(
                      label: 'Guardar gestión',
                      onPressed: isLoading ? null : _submit,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'Se guardará localmente y se sincronizará cuando haya conexión.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.cardWhite,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primaryDark, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.statusFailed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.statusFailed),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const _DateField({required this.selectedDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Text(
                  selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                      : 'Seleccionar fecha',
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedDate != null
                        ? AppColors.primaryDark
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
