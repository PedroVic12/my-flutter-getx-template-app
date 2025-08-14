
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

// Models
class Exercise {
  final String name;
  RxBool isCompleted;

  Exercise({required this.name, bool isCompleted = false})
      : isCompleted = isCompleted.obs;
}

class WorkoutData {
  final String type;
  final List<Map<String, String>> videos;
  final List<Exercise> exercises;

  WorkoutData({
    required this.type,
    required this.videos,
    required List<String> exerciseNames,
  }) : exercises = exerciseNames.map((name) => Exercise(name: name)).toList();
}

// Repositories
class WorkoutRepository {
  static List<WorkoutData> getWorkouts() {
    return [
      WorkoutData(
        type: 'Push',
        videos: [
          {'id': 'dGpVNgzqMjY', 'title': 'Treino Push - Peito, Ombro e Tríceps'},
          {'id': 'RJ0zxH0tUJM', 'title': 'Dicas para Treino Push Completo'},
          {'id': 'tHD3Y4OjcQg', 'title': 'Push Workout para Hipertrofia'}
        ],
        exerciseNames: [
          'Supino Reto 4x12',
          'Desenvolvimento com Halteres 3x10',
          'Crucifixo Máquina 3x12',
          'Elevação Lateral 4x15',
          'Tríceps Corda 4x15',
          'Tríceps Francês 3x12'
        ],
      ),
      WorkoutData(
        type: 'Pull',
        videos: [
          {'id': '7jYIxJVEKMI', 'title': 'Treino Pull - Costas e Bíceps'},
          {'id': 'KSG9bETUzNI', 'title': 'Pull Workout para Ganho de Massa'},
          {'id': 'MgNn2uPXOz4', 'title': 'Técnicas Avançadas para Pull Day'}
        ],
        exerciseNames: [
          'Puxada Frontal 4x12',
          'Remada Curvada 4x10',
          'Pulldown 3x12',
          'Rosca Direta 4x12',
          'Rosca Martelo 3x12',
          'Remada Unilateral 3x10 (cada lado)'
        ],
      ),
      WorkoutData(
        type: 'Abs',
        videos: [
          {'id': '1foQY0o8CSc', 'title': 'Treino Abdominal Completo 10min'},
          {'id': 'AnYl6Nk9GOA', 'title': 'Abdominal Para Iniciantes'},
          {'id': 'DHD1-2P94DI', 'title': 'Core Training para Definição'}
        ],
        exerciseNames: [
          'Crunch Tradicional 3x20',
          'Prancha Frontal 3x30s',
          'Prancha Lateral 3x20s (cada lado)',
          'Elevação de Pernas 3x15',
          'Russian Twist 3x20',
          'Mountain Climber 3x30s'
        ],
      ),
    ];
  }
}

// Controllers
class WorkoutController extends GetxController {
  late List<WorkoutData> workouts;
  var currentTab = 0.obs;
  var currentVideoIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    workouts = WorkoutRepository.getWorkouts();
  }

  void changeTab(int index) {
    currentTab.value = index;
    currentVideoIndex.value = 0;
  }
  
  void nextVideo() {
      final videosCount = workouts[currentTab.value].videos.length;
      if (currentVideoIndex.value < videosCount - 1) {
          currentVideoIndex.value++;
      } else {
          currentVideoIndex.value = 0;
      }
  }

  void prevVideo() {
      final videosCount = workouts[currentTab.value].videos.length;
      if (currentVideoIndex.value > 0) {
          currentVideoIndex.value--;
      } else {
          currentVideoIndex.value = videosCount - 1;
      }
  }

  double get currentWorkoutProgress {
    final currentWorkout = workouts[currentTab.value];
    if (currentWorkout.exercises.isEmpty) return 0.0;
    
    final completedCount = currentWorkout.exercises.where((e) => e.isCompleted.value).length;
    return completedCount / currentWorkout.exercises.length;
  }
  
  void finishWorkout() {
      final progress = currentWorkoutProgress;
      if (progress == 1.0) {
          showToast('Parabéns! Treino concluído com sucesso!', isError: false);
      } else {
          final percentage = (progress * 100).toStringAsFixed(0);
          showToast('Treino parcialmente concluído: $percentage% dos exercícios realizados.');
      }
  }
}

