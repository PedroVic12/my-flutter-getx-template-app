const {
    colors, createTheme, ThemeProvider, CssBaseline, Box, AppBar, Toolbar,
    IconButton, Typography, Drawer, List, ListItem, ListItemButton,
    ListItemIcon, ListItemText, Grid, Card, CardHeader, CardContent,
    CardActions, Button, Dialog, DialogTitle, DialogContent, TextField,
    DialogActions, Select, MenuItem, LinearProgress, CircularProgress,
    Paper, Icon, useMediaQuery, Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Chip, Avatar
} = MaterialUI;

// =============================================================================
// CAMADA DE DADOS
// =============================================================================
class DataRepository {
    constructor() {
        this.storageKey = 'kanban_pro_data';
        this.db = this._load();
        if (!this.db || !this.db.projects) {
            this.db = {
                projects: [
                    { id: '1', title: 'Implementar Dashboard com Gráficos', status: 'concluido', category: 'flutter', priority: 'normal', content: '- [x] Criar cards de estatísticas\n- [x] Implementar gráfico de status\n- [x] Implementar gráfico de categorias', createdAt: new Date('2023-10-01'), updatedAt: new Date('2023-10-15') },
                    { id: '2', title: 'Desenvolver Tela de controle financeiro', status: 'concluido', category: 'flutter', priority: 'compromisso', content: '- [x] Criar componente de tabela\n- [x] Adicionar paginação e filtros', createdAt: new Date('2023-10-05'), updatedAt: new Date('2023-10-20') },
                    { id: '3', title: 'Estudar Análise de Sistemas de Potência', status: 'in progress', category: 'ons', priority: 'urgente', content: '- [x] Ler sobre Fluxo de Potência\n- [ ] Simular circuito no ANAREDE', createdAt: new Date(), updatedAt: new Date() },
                    { id: '4', title: 'Adicionar Timer Pomodoro', status: 'in progress', category: 'flutter', priority: 'normal', content: '- [x] Criar UI do timer\n- [x] Implementar Modo Foco\n- [ ] Adicionar notificações', createdAt: new Date(), updatedAt: new Date() },
                    { id: '5', title: 'Preparar Relatório Semanal', status: 'todo', category: 'ons', priority: 'compromisso', content: '- [ ] Coletar dados de performance\n- [ ] Gerar gráficos\n- [ ] Redigir sumário executivo', createdAt: new Date(), updatedAt: new Date() },
                    { id: '6', title: 'Desenvolver Algoritmo de IA', status: 'backlog', category: 'python', priority: 'normal', content: 'Definir escopo do projeto de IA para otimização de redes.', createdAt: new Date(), updatedAt: new Date() },
                    { id: '7', title: 'Revisar Documentação da API', status: 'review', category: 'backend', priority: 'normal', content: '- [x] Verificar endpoint /users\n- [ ] Documentar endpoint /projects', createdAt: new Date(), updatedAt: new Date() },
                ],
                files: [{ id: 'f1', title: 'Anotações da Reunião', content: '# Anotações\n\n- Discutir o novo layout.\n- Planear o sprint.', createdAt: new Date(), updatedAt: new Date() }],
                pomodoroSessions: [{ id: 'p1', projectId: '3', duration: 25, completedAt: new Date() }, { id: 'p2', projectId: '3', duration: 25, completedAt: new Date(Date.now() - 86400000) }],
            };
            this._save();
        } else if (!this.db.files) {
            this.db.files = [{ id: 'f1', title: 'Anotações da Reunião', content: '# Anotações\n\n- Discutir o novo layout.\n- Planear o sprint.', createdAt: new Date(), updatedAt: new Date() }];
            this._save();
        }
    }

