
import 'package:get/get.dart';
import 'package:gohan_treinamentos_app/models/kanban_models.dart';
import 'package:gohan_treinamentos_app/repositories/kanban_repository.dart';

class KanbanController extends GetxController {
  final KanbanRepository _repository;
  RxList<ProjectItem> projects = <ProjectItem>[].obs;

  KanbanController({required String kanbanFilePath})
      : _repository = KanbanRepository(kanbanFilePath: kanbanFilePath);

  @override
  void onInit() {
    super.onInit();
    loadProjects();
  }

  Future<void> loadProjects() async {
    projects.value = await _repository.loadKanbanFromMarkdown();
  }

  Future<void> updateProjectStatus(String projectId, String newStatus) async {
    final index = projects.indexWhere((item) => item.id == projectId);
    if (index != -1) {
      projects[index].status = newStatus;
      projects.refresh(); // Notify listeners of change
      await _repository.saveKanbanToMarkdown(projects);
    }
  }

  Future<void> updateProject(ProjectItem updatedProject) async {
    final index = projects.indexWhere((item) => item.id == updatedProject.id);
    if (index != -1) {
      projects[index] = updatedProject;
      projects.refresh();
      await _repository.saveKanbanToMarkdown(projects);
    }
  }

  Future<void> addProject(ProjectItem newProject) async {
    projects.add(newProject);
    await _repository.saveKanbanToMarkdown(projects);
  }

  Future<void> deleteProject(String projectId) async {
    projects.removeWhere((item) => item.id == projectId);
    await _repository.saveKanbanToMarkdown(projects);
  }
}