// Widgets
void showToast(String message, {bool isError = false, Widget? action}) {
  Get.snackbar(
    isError ? 'Erro' : 'Sucesso',
    message,
    snackPosition: SnackPosition.TOP,
    backgroundColor: isError ? Colors.red[600] : Colors.green[600],
    colorText: Colors.white,
    borderRadius: 8,
    margin: const EdgeInsets.all(10),
    mainButton: action != null 
        ? TextButton(
            onPressed: () {
              if (Get.isSnackbarOpen) Get.back();
            },
            child: action,
          )
        : null,
  );
}

class YouTubeVideoCard extends StatelessWidget {
  final String videoId;
  final String title;

  const YouTubeVideoCard({Key? key, required this.videoId, required this.title}) : super(key: key);

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (!await launchUrl(url)) {
      showToast('Não foi possível abrir o vídeo.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: _launchURL,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  'https://img.youtube.com/vi/$videoId/0.jpg',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey[800],
                    child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50)),
                  ),
                ),
                Icon(Icons.play_circle_fill, color: Colors.white.withOpacity(0.8), size: 60),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: Get.textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseItem extends StatelessWidget {
  final Exercise exercise;

  const ExerciseItem({Key? key, required this.exercise}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => CheckboxListTile(
          title: Text(exercise.name),
          value: exercise.isCompleted.value,
          onChanged: (bool? value) {
            exercise.isCompleted.value = value ?? false;
          },
          controlAffinity: ListTileControlAffinity.leading,
        ));
  }
}

class WorkoutPage extends StatelessWidget {
  WorkoutPage({Key? key}) : super(key: key);
  final WorkoutController _controller = Get.put(WorkoutController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _controller.workouts.length,
      child: Column(
        children: [
          TabBar(
            onTap: (index) => _controller.changeTab(index),
            tabs: _controller.workouts
                .map((w) => Tab(text: w.type))
                .toList(),
          ),
          Expanded(
            child: Obx(() => IndexedStack(
              index: _controller.currentTab.value,
              children: _controller.workouts.map((workout) {
                return WorkoutTabContent(workoutData: workout);
              }).toList(),
            )),
          ),
        ],
      ),
    );
  }
}

class WorkoutTabContent extends StatelessWidget {
  final WorkoutData workoutData;
  final WorkoutController _controller = Get.find();

  WorkoutTabContent({Key? key, required this.workoutData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildVideoCarousel(),
          const SizedBox(height: 24),
          _buildExerciseChecklist(),
        ],
      ),
    );
  }

  Widget _buildVideoCarousel() {
    return Column(
      children: [
        Obx(() => YouTubeVideoCard(
          videoId: workoutData.videos[_controller.currentVideoIndex.value]['id']!,
          title: workoutData.videos[_controller.currentVideoIndex.value]['title']!,
        )),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: _controller.prevVideo),
            Obx(() => Text('${_controller.currentVideoIndex.value + 1} / ${workoutData.videos.length}')),
            IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: _controller.nextVideo),
          ],
        )
      ],
    );
  }

  Widget _buildExerciseChecklist() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text("Exercícios", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Obx(() {
                  final progress = _controller.currentWorkoutProgress;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        color: progress == 1.0 ? Colors.green : Get.theme.primaryColor,
                      ),
                      Text("${(progress * 100).toInt()}%"),
                    ],
                  );
                }),
              ],
            ),
            const Divider(height: 24),
            ...workoutData.exercises.map((ex) => ExerciseItem(exercise: ex)).toList(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _controller.finishWorkout,
              icon: const Icon(Icons.check_circle),
              label: const Text("Finalizar Treino"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            )
          ],
        ),
      ),
    );
  }
}