    _load = () => {
        try {
            const data = localStorage.getItem(this.storageKey);
            if (data) {
                const parsed = JSON.parse(data);
                if (parsed.projects) {
                    parsed.projects.forEach(p => {
                        p.createdAt = new Date(p.createdAt);
                        p.updatedAt = new Date(p.updatedAt);
                    });
                }
                if (parsed.pomodoroSessions) {
                    parsed.pomodoroSessions.forEach(s => {
                        s.completedAt = new Date(s.completedAt);
                    });
                }
                if (parsed.files) {
                    parsed.files.forEach(f => {
                        f.createdAt = new Date(f.createdAt);
                        f.updatedAt = new Date(f.updatedAt);
                    });
                }
                return parsed;
            }
            return null;
        } catch (error) {
            console.error("Failed to load data from localStorage", error);
            localStorage.removeItem(this.storageKey); // Clear corrupted data
            return null;
        }
    }

    _save = () => {
        try {
            localStorage.setItem(this.storageKey, JSON.stringify(this.db));
        } catch (error) {
            console.error("Failed to save data to localStorage", error);
        }
    }

    getProjects = () => this.db.projects;
    addProject = (p) => { this.db.projects.push({ ...p, id: Date.now().toString(), createdAt: new Date(), updatedAt: new Date() }); this._save(); }
    updateProject = (id, u) => { const i = this.db.projects.findIndex(p => p.id === id); if (i !== -1) this.db.projects[i] = { ...this.db.projects[i], ...u, updatedAt: new Date() }; this._save(); }
    deleteProject = (id) => { this.db.projects = this.db.projects.filter(p => p.id !== id); this._save(); }

    getFiles = () => this.db.files;
    addFile = (f) => { this.db.files.push({ ...f, id: 'f' + Date.now().toString(), createdAt: new Date(), updatedAt: new Date() }); this._save(); }
    updateFile = (id, u) => { const i = this.db.files.findIndex(f => f.id === id); if (i !== -1) this.db.files[i] = { ...this.db.files[i], ...u, updatedAt: new Date() }; this._save(); }
    deleteFile = (id) => { this.db.files = this.db.files.filter(f => f.id !== id); this._save(); }

    getStatusStats = () => this.db.projects.reduce((acc, p) => { acc[p.status] = (acc[p.status] || 0) + 1; return acc; }, {});
    getCategoryStats = () => this.db.projects.reduce((acc, p) => { acc[p.category] = (acc[p.category] || 0) + 1; return acc; }, {});
    getPomodoroStats = () => ({ today: this.db.pomodoroSessions.filter(s => new Date(s.completedAt).toDateString() === new Date().toDateString()).length, total: this.db.pomodoroSessions.length });
}

const repository = new DataRepository();

const STATUS_COLUMNS = { 'backlog': { title: 'Backlog', emoji: '📦' }, 'todo': { title: 'A Fazer', emoji: '📝' }, 'in progress': { title: 'Em Progresso', emoji: '⏳' }, 'review': { title: 'Revisão', emoji: '👀' }, 'concluido': { title: 'Concluído', emoji: '✅' } };
const CATEGORIES = { 'ons': { label: 'ONS', color: 'primary' }, 'python': { label: 'Python', color: 'secondary' }, 'flutter': { label: 'Flutter', color: 'success' }, 'backend': { label: 'Backend', color: 'warning' } };
const PRIORITIES = { 'normal': { label: 'Normal', color: 'info', icon: 'low_priority' }, 'compromisso': { label: 'Compromisso', color: 'warning', icon: 'warning_amber' }, 'urgente': { label: 'Urgente', color: 'error', icon: 'priority_high' } };

// =============================================================================
// COMPONENTES DE UI
// =============================================================================
const ChecklistProgress = ({ content }) => {
    const items = (content.match(/- \[x \]/g) || []);
    if (items.length === 0) return null;
    const completed = (content.match(/- \[x\]/g) || []).length;
    const progress = (completed / items.length) * 100;
    return <Box mt={2}><LinearProgress variant="determinate" value={progress} /><Typography variant="caption" display="block" textAlign="right">{`${completed}/${items.length}`}</Typography></Box>;
};

