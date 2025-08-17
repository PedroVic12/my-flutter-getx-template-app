"use client";

import { useState, useEffect, useRef } from "react";
import {
  Drawer,
  List,
  ListItem,
  ListItemButton,
  ListItemText,
  AppBar,
  Toolbar,
  IconButton,
  Typography,
  Checkbox,
  TextField,
  Button,
  CircularProgress,
  Divider,
} from "@mui/material";
import MenuIcon from "@mui/icons-material/Menu";
import AddIcon from "@mui/icons-material/Add";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import LinkIcon from "@mui/icons-material/Link";
import CheckIcon from "@mui/icons-material/Check";
import { Bar } from "react-chartjs-2";
import { Chart as ChartJS, CategoryScale, LinearScale, BarElement, Title, Tooltip } from "chart.js";



// Registrar componentes do Chart.js
ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip);

//! npm install @mui/material @emotion/react @emotion/styled react-chartjs-2 chart.js @ionic/react  @icon/ionicons

// Tipos
type Task = {
  ID: string;
  Atividade: string;
  Categoria: string;
  Tempo: number;
  Data: string;
  Status: string;
  NotionLink?: string;
  ClickUpLink?: string;
};

type PlanItem = {
  ID: string;
  Prioridade: number;
  Tempo: number;
  Atividade: string;
  "Resultado Esperado": string;
  Status: string;
};

type ScrumItem = {
  ID: string;
  Todo: boolean;
  InProgress: boolean;
  Concluido: boolean;
  AgentesAI?: string;
  "Projetos Parados"?: boolean;
};

type WeeklyStats = {
  estudos: { atual: number; meta: number };
  projetos: { atual: number; meta: number };
};

// Dados de navegação
const navItems = [
  { name: "🏠 Início", href: "/" },
  { name: "📋 Tarefas", href: "/todo" },
  { name: "⏱️ Pomodoro", href: "/pomodoro" },
  { name: "📊 Dashboard", href: "/dashboard" },
  { name: "📅 Plano Atividades", href: "/plano" },
  { name: "🔄 Scrum Planner", href: "/scrum" },
  { name: "🧠 Estudo", href: "/study" },
  { name: "💪 Calistenia", href: "/calistenia" },
  { name: "📖 Habit Tracker 2025", href: "/home" },
];

