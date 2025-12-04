import 'package:flutter/material.dart';
import 'package:todo_app/database/databse_helper.dart';
import '../models/todo_model.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';
import '../widgets/todo_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/category_chip.dart';
import 'add_edit_todo_screen.dart';
import 'todo_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<TodoModel> _todos = [];
  List<TodoModel> _filteredTodos = [];
  String _selectedFilter = 'all'; // all, today, pending, completed
  String _selectedCategory = 'all';
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadTodos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) return;
    
    setState(() {
      switch (_tabController.index) {
        case 0:
          _selectedFilter = 'all';
          break;
        case 1:
          _selectedFilter = 'today';
          break;
        case 2:
          _selectedFilter = 'pending';
          break;
        case 3:
          _selectedFilter = 'completed';
          break;
      }
      _filterTodos();
    });
  }

  Future<void> _loadTodos() async {
    setState(() => _isLoading = true);
    
    final todos = await _dbHelper.readAllTodos();
    
    setState(() {
      _todos = todos;
      _filterTodos();
      _isLoading = false;
    });
  }

  void _filterTodos() {
    List<TodoModel> filtered = List.from(_todos);

    // Filter by tab
    switch (_selectedFilter) {
      case 'today':
        final now = DateTime.now();
        filtered = filtered.where((todo) {
          return todo.deadline.year == now.year &&
              todo.deadline.month == now.month &&
              todo.deadline.day == now.day &&
              !todo.isCompleted;
        }).toList();
        break;
      case 'pending':
        filtered = filtered.where((todo) => !todo.isCompleted).toList();
        break;
      case 'completed':
        filtered = filtered.where((todo) => todo.isCompleted).toList();
        break;
    }

    // Filter by category
    if (_selectedCategory != 'all') {
      filtered = filtered.where((todo) => todo.category == _selectedCategory).toList();
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((todo) {
        return todo.title.toLowerCase().contains(query) ||
            (todo.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    setState(() => _filteredTodos = filtered);
  }

  Future<void> _toggleComplete(TodoModel todo) async {
    final updated = todo.copyWith(
      isCompleted: !todo.isCompleted,
      status: !todo.isCompleted ? 'completed' : 'pending',
    );
    await _dbHelper.update(updated);
    _loadTodos();
  }

  Future<void> _deleteTodo(TodoModel todo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Tugas', style: AppTextStyles.h4),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${todo.title}"?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Hapus', style: AppTextStyles.button),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbHelper.delete(todo.id!);
      _loadTodos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tugas berhasil dihapus', style: AppTextStyles.bodyMedium),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _navigateToAddTodo() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditTodoScreen()),
    );
    if (result == true) _loadTodos();
  }

  void _navigateToEditTodo(TodoModel todo) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTodoScreen(todo: todo),
      ),
    );
    if (result == true) _loadTodos();
  }

  void _navigateToDetail(TodoModel todo) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoDetailScreen(todo: todo),
      ),
    );
    if (result == true) _loadTodos();
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
              _buildHeader(),
              _buildSearchBar(),
              _buildCategoryFilter(),
              _buildTabBar(),
              Expanded(child: _buildTodoList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddTodo,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: Text('Tambah', style: AppTextStyles.button),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Todo App', style: AppTextStyles.h2),
              const SizedBox(height: 4),
              FutureBuilder<Map<String, int>>(
                future: _dbHelper.getStatistics(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final stats = snapshot.data!;
                  return Text(
                    '${stats['completed']}/${stats['total']} selesai',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  );
                },
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
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
            child: Icon(Icons.person_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _filterTodos(),
        decoration: InputDecoration(
          hintText: 'Cari tugas...',
          hintStyle: AppTextStyles.hint,
          border: InputBorder.none,
          icon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    _filterTodos();
                  },
                )
              : null,
        ),
        style: AppTextStyles.bodyMedium,
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          FilterCategoryChip(
            category: 'all',
            isSelected: _selectedCategory == 'all',
            onTap: () => setState(() {
              _selectedCategory = 'all';
              _filterTodos();
            }),
          ),
          const SizedBox(width: 8),
          FilterCategoryChip(
            category: 'kuliah',
            isSelected: _selectedCategory == 'kuliah',
            onTap: () => setState(() {
              _selectedCategory = 'kuliah';
              _filterTodos();
            }),
          ),
          const SizedBox(width: 8),
          FilterCategoryChip(
            category: 'kerja',
            isSelected: _selectedCategory == 'kerja',
            onTap: () => setState(() {
              _selectedCategory = 'kerja';
              _filterTodos();
            }),
          ),
          const SizedBox(width: 8),
          FilterCategoryChip(
            category: 'pribadi',
            isSelected: _selectedCategory == 'pribadi',
            onTap: () => setState(() {
              _selectedCategory = 'pribadi';
              _filterTodos();
            }),
          ),
          const SizedBox(width: 8),
          FilterCategoryChip(
            category: 'lainnya',
            isSelected: _selectedCategory == 'lainnya',
            onTap: () => setState(() {
              _selectedCategory = 'lainnya';
              _filterTodos();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.tab,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Semua'),
          Tab(text: 'Hari Ini'),
          Tab(text: 'Pending'),
          Tab(text: 'Selesai'),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredTodos.isEmpty) {
      if (_searchController.text.isNotEmpty) {
        return NoSearchResultsEmpty(searchQuery: _searchController.text);
      }
      
      switch (_selectedFilter) {
        case 'today':
          return const NoTodayTodosEmpty();
        case 'completed':
          return _todos.where((t) => t.isCompleted).isEmpty
              ? NoTodosEmpty(onAddPressed: _navigateToAddTodo)
              : const AllCompletedEmpty();
        default:
          return NoTodosEmpty(onAddPressed: _navigateToAddTodo);
      }
    }

    return RefreshIndicator(
      onRefresh: _loadTodos,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _filteredTodos.length,
        itemBuilder: (context, index) {
          final todo = _filteredTodos[index];
          return TodoCard(
            todo: todo,
            onTap: () => _navigateToDetail(todo),
            onComplete: () => _toggleComplete(todo),
            onDelete: () => _deleteTodo(todo),
            onEdit: () => _navigateToEditTodo(todo),
          );
        },
      ),
    );
  }
}