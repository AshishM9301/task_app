import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../../core/constants/app_constants.dart';
import '../../../data/utils/api_service.dart';
import '../../../providers/guest_provider.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_input_field.dart';

class AddTaskScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final Function(Map<String, dynamic>)? onTaskAdded;
  final bool hasNotification;
  final IconData? backButtonIcon;

  const AddTaskScreen({
    super.key,
    this.onBackPressed,
    this.onTaskAdded,
    this.hasNotification = true,
    this.backButtonIcon,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  int _selectedCategoryIndex = 0;
  int _selectedProjectIndex = 0;
  List<dynamic> _taskGroups = [];
  List<String> _categories = ['Work', 'Personal'];
  List<IconData> _categoryIcons = [Icons.work, Icons.person];
  static const _addNewProjectSlug = 'add-new-project';
  List<dynamic> _projects = [];
  bool _isLoadingTaskGroups = true;
  bool _isLoadingProjects = true;
  bool _isInitialLoading = true;

  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTaskGroups();
      _fetchProjects();
    });
  }

  Future<void> _fetchTaskGroups() async {
    try {
      final response = await _apiService.getAllTaskGroups();
      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            _taskGroups = response.data!;
            if (_taskGroups.isNotEmpty) {
              _categories = _taskGroups.map((g) => g['title']?.toString() ?? 'Untitled').toList();
              _categoryIcons = List.generate(_categories.length, (i) => _getCategoryIcon(i));
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching task groups: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTaskGroups = false;
          _checkInitialLoadingComplete();
        });
      }
    }
  }

  Future<void> _fetchProjects() async {
    try {
      final response = await _apiService.getAllProjects();
      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            _projects = response.data!;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching projects: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProjects = false;
          _checkInitialLoadingComplete();
        });
      }
    }
  }

  void _checkInitialLoadingComplete() {
    if (!_isLoadingTaskGroups && !_isLoadingProjects) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  IconData _getCategoryIcon(int index) {
    final icons = [Icons.work, Icons.person, Icons.shopping_bag, Icons.health_and_safety, Icons.code, Icons.school];
    return icons[index % icons.length];
  }

  void _showAddProjectDialog() {
    final controller = TextEditingController();
    bool isLoading = false;

    Future.microtask(() async {
      if (!mounted) return;

      await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Add New Project'),
            content: isLoading
                ? const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Project Name',
                      hintText: 'Enter project name',
                    ),
                    autofocus: true,
                  ),
            actions: isLoading
                ? []
                : [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, 'cancel'),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final name = controller.text.trim();
                        if (name.isEmpty) return;

                        setDialogState(() => isLoading = true);

                        try {
                          final response = await _apiService.createProject(title: name);
                          if (response.success && response.data != null) {
                            setState(() {
                              _projects.add(response.data!);
                              _selectedProjectIndex = _projects.length - 1;
                            });
                            if (mounted) Navigator.pop(dialogContext, 'created');
                          } else {
                            setDialogState(() => isLoading = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(response.message),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          setDialogState(() => isLoading = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
          ),
        ),
      );
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          if (!kIsWeb) {
            _selectedImage = File(image.path);
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.blackColor,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: AppConstants.primaryColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.blackColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppConstants.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppConstants.blackColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _saveTask() async {
    if (_taskNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCategoryIndex >= _taskGroups.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a task group'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final guestProvider = context.read<GuestProvider>();
      if (!guestProvider.hasGuestKey) {
        await guestProvider.initializeGuestKey();
      }

      final taskGroupId = _taskGroups[_selectedCategoryIndex]['id'];
      final isAddNewProject = _selectedProjectIndex >= _projects.length;
      final projectTitle = isAddNewProject
          ? 'Default Project'
          : _projects[_selectedProjectIndex]['title']?.toString() ?? 'Default Project';
      final projectId = isAddNewProject
          ? null
          : _projects[_selectedProjectIndex]['id'];

      final response = await _apiService.createTask(
        title: _taskNameController.text,
        description: _descriptionController.text,
        taskGroupId: taskGroupId as int,
        projectTitle: projectTitle,
        projectId: projectId as int?,
        startedAt: _startDate!,
        endedAt: _endDate!,
        status: 'pending',
      );

      setState(() {
        _isSaving = false;
      });

      if (response.success) {
        final taskData = {
          'category': _categories[_selectedCategoryIndex],
          'categoryIcon': _categoryIcons[_selectedCategoryIndex],
          'projectName': projectTitle,
          'taskName': _taskNameController.text,
          'description': _descriptionController.text,
          'startDate': _startDate,
          'endDate': _endDate,
          'image': _selectedImage,
          'apiResponse': response.data,
        };

        widget.onTaskAdded?.call(taskData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.whiteColor,
      body: SafeArea(
        child: _isInitialLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppConstants.primaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: AppConstants.secondaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCategorySelection(),
                           const SizedBox(height: 16),
                          _buildProjectSelection(),
                          const SizedBox(height: 24),
                          CustomInputField(
                            controller: _taskNameController,
                            label: 'Task Name',
                            hint: 'Enter task name',
                          ),

                          const SizedBox(height: 16),
                          _buildDescriptionField(),
                          const SizedBox(height: 16),
                          _buildDatePickers(),
                          const SizedBox(height: 16),
                          _selectedImageBytes != null
                              ? _buildImagePreview()
                              : _buildImageSection(),
                          const SizedBox(height: 32),
                          _buildSaveButton(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: widget.onBackPressed ?? () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Icon(
                widget.backButtonIcon ?? Icons.arrow_back_ios_new,
                color: AppConstants.primaryColor,
                size: 20,
              ),
            ),
          ),
          const Text(
            "Today's Tasks",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.blackColor,
            ),
          ),
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: const Icon(
                  Icons.notifications,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              if (widget.hasNotification)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppConstants.whiteColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelection() {
    if (_isLoadingTaskGroups) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(
            color: AppConstants.primaryColor,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDropdown(
            label: 'Task Group',
            items: _categories,
            itemIcons: _categoryIcons,
            selectedItem: _categories.isNotEmpty
                ? _categories[_selectedCategoryIndex]
                : null,
            prefixIcon: _categoryIcons.isNotEmpty
                ? _categoryIcons[_selectedCategoryIndex]
                : Icons.work,
            onChanged: (value) {
              setState(() {
                _selectedCategoryIndex = _categories.indexOf(value!);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSelection() {
    if (_isLoadingProjects) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(
            color: AppConstants.primaryColor,
          ),
        ),
      );
    }

    final displayProjects = [
      ..._projects,
      {'title': 'Add New Project', 'slug': _addNewProjectSlug},
    ];
    final displayTitles = displayProjects.map((p) => p['title']?.toString() ?? '').toList();
    final displayIcons = List.generate(displayProjects.length, (i) => Icons.folder);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDropdown(
            label: 'Project',
            items: displayTitles,
            itemIcons: displayIcons,
            selectedItem: displayTitles.isNotEmpty
                ? displayTitles[_selectedProjectIndex.clamp(0, displayTitles.length - 1)]
                : null,
            prefixIcon: displayIcons.isNotEmpty
                ? displayIcons[_selectedProjectIndex.clamp(0, displayIcons.length - 1)]
                : Icons.folder,
            onChanged: (value) {
              final index = displayTitles.indexOf(value!);
              if (index >= 0 && displayProjects[index]['slug'] == _addNewProjectSlug) {
                _showAddProjectDialog();
                return;
              }
              setState(() {
                _selectedProjectIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return CustomInputField(
      controller: _descriptionController,
      label: 'Task Description',
      hint: 'Enter task description...',
      maxLines: 4,
    );
  }

  Widget _buildDatePickers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDatePicker(
          label: 'Start Date',
          date: _startDate,
          onTap: () => _selectDate(true),
        ),
        const SizedBox(height: 20),
        _buildDatePicker(
          label: 'End Date',
          date: _endDate,
          onTap: () => _selectDate(false),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(
              color: AppConstants.primaryColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: AppConstants.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppConstants.secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date != null ? _formatDate(date) : 'Select date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: date != null
                            ? AppConstants.blackColor
                            : AppConstants.secondaryColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_drop_down_rounded,
                color: AppConstants.blackColor,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          border: Border.all(
            color: AppConstants.secondaryColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppConstants.secondaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.memory(
                  _selectedImageBytes!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: _showImagePicker,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Change Logo'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSmall,
                      ),
                    ),
                    backgroundColor: const Color(0xffEDE8FF),
                    foregroundColor: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                      _selectedImageBytes = null;
                    });
                  },
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  tooltip: 'Delete image',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          border: Border.all(
            color: AppConstants.secondaryColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attachment (Optional)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppConstants.secondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showImagePicker,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppConstants.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tap to add image',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            disabledBackgroundColor: AppConstants.primaryColor.withOpacity(0.5),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Save Task',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }
}