// Componente Timer
function Timer({ tasks, onTimeAdd }: { tasks: Task[]; onTimeAdd: (taskId: string, minutes: number) => void }) {
  const [isActive, setIsActive] = useState(false);
  const [timeLeft, setTimeLeft] = useState(25 * 60);
  const [selectedTask, setSelectedTask] = useState("");
  const intervalRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    if (isActive) {
      intervalRef.current = setInterval(() => {
        setTimeLeft((prev) => {
          if (prev <= 1) {
            completeTimer();
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    } else if (intervalRef.current) {
      clearInterval(intervalRef.current);
    }

    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
    };
  }, [isActive]);

  const startTimer = () => {
    if (!selectedTask) {
      alert("Selecione uma tarefa!");
      return;
    }
    setIsActive(true);
  };

  const completeTimer = () => {
    setIsActive(false);
    onTimeAdd(selectedTask, 25);
    setTimeLeft(25 * 60);
    alert("Tempo concluído!");
  };

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs < 10 ? "0" : ""}${secs}`;
  };

  return (
    <div className="p-4 bg-white rounded-lg shadow">
      <h2 className="text-xl font-bold mb-4">🍅 Pomodoro Timer</h2>
      <div className="text-center mb-4">
        <div className="text-4xl font-mono font-bold">{formatTime(timeLeft)}</div>
      </div>
      
      <div className="space-y-3">
        <select
          value={selectedTask}
          onChange={(e) => setSelectedTask(e.target.value)}
          disabled={isActive}
          className="w-full p-2 border border-gray-300 rounded"
        >
          <option value="">Selecione uma tarefa</option>
          {tasks.map((task) => (
            <option key={task.ID} value={task.ID}>
              {task.Atividade}
            </option>
          ))}
        </select>
        
        <div className="flex space-x-2">
          {!isActive ? (
            <button
              onClick={startTimer}
              className="flex-1 bg-green-500 hover:bg-green-600 text-white py-2 px-4 rounded"
            >
              Iniciar
            </button>
          ) : (
            <button
              onClick={() => setIsActive(false)}
              className="flex-1 bg-red-500 hover:bg-red-600 text-white py-2 px-4 rounded"
            >
              Pausar
            </button>
          )}
        </div>
      </div>
    </div>
  );
}

// Componente ParetoChart
function ParetoChart({ tasks }: { tasks: Task[] }) {
  // Calcular tempo por tarefa
  const taskTimes = tasks.reduce((acc: Record<string, number>, task) => {
    acc[task.Atividade] = (acc[task.Atividade] || 0) + (task.Tempo || 0);
    return acc;
  }, {});
  
  // Ordenar por tempo (Pareto)
  const sortedTasks = Object.entries(taskTimes)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5);

  const data = {
    labels: sortedTasks.map(([task]) => task),
    datasets: [
      {
        label: 'Minutos Investidos',
        data: sortedTasks.map(([_, time]) => time),
        backgroundColor: 'rgba(75, 192, 192, 0.6)',
      }
    ]
  };

  const options = {
    responsive: true,
    plugins: {
      title: {
        display: true,
        text: 'Top 5 Tarefas (Princípio de Pareto)',
      },
    },
  };

  return <Bar data={data} options={options} />;
}

// Componente TaskList
function TaskList({ tasks, onDelete, onEdit }: { 
  tasks: Task[]; 
  onDelete: (id: string) => void;
  onEdit: (task: Task) => void;
}) {
  return (
    <div className="overflow-x-auto">
      <table className="min-w-full bg-white">
        <thead>
          <tr className="bg-gray-100">
            <th className="py-2 px-4 text-left">Atividade</th>
            <th className="py-2 px-4 text-left">Categoria</th>
            <th className="py-2 px-4 text-left">Tempo (min)</th>
            <th className="py-2 px-4 text-left">Data</th>
            <th className="py-2 px-4 text-left">Ações</th>
          </tr>
        </thead>
        <tbody>
          {tasks.map((task) => (
            <tr key={task.ID} className="border-b">
              <td className="py-2 px-4">{task.Atividade}</td>
              <td className="py-2 px-4">
                <span className={`px-2 py-1 rounded-full text-xs ${
                  task.Categoria === 'Estudos' ? 'bg-blue-100 text-blue-800' :
                  task.Categoria === 'Projetos' ? 'bg-green-100 text-green-800' :
                  'bg-gray-100 text-gray-800'
                }`}>
                  {task.Categoria}
                </span>
              </td>
              <td className="py-2 px-4">{task.Tempo || 0}</td>
              <td className="py-2 px-4">{task.Data}</td>
              <td className="py-2 px-4 flex space-x-2">
                <button 
                  onClick={() => onEdit(task)}
                  className="text-blue-500 hover:text-blue-700"
                >
                  <EditIcon fontSize="small" />
                </button>
                <button 
                  onClick={() => onDelete(task.ID)}
                  className="text-red-500 hover:text-red-700"
                >
                  <DeleteIcon fontSize="small" />
                </button>
                {task.NotionLink && (
                  <a href={task.NotionLink} target="_blank" rel="noopener noreferrer">
                    <LinkIcon fontSize="small" className="text-purple-500" />
                  </a>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

// Componente TodoForm
function TodoForm({ task, onSave, onCancel }: { 
  task?: Task; 
  onSave: (task: Task) => void;
  onCancel: () => void;
}) {
  const [formData, setFormData] = useState<Task>(task || {
    ID: "",
    Atividade: "",
    Categoria: "Geral",
    Tempo: 0,
    Data: new Date().toISOString().split('T')[0],
    Status: "Pendente",
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(formData);
  };

  return (
    <div className="p-4 bg-white rounded-lg shadow mb-4">
      <h2 className="text-xl font-bold mb-4">{task ? "Editar Tarefa" : "Nova Tarefa"}</h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <TextField
          label="Atividade"
          name="Atividade"
          value={formData.Atividade}
          onChange={handleChange}
          fullWidth
          required
        />
        
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium mb-1">Categoria</label>
            <select
              name="Categoria"
              value={formData.Categoria}
              onChange={handleChange}
              className="w-full p-2 border border-gray-300 rounded"
            >
              <option value="Estudos">Estudos</option>
              <option value="Projetos">Projetos</option>
              <option value="Treinos">Treinos</option>
              <option value="Pessoal">Pessoal</option>
              <option value="Geral">Geral</option>
            </select>
          </div>
          
          <TextField
            label="Tempo (min)"
            name="Tempo"
            type="number"
            value={formData.Tempo}
            onChange={handleChange}
            fullWidth
          />
        </div>
        
        <TextField
          label="Link Notion"
          name="NotionLink"
          value={formData.NotionLink || ""}
          onChange={handleChange}
          fullWidth
        />
        
        <TextField
          label="Link ClickUp"
          name="ClickUpLink"
          value={formData.ClickUpLink || ""}
          onChange={handleChange}
          fullWidth
        />
        
        <div className="flex justify-end space-x-2">
          <button
            type="button"
            onClick={onCancel}
            className="px-4 py-2 border border-gray-300 rounded hover:bg-gray-100"
          >
            Cancelar
          </button>
          <button
            type="submit"
            className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
          >
            {task ? "Atualizar" : "Adicionar"}
          </button>
        </div>
      </form>
    </div>
  );
}

// Controlador de estado para TodoList
class TodoListController {
  private tasks: Task[] = [];
  private setTasks: React.Dispatch<React.SetStateAction<Task[]>> | null = null;
  
  constructor() {
    this.loadTasks();
  }
  
  async loadTasks() {
    try {
      const response = await fetch('/api/todo');
      const data = await response.json();
      this.tasks = data;
      if (this.setTasks) this.setTasks(data);
    } catch (error) {
      console.error("Erro ao carregar tarefas:", error);
    }
  }
  
  async addTask(task: Omit<Task, 'ID'>) {
    try {
      const response = await fetch('/api/todo', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(task)
      });
      
      const result = await response.json();
      if (result.success) {
        await this.loadTasks();
        return result.id;
      }
    } catch (error) {
      console.error("Erro ao adicionar tarefa:", error);
    }
    return null;
  }
  
  async updateTask(task: Task) {
    try {
      const response = await fetch(`/api/todo/${task.ID}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(task)
      });
      
      const result = await response.json();
      if (result.success) {
        await this.loadTasks();
        return true;
      }
    } catch (error) {
      console.error("Erro ao atualizar tarefa:", error);
    }
    return false;
  }
  
  async deleteTask(id: string) {
    try {
      const response = await fetch(`/api/todo/${id}`, {
        method: 'DELETE'
      });
      
      const result = await response.json();
      if (result.success) {
        await this.loadTasks();
        return true;
      }
    } catch (error) {
      console.error("Erro ao deletar tarefa:", error);
    }
    return false;
  }
  
  async addTimeToTask(id: string, minutes: number) {
    try {
      const response = await fetch(`/api/todo/${id}/add_time`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ minutes })
      });
      
      const result = await response.json();
      if (result.success) {
        await this.loadTasks();
        return true;
      }
    } catch (error) {
      console.error("Erro ao adicionar tempo:", error);
    }
    return false;
  }
  
  bindSetState(setState: React.Dispatch<React.SetStateAction<Task[]>>) {
    this.setTasks = setState;
  }
}

