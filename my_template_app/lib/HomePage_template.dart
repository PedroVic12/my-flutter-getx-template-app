import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

// =======================================================================
// 1. MODELOS DE DADOS (Models)
// =======================================================================

// Modelo para um item de exercício
class Exercise {
  final String name;
  RxBool isCompleted;

  Exercise({required this.name, bool isCompleted = false})
      : isCompleted = isCompleted.obs;
}

// Modelo para os dados de um tipo de treino (Push, Pull, etc.)
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


// =======================================================================
// 2. REPOSITÓRIOS (Data Layer)
// =======================================================================

// Repositório para os dados dos treinos.
// Em um app real, isso viria de uma API ou banco de dados.
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

// =======================================================================
// 3. CONTROLADORES (Controllers - GetX)
// =======================================================================

// Controla o estado da navegação principal (índice da BottomNav, drawer)
class NavigationController extends GetxController {
  var selectedIndex = 0.obs;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void changePage(int index) {
    selectedIndex.value = index;
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }
  
  void closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
  }
}

// Controla o tema da aplicação (Claro/Escuro)
class ThemeController extends GetxController {
  var isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    showToast('Modo Escuro ${isDarkMode.value ? "ativado" : "desativado"}');
  }
}

// Controla o estado da página de treinos
class WorkoutController extends GetxController {
  late List<WorkoutData> workouts;
  var currentTab = 0.obs;
  
  // Usado para o carrossel de vídeos
  var currentVideoIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    workouts = WorkoutRepository.getWorkouts();
  }

  void changeTab(int index) {
    currentTab.value = index;
    currentVideoIndex.value = 0; // Reseta o vídeo ao trocar de aba
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

  // Calcula o progresso do treino atual
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

// =======================================================================
// 4. WIDGETS REUTILIZÁVEIS E HELPERS
// =======================================================================

// Função para exibir snackbars (toasts)
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
              // A lógica do botão de ação precisa ser passada aqui
            },
            child: action,
          )
        : null,
  );
}

// Função para exibir um BottomSheet customizado
void showCustomBottomSheet({required String title, required Widget content}) {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Get.textTheme.titleLarge),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(child: SingleChildScrollView(child: content)),
           const SizedBox(height: 16),
           Row(
             mainAxisAlignment: MainAxisAlignment.end,
             children: [
               OutlinedButton(onPressed: ()=> Get.back(), child: const Text("Cancelar")),
               const SizedBox(width: 8),
               ElevatedButton(onPressed: ()=> Get.back(), child: const Text("Confirmar")),
             ],
           )
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

// Widget para exibir um vídeo do YouTube (simulado)
class YouTubeVideoCard extends StatelessWidget {
  final String videoId;
  final String title;

  const YouTubeVideoCard({Key? key, required this.videoId, required this.title}) : super(key: key);

