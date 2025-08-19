# Funcionalidades do Projeto

Este documento descreve as funcionalidades do projeto de produtividade.

## Backend (API)

- **Fonte de Dados:** Utiliza o `json-server` com o arquivo `db.json` para armazenar os dados.
- **Operações:** Permite criar, ler, atualizar e deletar itens para as seções de Todo List, Plano de Atividades e Scrum Planner.
- **Exportação:** Possui um endpoint dedicado para exportar os dados para o formato `.xlsx`.

## Frontend (Interface do Usuário)

- **Dashboard:** Apresenta um resumo geral das tarefas e atividades.
- **Todo List:** Tela para gerenciar a lista de tarefas.
- **Plano de Atividades:** Tela para gerenciar o plano de atividades.
- **Scrum Planner:** Tela para organizar tarefas no formato de um quadro Scrum.
- **Exportar para Excel:** Um botão no dashboard para baixar os dados em formato de planilha.
- **Acúmulo de Tempo:** Um sistema para que o tempo gasto nas tarefas seja contabilizado automaticamente.
- **Depuração:** Exibição dos dados do banco de dados no console do navegador para facilitar o desenvolvimento e a depuração.