// Componente Dashboard
function Dashboard() {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [weeklyStats, setWeeklyStats] = useState<WeeklyStats>({
    estudos: { atual: 0, meta: 600 }, // 10h = 600 min
    projetos: { atual: 0, meta: 1800 } // 30h = 1800 min
  });

  const todoController = useRef(new TodoListController());

  useEffect(() => {
    todoController.current.bindSetState(setTasks);
    todoController.current.loadTasks();
  }, []);

  useEffect(() => {
    // Calcular tempo semanal
    const estudos = tasks
      .filter(task => task.Categoria === "Estudos")
      .reduce((sum, task) => sum + (task.Tempo || 0), 0);
    
    const projetos = tasks
      .filter(task => task.Categoria === "Projetos")
      .reduce((sum, task) => sum + (task.Tempo || 0), 0);
    
    setWeeklyStats({
      estudos: { ...weeklyStats.estudos, atual: estudos },
      projetos: { ...weeklyStats.projetos, atual: projetos }
    });
  }, [tasks]);

  const handleTimeAdd = async (taskId: string, minutes: number) => {
    await todoController.current.addTimeToTask(taskId, minutes);
  };

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">📊 Dashboard de Produtividade</h1>
      
      {/* Timer Pomodoro */}
      <Timer tasks={tasks} onTimeAdd={handleTimeAdd} />
      
      {/* Metas Semanais */}
      <div className="p-4 bg-white rounded-lg shadow">
        <h2 className="text-xl font-bold mb-4">🎯 Metas Semanais</h2>
        <div className="space-y-4">
          <div>
            <div className="flex justify-between mb-1">
              <span className="font-medium">Estudos: {(weeklyStats.estudos.atual/60).toFixed(1)}h / 10h</span>
              <span>{Math.round((weeklyStats.estudos.atual / weeklyStats.estudos.meta) * 100)}%</span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2.5">
              <div 
                className="bg-blue-600 h-2.5 rounded-full" 
                style={{ width: `${Math.min(100, (weeklyStats.estudos.atual / weeklyStats.estudos.meta) * 100)}%` }}
              ></div>
            </div>
          </div>
          
          <div>
            <div className="flex justify-between mb-1">
              <span className="font-medium">Projetos: {(weeklyStats.projetos.atual/60).toFixed(1)}h / 30h</span>
              <span>{Math.round((weeklyStats.projetos.atual / weeklyStats.projetos.meta) * 100)}%</span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2.5">
              <div 
                className="bg-green-600 h-2.5 rounded-full" 
                style={{ width: `${Math.min(100, (weeklyStats.projetos.atual / weeklyStats.projetos.meta) * 100)}%` }}
              ></div>
            </div>
          </div>
        </div>
      </div>
      
      {/* Gráfico de Pareto */}
      <div className="p-4 bg-white rounded-lg shadow">
        <h2 className="text-xl font-bold mb-4">📊 Análise de Pareto</h2>
        <ParetoChart tasks={tasks} />
      </div>
      
      {/* Lista de Tarefas */}
      <div className="p-4 bg-white rounded-lg shadow">
        <h2 className="text-xl font-bold mb-4">📝 Lista de Tarefas</h2>
        <TaskList 
          tasks={tasks} 
          onDelete={id => todoController.current.deleteTask(id)}
          onEdit={task => console.log("Editar:", task)}
        />
      </div>
    </div>
  );
}

