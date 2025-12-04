import 'package:flutter/material.dart';
import 'package:todo_app/database/databse_helper.dart';
import '../models/todo_model.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import '../utils/date_formatter.dart';
import '../widgets/priority_badge.dart';
import '../widgets/category_chip.dart';

class AddEditTodoScreen extends StatefulWidget {
  final TodoModel? todo;

  const AddEditTodoScreen({super.key, this.todo});

  @override
  State<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedPriority = 'medium';
  String _selectedCategory = 'kuliah';
  bool _isLoading = false;

  bool get _isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.todo!.title;
      _descriptionController.text = widget.todo!.description ?? '';
      _selectedDeadline = widget.todo!.deadline;
      _selectedTime = TimeOfDay.fromDateTime(widget.todo!.deadline);
      _selectedPriority = widget.todo!.priority;
      _selectedCategory = widget.todo!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final deadline = DateTime(
      _selectedDeadline.year,
      _selectedDeadline.month,
      _selectedDeadline.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    try {
      if (_isEditing) {
        final updated = widget.todo!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          deadline: deadline,
          priority: _selectedPriority,
          category: _selectedCategory,
        );
        await _dbHelper.update(updated);
      } else {
        final newTodo = TodoModel(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          deadline: deadline,
          priority: _selectedPriority,
          category: _selectedCategory,
        );
        await _dbHelper.create(newTodo);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Tugas berhasil diupdate' : 'Tugas berhasil ditambahkan',
              style: AppTextStyles.bodyMedium,
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e', style: AppTextStyles.bodyMedium),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleField(),
                        const SizedBox(height: 20),
                        _buildDescriptionField(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Kategori'),
                        const SizedBox(height: 12),
                        CategorySelector(
                          selectedCategory: _selectedCategory,
                          onCategoryChanged: (category) {
                            setState(() => _selectedCategory = category);
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Prioritas'),
                        const SizedBox(height: 12),
                        PrioritySelector(
                          selectedPriority: _selectedPriority,
                          onPriorityChanged: (priority) {
                            setState(() => _selectedPriority = priority);
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Deadline'),
                        const SizedBox(height: 12),
                        _buildDateTimePickers(),
                        const SizedBox(height: 32),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _isEditing ? 'Edit Tugas' : 'Tambah Tugas',
            style: AppTextStyles.h3,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h4,
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextFormField(
        controller: _titleController,
        decoration: InputDecoration(
          labelText: 'Judul Tugas',
          labelStyle: AppTextStyles.label,
          hintText: 'Masukkan judul tugas',
          hintStyle: AppTextStyles.hint,
          prefixIcon: const Icon(Icons.title_rounded, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.white,
        ),
        style: AppTextStyles.bodyMedium,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Judul tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: 'Deskripsi (Opsional)',
          labelStyle: AppTextStyles.label,
          hintText: 'Tambahkan detail tugas...',
          hintStyle: AppTextStyles.hint,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(bottom: 60),
            child: Icon(Icons.description_rounded, color: AppColors.primary),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.white,
        ),
        style: AppTextStyles.bodyMedium,
      ),
    );
  }

  Widget _buildDateTimePickers() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text('Tanggal', style: AppTextStyles.label),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormatter.formatDate(_selectedDeadline),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: _selectTime,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text('Waktu', style: AppTextStyles.label),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedTime.format(context),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTodo,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                _isEditing ? 'Update Tugas' : 'Simpan Tugas',
                style: AppTextStyles.button,
              ),
      ),
    );
  }
}