  // Função para abrir o vídeo no YouTube
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

// Widget para um item da lista de exercícios
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

// =======================================================================
// 5. PÁGINAS (Screens/Views)
// =======================================================================

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Home Page", style: Get.textTheme.displaySmall),
          const SizedBox(height: 16),
          const Text("Welcome to the mobile app template 2025."),
          const SizedBox(height: 8),
          const Text("Use the buttons below to interact with the app."),
          const SizedBox(height: 16),
          const Text("Estou usando esse template para migrar um projeto em Flutter para React com Ionic para React com Vite e com todos os componentes com código limpo usando Material UI, Tailwind e Ionic."),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              showCustomBottomSheet(
                title: "Example Bottom Sheet",
                content: Column(
                  children: const [
                    Text("This is the bottom sheet content."),
                    Text("It scrolls if needed. Lorem ipsum..."),
                  ],
                ),
              );
            },
            child: const Text("Open Bottom Sheet"),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => showToast("Operation successful!", isError: false),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
                child: const Text("Show Success Toast"),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => showToast("Something went wrong!", isError: true),
                 style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Show Error Toast"),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text("From Pedro Victor Veras Software developer.", style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://placehold.co/100x100/EFEFEF/AAAAAA&text=PV'),
                ),
                const SizedBox(height: 16),
                Text("John Doe", style: Get.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text("john.doe@example.com", style: Get.textTheme.titleMedium),
                const SizedBox(height: 16),
                const Text("Profile page content goes here.", textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);
  final ThemeController _themeController = Get.find();
  final RxBool notificationsEnabled = true.obs;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        Card(
          child: Column(
            children: [
               Obx(() => SwitchListTile(
                    title: const Text("Enable Notifications"),
                    secondary: const Icon(Icons.notifications),
                    value: notificationsEnabled.value,
                    onChanged: (val) => notificationsEnabled.value = val,
                  )),
              const Divider(height: 1),
              Obx(() => SwitchListTile(
                    title: const Text("Dark Mode"),
                    secondary: const Icon(Icons.dark_mode),
                    value: _themeController.isDarkMode.value,
                    onChanged: (val) => _themeController.toggleTheme(),
                  )),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.language),
                title: Text("Language"),
                subtitle: Text("Português (Brasil)"),
              ),
            ],
          ),
        ),
      ],
    );
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
          // Carrossel de Vídeos
          _buildVideoCarousel(),
          const SizedBox(height: 24),
          // Checklist de Exercícios
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

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("404", style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text("Página não encontrada", style: TextStyle(fontSize: 24)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.find<NavigationController>().changePage(0),
            child: const Text("Ir para Home"),
          ),
        ],
      ),
    );
  }
}


// =======================================================================
// 6. LAYOUT PRINCIPAL (Main Layout with AppBar, Drawer, BottomNav)
// =======================================================================

class MainLayout extends StatelessWidget {
  MainLayout({Key? key}) : super(key: key);

  final NavigationController _navController = Get.put(NavigationController());

  final List<Widget> _pages = [
    const HomePage(),
    const ProfilePage(),
    WorkoutPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _navController.scaffoldKey,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Obx(() => IndexedStack(
            index: _navController.selectedIndex.value,
            children: _pages,
          )),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Mobile App"),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => _navController.openDrawer(),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Get.theme.colorScheme.primary),
            child: Text('App Menu', style: TextStyle(color: Get.theme.colorScheme.onPrimary, fontSize: 24)),
          ),
          _drawerItem(icon: Icons.home, text: 'Home', pageIndex: 0),
          _drawerItem(icon: Icons.person, text: 'Profile', pageIndex: 1),
          _drawerItem(icon: Icons.fitness_center, text: 'Workout', pageIndex: 2),
          _drawerItem(icon: Icons.settings, text: 'Settings', pageIndex: 3),
          const Divider(),
          _drawerItem(icon: Icons.mail, text: 'Mail', onTap: () => showToast("Mail Page (not implemented)")),
          _drawerItem(icon: Icons.inbox, text: 'Inbox', onTap: () => showToast("Inbox Page (not implemented)")),
        ],
      ),
    );
  }

  ListTile _drawerItem({required IconData icon, required String text, int? pageIndex, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: () {
        _navController.closeDrawer();
        if (pageIndex != null) {
          _navController.changePage(pageIndex);
        }
        onTap?.call();
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Obx(() => BottomNavigationBar(
          currentIndex: _navController.selectedIndex.value,
          onTap: (index) => _navController.changePage(index),
          type: BottomNavigationBarType.fixed, // Garante que o fundo seja sempre visível
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ));
  }
}


// =======================================================================
// 7. FUNÇÃO PRINCIPAL E CONFIGURAÇÃO DO APP
// =======================================================================

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inicializa o ThemeController globalmente
    Get.put(ThemeController());
    
    return GetMaterialApp(
      title: 'Flutter Mobile App',
      debugShowCheckedModeBanner: false,
      
      // Definição dos Temas com Material 3
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),

        appBarTheme: const AppBarTheme(
          elevation: 2,
        )
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark
        ),

        appBarTheme: const AppBarTheme(
          elevation: 4,
        )
      ),
      themeMode: ThemeMode.system, // O controller irá gerenciar isso

      // Página inicial
      home: MainLayout(),
    );
  }
}