// Componente TodoPage
function TodoPage() {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [editingTask, setEditingTask] = useState<Task | null>(null);
  
  const todoController = useRef(new TodoListController());

  useEffect(() => {
    todoController.current.bindSetState(setTasks);
    todoController.current.loadTasks();
  }, []);

  const handleAddTask = async (task: Task) => {
    if (editingTask) {
      await todoController.current.updateTask(task);
    } else {
      await todoController.current.addTask(task);
    }
    setShowForm(false);
    setEditingTask(null);
  };

  const handleEditTask = (task: Task) => {
    setEditingTask(task);
    setShowForm(true);
  };

  const handleDeleteTask = async (id: string) => {
    await todoController.current.deleteTask(id);
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold">📋 Lista de Tarefas</h1>
        <button
          onClick={() => setShowForm(true)}
          className="flex items-center bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
        >
          <AddIcon className="mr-1" /> Nova Tarefa
        </button>
      </div>
      
      {showForm && (
        <TodoForm 
          task={editingTask || undefined}
          onSave={handleAddTask}
          onCancel={() => {
            setShowForm(false);
            setEditingTask(null);
          }}
        />
      )}
      
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <TaskList 
          tasks={tasks} 
          onDelete={handleDeleteTask}
          onEdit={handleEditTask}
        />
      </div>
    </div>
  );
}

