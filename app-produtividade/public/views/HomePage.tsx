


async function getData() {
  const response = await fetch('https://jsonplaceholder.typicode.com/posts');
  if (!response.ok) {
    throw new Error('Network response was not ok');
  }
  return response.json();
}


async function TodoContainer(){
    const data = await getData();
    return (
        <div className="wrapper">
            <div className="container">
                <h1> Lista de Tarefas Nextjs</h1>
                <span>
                    <Link href="/todos" className="btn btn-primary">
                        Ver Tarefas
                    </Link>
                </span>

                {
                    data.lenght > 0 ? (
                        <ul className="list-disc pl-5">
                            {data.slice(0, 10).map((item: { id: number; title: string }) => (
                                <li key={item.id} className="mb-2">
                                    {item.title}
                                </li>
                            ))}
                        </ul>
                    ) : (
                        <p className="text-red-500">Nenhuma tarefa encontrada.</p>
                    )
                }

            </div>

        </div>
    );
}


async function AddTodoContainer(params, searchParams) {
  const { id } = params;
  const { search } = searchParams;

  return (
    <div className="addTodo">
      <div className="container">
        <h1>Adicionar Tarefa</h1>
        <p>ID: {id}</p>
        <p>Search: {search}</p>
        {/* Formulário de adição de tarefa pode ser implementado aqui */}
        <form className="space-y-4">
          <div>
            <label htmlFor="title" className="block text-sm font-medium text-gray-700">Título</label>
            <input type="text" id="title" name="title" className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm" />
          </div>
          <div>
            <label htmlFor="description" className="block text-sm font-medium text-gray-700">Descrição</label>
            <textarea id="description" name="description" rows={3} className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm"></textarea>
          </div>
          <button type="submit" className="btn btn-primary">Adicionar Tarefa</button>
        </form>
        <div className="mt-4">
          <Link href="/todos" className="btn btn-secondary">
            Voltar para Tarefas
          </Link>

          <div>
            <Link href={`/todos/${id}?search=${search}`} className="btn btn-secondary ml-2">
              Ver Tarefa Específica
            </Link>

            </div>

                
      </div>
    </div>
  );
    
}


export default async function HomePage() {
  const data = await getData();

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Home Page</h1>
      <ul className="list-disc pl-5">
        {data.slice(0, 10).map((item: { id: number; title: string }) => (
          <li key={item.id} className="mb-2">
            {item.title}
          </li>
        ))}
      </ul>
    </div>
  );
}