const KanbanCard = ({ item, onEdit, isDragging, onDragStart, onDragEnd }) => (
    <Card className={isDragging ? 'dragging' : ''} sx={{ mb: 2, '&:hover': { boxShadow: 6 }, transition: 'opacity 0.2s, transform 0.2s' }} >
        <CardContent sx={{ pb: 1, cursor: 'pointer' }} onClick={() => onEdit(item)}>
            <Chip label={CATEGORIES[item.category]?.label || 'Geral'} color={CATEGORIES[item.category]?.color || 'default'} size="small" sx={{ mb: 1 }} />
            <Typography variant="body1" sx={{ fontWeight: 'bold' }}>{item.title}</Typography>
            {item.content && <ChecklistProgress content={item.content} />}
        </CardContent>
        <CardActions sx={{ justifyContent: 'space-between', pt: 0, px: 2, pb: 1 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <Icon sx={{ color: PRIORITIES[item.priority]?.color + '.main' }} title={PRIORITIES[item.priority]?.label}>{PRIORITIES[item.priority]?.icon}</Icon>
                <Typography variant="caption">{new Date(item.updatedAt).toLocaleDateString()}</Typography>
            </Box>
            <Icon sx={{ color: 'grey.500', cursor: 'grab' }} draggable onDragStart={onDragStart} onDragEnd={onDragEnd}>drag_indicator</Icon>
        </CardActions>
    </Card>
);

const PlotlyChart = ({ data, layout, style }) => {
    const chartRef = React.useRef(null);
    React.useEffect(() => {
        if (chartRef.current) {
            Plotly.newPlot(chartRef.current, data, layout, { responsive: true });
        }
    }, [data, layout]);
    return <div ref={chartRef} style={style}></div>;
};

const MarkdownEditor = ({ file, onSave, onClose, onDelete }) => {
    const [title, setTitle] = React.useState(file.title);
    const [content, setContent] = React.useState(file.content);
    const ActualReactMarkdown = ReactMarkdown.default || ReactMarkdown;

    const handleSave = () => {
        onSave({ ...file, title, content });
        onClose();
    };

    return (
        <Dialog open={true} onClose={onClose} fullWidth maxWidth="lg">
            <DialogTitle>Editar Documento</DialogTitle>
            <DialogContent dividers>
                <TextField label="Título" value={title} onChange={(e) => setTitle(e.target.value)} fullWidth margin="normal" />
                <Grid container spacing={2} sx={{ mt: 1, height: '60vh' }}>
                    <Grid item xs={12} md={6}><TextField label="Conteúdo (Markdown)" value={content} onChange={(e) => setContent(e.target.value)} fullWidth multiline sx={{ height: '100%', '& .MuiOutlinedInput-root': { height: '100%' } }} /></Grid>
                    <Grid item xs={12} md={6}><Box border={1} borderColor="grey.300" borderRadius={1} p={2} sx={{ overflowY: 'auto', height: '100%' }}><div className="prose"><ActualReactMarkdown>{content}</ActualReactMarkdown></div></Box></Grid>
                </Grid>
            </DialogContent>
            <DialogActions>
                <Button onClick={() => { onDelete(file.id); onClose(); }} color="error">Excluir</Button>
                <Box sx={{ flex: '1 0 0' }} />
                <Button onClick={onClose}>Cancelar</Button>
                <Button onClick={handleSave} variant="contained">Salvar</Button>
            </DialogActions>
        </Dialog>
    );
};

// =============================================================================
// COMPONENTES DE TELA
// =============================================================================
const DashboardScreen = () => {
    const statusStats = repository.getStatusStats();
    const categoryStats = repository.getCategoryStats();

    const statusChartData = [{ x: Object.keys(statusStats).map(k => STATUS_COLUMNS[k].title), y: Object.values(statusStats), type: 'bar' }];
    const categoryChartData = [{ labels: Object.keys(categoryStats).map(k => CATEGORIES[k].label), values: Object.values(categoryStats), type: 'pie', hole: .4 }];

    const chartLayout = { margin: { t: 20, b: 40, l: 40, r: 20 }, paper_bgcolor: 'rgba(0,0,0,0)', plot_bgcolor: 'rgba(0,0,0,0)' };

    return (
        <Box p={3}>
            <Typography variant="h4" gutterBottom>Dashboard</Typography>
            <Grid container spacing={3}>
                <Grid item xs={12} md={6}><Card><CardHeader title="Projetos por Status" /><CardContent><PlotlyChart data={statusChartData} layout={chartLayout} /></CardContent></Card></Grid>
                <Grid item xs={12} md={6}><Card><CardHeader title="Projetos por Categoria" /><CardContent><PlotlyChart data={categoryChartData} layout={chartLayout} /></CardContent></Card></Grid>
            </Grid>
        </Box>
    );
};

const TableScreen = () => (
    <Box p={3}>
        <Typography variant="h4" gutterBottom>Tabela de Projetos</Typography>
        <Paper><TableContainer><Table><TableHead><TableRow><TableCell>Título</TableCell><TableCell>Status</TableCell><TableCell>Categoria</TableCell><TableCell>Prioridade</TableCell><TableCell>Atualizado em</TableCell></TableRow></TableHead>
            <TableBody>{repository.getProjects().map(p => (<TableRow key={p.id} hover><TableCell>{p.title}</TableCell><TableCell><Chip label={STATUS_COLUMNS[p.status]?.title} size="small" /></TableCell><TableCell><Chip label={CATEGORIES[p.category]?.label} color={CATEGORIES[p.category]?.color} size="small" /></TableCell><TableCell><Chip label={PRIORITIES[p.priority]?.label} color={PRIORITIES[p.priority]?.color} size="small" /></TableCell><TableCell>{new Date(p.updatedAt).toLocaleDateString()}</TableCell></TableRow>))}</TableBody>
        </Table></TableContainer></Paper>
    </Box>
);

const DocumentsScreen = ({ onFileSelect, files, onAddFile }) => (
    <Box p={3}>
        <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
            <Typography variant="h4" gutterBottom>Documentos</Typography>
            <Button variant="contained" startIcon={<Icon>add</Icon>} onClick={onAddFile}>Novo Documento</Button>
        </Box>
        <Grid container spacing={2}>
            {files.map(file => (
                <Grid item xs={12} sm={6} md={4} key={file.id}>
                    <Card sx={{ cursor: 'pointer', '&:hover': { boxShadow: 4 } }} onClick={() => onFileSelect(file)}>
                        <CardContent>
                            <Typography variant="h6">{file.title}</Typography>
                            <Typography variant="body2" color="text.secondary" sx={{ mt: 1, overflow: 'hidden', textOverflow: 'ellipsis', display: '-webkit-box', WebkitLineClamp: 3, WebkitBoxOrient: 'vertical' }}>{file.content}</Typography>
                        </CardContent>
                        <CardActions sx={{ justifyContent: 'flex-end' }}>
                            <Typography variant="caption">{new Date(file.updatedAt).toLocaleDateString()}</Typography>
                        </CardActions>
                    </Card>
                </Grid>
            ))}
        </Grid>
    </Box>
);

const PomodoroScreen = () => {
    const [timeLeft, setTimeLeft] = React.useState(25 * 60);
    const [isActive, setIsActive] = React.useState(false);
    const [isFocusMode, setIsFocusMode] = React.useState(false);
    const timerRef = React.useRef(null);

    React.useEffect(() => {
        if (isActive) { timerRef.current = setInterval(() => setTimeLeft(t => t > 0 ? t - 1 : 0), 1000); }
        else { clearInterval(timerRef.current); }
        return () => clearInterval(timerRef.current);
    }, [isActive]);

    const formatTime = (s) => `${Math.floor(s / 60).toString().padStart(2, '0')}:${(s % 60).toString().padStart(2, '0')}`;
    const progress = (timeLeft / (25 * 60)) * 100;

    if (isFocusMode) {
        return (
            <Box sx={{ position: 'fixed', top: 0, left: 0, width: '100%', height: '100%', bgcolor: 'black', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', zIndex: 9999 }}>
                <Typography variant="h1" sx={{ color: 'primary.main', fontWeight: 'bold' }}>{formatTime(timeLeft)}</Typography>
                <IconButton onClick={() => setIsFocusMode(false)} sx={{ position: 'absolute', top: 20, right: 20, color: 'white' }}><Icon>fullscreen_exit</Icon></IconButton>
            </Box>
        );
    }

    return (
        <Box p={3} display="flex" flexDirection="column" alignItems="center" justifyContent="center" height="100%">
            <Box display="flex" justifyContent="space-between" width="100%" maxWidth="sm" alignItems="center">
                <Typography variant="h4" gutterBottom>Timer Pomodoro</Typography>
                <IconButton onClick={() => setIsFocusMode(true)}><Icon>fullscreen</Icon></IconButton>
            </Box>
            <Box sx={{ position: 'relative', display: 'inline-flex', my: 4 }}>
                <CircularProgress variant="determinate" value={100} size={200} sx={{ color: 'grey.300' }} />
                <CircularProgress variant="determinate" value={progress} size={200} sx={{ position: 'absolute', left: 0 }} />
                <Box sx={{ top: 0, left: 0, bottom: 0, right: 0, position: 'absolute', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Typography variant="h3">{formatTime(timeLeft)}</Typography></Box>
            </Box>
            <Box>
                <Button variant="contained" onClick={() => setIsActive(!isActive)} sx={{ mr: 2 }} startIcon={<Icon>{isActive ? 'pause' : 'play_arrow'}</Icon>}>{isActive ? 'Pausar' : 'Iniciar'}</Button>
                <Button onClick={() => { setIsActive(false); setTimeLeft(25 * 60); }} startIcon={<Icon>replay</Icon>}>Resetar</Button>
            </Box>
        </Box>
    );
};

const ItemEditorDialog = ({ open, onClose, item, onSave, onDelete }) => {
    const [title, setTitle] = React.useState('');
    const [content, setContent] = React.useState('');
    const [category, setCategory] = React.useState('ons');
    const [priority, setPriority] = React.useState('normal');
    const ActualReactMarkdown = ReactMarkdown.default || ReactMarkdown;

    React.useEffect(() => { if (item) { setTitle(item.title || ''); setContent(item.content || ''); setCategory(item.category || 'ons'); setPriority(item.priority || 'normal'); } }, [item]);
    if (!item) return null;
    const handleSave = () => onSave({ ...item, title, content, category, priority });

    return (
        <Dialog open={open} onClose={onClose} fullWidth maxWidth="lg">
            <DialogTitle>Editar Item<IconButton onClick={onClose} sx={{ position: 'absolute', right: 8, top: 8 }}><Icon>close</Icon></IconButton></DialogTitle>
            <DialogContent dividers>
                <TextField label="Título" value={title} onChange={(e) => setTitle(e.target.value)} fullWidth margin="normal" />
                <Grid container spacing={2}>
                    <Grid item xs={6}><Select value={category} onChange={(e) => setCategory(e.target.value)} fullWidth>{Object.entries(CATEGORIES).map(([k, v]) => <MenuItem key={k} value={k}>{v.label}</MenuItem>)}</Select></Grid>
                    <Grid item xs={6}><Select value={priority} onChange={(e) => setPriority(e.target.value)} fullWidth>{Object.entries(PRIORITIES).map(([k, v]) => <MenuItem key={k} value={k}>{v.label}</MenuItem>)}</Select></Grid>
                </Grid>
                <Grid container spacing={2} sx={{ mt: 1, height: '50vh' }}>
                    <Grid item xs={12} md={6}><TextField label="Conteúdo (Markdown)" value={content} onChange={(e) => setContent(e.target.value)} fullWidth multiline sx={{ height: '100%', '& .MuiOutlinedInput-root': { height: '100%' } }} /></Grid>
                    <Grid item xs={12} md={6}><Box border={1} borderColor="grey.300" borderRadius={1} p={2} sx={{ overflowY: 'auto', height: '100%' }}><div className="prose"><ActualReactMarkdown>{content}</ActualReactMarkdown></div></Box></Grid>
                </Grid>
            </DialogContent>
            <DialogActions><Button onClick={() => onDelete(item.id)} color="error">Excluir</Button><Box sx={{ flex: '1 0 0' }} /><Button onClick={onClose}>Cancelar</Button><Button onClick={handleSave} variant="contained">Salvar</Button></DialogActions>
        </Dialog>
    );
};

// =============================================================================
// COMPONENTE APP PRINCIPAL
// =============================================================================
function App() {
    const [mobileOpen, setMobileOpen] = React.useState(false);
    const [currentScreen, setCurrentScreen] = React.useState('kanban');
    const [isEditing, setIsEditing] = React.useState(false);
    const [editingItem, setEditingItem] = React.useState(null);
    const [projects, setProjects] = React.useState([]);
    const [files, setFiles] = React.useState([]);
    const [editingFile, setEditingFile] = React.useState(null);
    const [draggingItem, setDraggingItem] = React.useState(null);
    const [dragOverColumn, setDragOverColumn] = React.useState(null);

    const theme = createTheme();
    const isMobile = useMediaQuery(theme.breakpoints.down('sm'));

    React.useEffect(() => {
        refreshAllData();
    }, []);

    const refreshAllData = () => {
        setProjects([...repository.getProjects()]);
        setFiles([...repository.getFiles()]);
    }

    const handleDrawerToggle = () => setMobileOpen(!mobileOpen);
    const handleOpenEditor = (item) => { setEditingItem(item); setIsEditing(true); };
    const handleAddItem = (status) => handleOpenEditor({ title: 'Novo Item', status, category: 'ons', priority: 'normal', content: '' });
    const handleSaveItem = (item) => { item.id ? repository.updateProject(item.id, item) : repository.addProject(item); refreshAllData(); setIsEditing(false); };
    const handleDeleteItem = (id) => { repository.deleteProject(id); refreshAllData(); setIsEditing(false); };

    const handleFileSelect = (file) => setEditingFile(file);
    const handleAddFile = () => setEditingFile({ title: 'Novo Documento', content: '' });
    const handleSaveFile = (file) => { file.id ? repository.updateFile(file.id, file) : repository.addFile(file); refreshAllData(); setEditingFile(null); };
    const handleDeleteFile = (id) => { repository.deleteFile(id); refreshAllData(); setEditingFile(null); };

    const handleDragStart = (e, item) => { e.dataTransfer.setData("itemId", item.id); setDraggingItem(item.id); };
    const handleDragEnd = () => { setDraggingItem(null); setDragOverColumn(null); };
    const handleDropItem = (id, newStatus) => { repository.updateProject(id, { status: newStatus }); refreshAllData(); };

    const drawerWidth = 240;
    const menuItems = [{ id: 'dashboard', text: 'Dashboard', icon: 'dashboard' }, { id: 'kanban', text: 'Kanban', icon: 'view_kanban' }, { id: 'table', text: 'Tabelas', icon: 'table_view' }, { id: 'documents', text: 'Documentos', icon: 'article' }, { id: 'pomodoro', text: 'Pomodoro', icon: 'timer' }];

    const drawerContent = (
        <Box><Toolbar><Icon sx={{ mr: 2 }}>dynamic_feed</Icon><Typography variant="h6">Kanban Pro</Typography></Toolbar>
            <List>{menuItems.map(i => <ListItem key={i.id} disablePadding><ListItemButton selected={currentScreen === i.id} onClick={() => { setCurrentScreen(i.id); isMobile && handleDrawerToggle(); }}><ListItemIcon><Icon>{i.icon}</Icon></ListItemIcon><ListItemText primary={i.text} /></ListItemButton></ListItem>)}</List></Box>
    );

    const KanbanScreenComponent = () => (
        <Box sx={{ display: 'flex', overflowX: 'auto', p: 2, gap: 2, height: '100%' }}>
            {Object.entries(STATUS_COLUMNS).map(([status, info]) => (
                <Paper key={status} onDragOver={(e) => e.preventDefault()} onDragEnter={() => setDragOverColumn(status)} onDrop={(e) => { e.preventDefault(); handleDropItem(e.dataTransfer.getData("itemId"), status); }}
                    sx={{ p: 1.5, bgcolor: dragOverColumn === status ? 'primary.light' : '#f0f2f5', transition: 'background-color 0.3s ease', display: 'flex', flexDirection: 'column', minWidth: 300, height: `calc(100vh - ${isMobile ? '120px' : '110px'})` }}>
                    <Box display="flex" justifyContent="space-between" alignItems="center" mb={2} px={1}><Typography variant="h6" sx={{ display: 'flex', alignItems: 'center', gap: 1, fontSize: '1rem', fontWeight: 'bold' }}><span>{info.emoji}</span> {info.title}</Typography><IconButton size="small" onClick={() => handleAddItem(status)}><Icon>add_circle_outline</Icon></IconButton></Box>
                    <Box className="kanban-column-content" sx={{ overflowY: 'auto', flexGrow: 1, p: 1 }}>{projects.filter(p => p.status === status).map(item => <KanbanCard key={item.id} item={item} onEdit={handleOpenEditor} isDragging={draggingItem === item.id} onDragStart={(e) => handleDragStart(e, item)} onDragEnd={handleDragEnd} />)}</Box>
                </Paper>
            ))}
        </Box>
    );

    const renderScreen = () => {
        switch (currentScreen) {
            case 'dashboard': return <DashboardScreen />;
            case 'kanban': return <KanbanScreenComponent />;
            case 'table': return <TableScreen />;
            case 'documents': return <DocumentsScreen files={files} onFileSelect={handleFileSelect} onAddFile={handleAddFile} />;
            case 'pomodoro': return <PomodoroScreen />;
            default: return <Typography p={3}>Tela não encontrada</Typography>;
        }
    };

    return (
        <ThemeProvider theme={createTheme()}>
            <Box sx={{ display: 'flex', height: '100vh', overflow: 'hidden' }}>
                <CssBaseline />
                <AppBar position="fixed" sx={{ zIndex: (t) => t.zIndex.drawer + 1 }}><Toolbar><IconButton color="inherit" edge="start" onClick={handleDrawerToggle} sx={{ mr: 2, display: { sm: 'none' } }}><Icon>menu</Icon></IconButton><Typography variant="h6">{menuItems.find(i => i.id === currentScreen)?.text}</Typography></Toolbar></AppBar>
                <Box component="nav" sx={{ width: { sm: drawerWidth }, flexShrink: { sm: 0 } }}><Drawer variant={isMobile ? "temporary" : "permanent"} open={isMobile ? mobileOpen : true} onClose={handleDrawerToggle} sx={{ '& .MuiDrawer-paper': { width: drawerWidth } }}>{drawerContent}</Drawer></Box>
                <Box component="main" sx={{ flexGrow: 1, width: { sm: `calc(100% - ${drawerWidth}px)` }, display: 'flex', flexDirection: 'column' }}><Toolbar />{renderScreen()}</Box>
                <ItemEditorDialog open={isEditing} onClose={() => setIsEditing(false)} item={editingItem} onSave={handleSaveItem} onDelete={handleDeleteItem} />
                {editingFile && <MarkdownEditor file={editingFile} onClose={() => setEditingFile(null)} onSave={handleSaveFile} onDelete={handleDeleteFile} />}
            </Box>
        </ThemeProvider>
    );
}

ReactDOM.render(<App />, document.getElementById('root'));