// Componente PlanoAtividades
function PlanoAtividades() {
  const [planItems, setPlanItems] = useState<PlanItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch('/api/plano_atividades');
        const data = await response.json();
        setPlanItems(data);
      } catch (error) {
        console.error("Erro ao carregar plano de atividades:", error);
      } finally {
        setLoading(false);
      }
    };
    
    fetchData();
  }, []);

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <CircularProgress />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">📅 Plano de Atividades</h1>
      
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="min-w-full">
          <thead className="bg-gray-100">
            <tr>
              <th className="py-3 px-4 text-left">Prioridade</th>
              <th className="py-3 px-4 text-left">Atividade</th>
              <th className="py-3 px-4 text-left">Tempo (min)</th>
              <th className="py-3 px-4 text-left">Resultado Esperado</th>
              <th className="py-3 px-4 text-left">Status</th>
            </tr>
          </thead>
          <tbody>
            {planItems.map((item) => (
              <tr key={item.ID} className="border-b hover:bg-gray-50">
                <td className="py-3 px-4">
                  <span className={`px-2 py-1 rounded-full ${
                    item.Prioridade === 1 ? 'bg-red-100 text-red-800' :
                    item.Prioridade === 2 ? 'bg-yellow-100 text-yellow-800' :
                    'bg-green-100 text-green-800'
                  }`}>
                    {item.Prioridade}
                  </span>
                </td>
                <td className="py-3 px-4">{item.Atividade}</td>
                <td className="py-3 px-4">{item.Tempo}</td>
                <td className="py-3 px-4">{item["Resultado Esperado"]}</td>
                <td className="py-3 px-4">
                  <span className={`px-2 py-1 rounded-full text-xs ${
                    item.Status === 'Concluído' ? 'bg-green-100 text-green-800' :
                    item.Status === 'Em andamento' ? 'bg-yellow-100 text-yellow-800' :
                    'bg-gray-100 text-gray-800'
                  }`}>
                    {item.Status}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

// Componente ScrumPlanner
function ScrumPlanner() {
  const [scrumItems, setScrumItems] = useState<ScrumItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch('/api/scrum_planner');
        const data = await response.json();
        setScrumItems(data);
      } catch (error) {
        console.error("Erro ao carregar Scrum Planner:", error);
      } finally {
        setLoading(false);
      }
    };
    
    fetchData();
  }, []);

  const moveItem = async (id: string, from: string, to: string) => {
    try {
      const response = await fetch('/api/scrum_planner/move', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id, from, to })
      });
      
      const result = await response.json();
      if (result.success) {
        // Atualizar estado local
        setScrumItems(prev => prev.map(item => {
          if (item.ID === id) {
            return { ...item, [from]: false, [to]: true };
          }
          return item;
        }));
      }
    } catch (error) {
      console.error("Erro ao mover item:", error);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <CircularProgress />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">🔄 Scrum Planner</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {/* Coluna Todo */}
        <div className="bg-gray-100 p-4 rounded-lg">
          <h2 className="text-lg font-semibold mb-4">📋 To Do</h2>
          <div className="space-y-3">
            {scrumItems.filter(item => item.Todo).map(item => (
              <div 
                key={item.ID} 
                className="bg-white p-3 rounded shadow cursor-move"
                draggable
                onDragStart={e => e.dataTransfer.setData("text/plain", JSON.stringify({
                  id: item.ID,
                  from: "Todo"
                }))}
              >
                {item.Todo}
                <div className="flex justify-end mt-2">
                  <button 
                    onClick={() => moveItem(item.ID, "Todo", "InProgress")}
                    className="text-blue-500 hover:text-blue-700"
                  >
                    <ArrowForwardIcon />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
        
        {/* Coluna In Progress */}
        <div className="bg-yellow-100 p-4 rounded-lg">
          <h2 className="text-lg font-semibold mb-4">🚧 In Progress</h2>
          <div className="space-y-3">
            {scrumItems.filter(item => item.InProgress).map(item => (
              <div 
                key={item.ID} 
                className="bg-white p-3 rounded shadow cursor-move"
                draggable
                onDragStart={e => e.dataTransfer.setData("text/plain", JSON.stringify({
                  id: item.ID,
                  from: "InProgress"
                }))}
              >
                {item.InProgress}
                <div className="flex justify-between mt-2">
                  <button 
                    onClick={() => moveItem(item.ID, "InProgress", "Todo")}
                    className="text-blue-500 hover:text-blue-700"
                  >
                    <ArrowBackIcon />
                  </button>
                  <button 
                    onClick={() => moveItem(item.ID, "InProgress", "Concluido")}
                    className="text-green-500 hover:text-green-700"
                  >
                    <CheckIcon />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
        
        {/* Coluna Concluído */}
        <div className="bg-green-100 p-4 rounded-lg">
          <h2 className="text-lg font-semibold mb-4">✅ Concluído</h2>
          <div className="space-y-3">
            {scrumItems.filter(item => item.Concluido).map(item => (
              <div 
                key={item.ID} 
                className="bg-white p-3 rounded shadow cursor-move"
                draggable
                onDragStart={e => e.dataTransfer.setData("text/plain", JSON.stringify({
                  id: item.ID,
                  from: "Concluido"
                }))}
              >
                {item.Concluido}
                <div className="flex justify-end mt-2">
                  <button 
                    onClick={() => moveItem(item.ID, "Concluido", "InProgress")}
                    className="text-blue-500 hover:text-blue-700"
                  >
                    <ArrowBackIcon />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

// Controlador de estado principal
class StateController {
  setState: React.Dispatch<React.SetStateAction<any>> | null = null;
  
  setMenuOpen(open: boolean) {
    if (this.setState) {
      this.setState((prev: any) => ({ ...prev, menuOpen: open }));
    }
  }

  setCurrentPage(page: string) {
    if (this.setState) {
      this.setState((prev: any) => ({ ...prev, currentPage: page }));
    }
  }
}

const stateController = new StateController();

// Página principal
export default function HomePage() {
  const [state, setState] = useState({
    menuOpen: false,
    currentPage: "dashboard",
    loading: true
  });

  // Vincular o controlador de estado
  useEffect(() => {
    stateController.setState = setState;
  }, []);

  // Renderizar conteúdo com base na página atual
  const renderContent = () => {
    switch (state.currentPage) {
      case "todo":
        return <TodoPage />;


      case "home":
        return (
          <div className="p-4 bg-white rounded-lg shadow">
          <h2 className="text-xl font-bold mb-4">📖 Habit Tracker 2025</h2>
          <p>Controle seus hábitos e produtividade com IA</p>
        
        {/* 
          <div className="mt-4">
            <DynamicGohanTreinamentosHomePage />
          </div> */}

          </div>
        );

      case "pomodoro":
        return (
          <div className="p-4 bg-white rounded-lg shadow">
            <h2 className="text-xl font-bold mb-4">⏱️ TempoMind - Pomodoro</h2>
            <div className="flex justify-center">
              <Timer 
                tasks={[]} 
                onTimeAdd={() => {}} 
              />
            </div>
          </div>
        );
      case "calistenia":
        return (
          <div className="p-4 bg-white rounded-lg shadow">
            <h2 className="text-xl font-bold mb-4">💪 CalisTrack - Treinos</h2>
            <p>Gerador e controle de treinos em Excel com IA</p>
          </div>
        );
      case "study":
        return (
          <div className="p-4 bg-white rounded-lg shadow">
            <h2 className="text-xl font-bold mb-4">🧠 NeoStudy - Estudo</h2>
            <p>PDF Reader, Flashcards e Simulados</p>
          </div>
        );
      case "dashboard":
        return <Dashboard />;
      case "plano":
        return <PlanoAtividades />;
      case "scrum":
        return <ScrumPlanner />;
      default:
        return (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 p-4">
            {navItems.filter(item => item.href !== "/").map((item) => (
              <div
                key={item.name}
                className="p-6 bg-white rounded-xl shadow hover:shadow-md transition cursor-pointer border border-gray-200 flex flex-col items-center text-center"
                onClick={() => stateController.setCurrentPage(item.href.slice(1))}
              >
                <div className="text-4xl mb-3">{item.name.split(' ')[0]}</div>
                <h3 className="text-lg font-semibold">{item.name}</h3>
                <p className="text-sm text-gray-600 mt-2">Clique para acessar</p>
              </div>
            ))}
          </div>
        );
    }
  };

  return (
    <div className="min-h-screen bg-gray-100">
      <AppBar position="static" className="bg-blue-600">
        <Toolbar>
          <IconButton
            edge="start"
            color="inherit"
            aria-label="menu"
            onClick={() => stateController.setMenuOpen(true)}
          >
            <MenuIcon />
          </IconButton>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
             Sistema de Produtividade
          </Typography>
        </Toolbar>
      </AppBar>

      <Drawer
        anchor="left"
        open={state.menuOpen}
        onClose={() => stateController.setMenuOpen(false)}
      >
        <List className="w-64 bg-gray-200 h-full">
          {navItems.map((item) => (
            <ListItem key={item.name} disablePadding>
              <ListItemButton
                onClick={() => {
                  stateController.setCurrentPage(item.href.slice(1) || "home");
                  stateController.setMenuOpen(false);
                }}
                className={state.currentPage === item.href.slice(1) ? "bg-blue-100" : ""}
              >
                <ListItemText 
                  primary={item.name} 
                  primaryTypographyProps={{ 
                    className: state.currentPage === item.href.slice(1) ? "font-semibold" : ""
                  }} 
                />
              </ListItemButton>
                <Divider component="li" />
            </ListItem>
            
          

          ))}
        </List>
      </Drawer>

      <main className="p-4 max-w-6xl mx-auto">
        {renderContent()}
      </main>
    </div>
  );
}

// Componentes de ícones auxiliares
function ArrowForwardIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
      <path fillRule="evenodd" d="M10.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L12.586 11H5a1 1 0 110-2h7.586l-2.293-2.293a1 1 0 010-1.414z" clipRule="evenodd" />
    </svg>
  );
}

function ArrowBackIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
      <path fillRule="evenodd" d="M9.707 14.707a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 1.414L7.414 9H15a1 1 0 110 2H7.414l2.293 2.293a1 1 0 010 1.414z" clipRule="evenodd" />
    </svg>
  );
}