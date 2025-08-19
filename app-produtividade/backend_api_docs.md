# Backend API Documentation

This document provides the documentation for the backend API of the productivity application.

## Todo List API

### Get all tasks

- **Method:** `GET`
- **URL:** `/api/todo`
- **Description:** Retrieves a list of all tasks from the todo list.
- **Success Response:**
  ```json
  [
    {
      "Atividade": "Test Task",
      "Categoria": "Testing",
      "ClickUpLink": "",
      "Data": "2025-08-18",
      "Deleted": false,
      "ID": "e82cca72-29d1-4235-89c8-a9e90123b11d",
      "NotionLink": "",
      "Status": "Pendente",
      "Tempo": 0
    }
  ]
  ```

### Add a new task

- **Method:** `POST`
- **URL:** `/api/todo`
- **Description:** Adds a new task to the todo list.
- **Request Body:**
  ```json
  {
    "Atividade": "Your Task Title",
    "Categoria": "Task Category",
    "Tempo": 60,
    "NotionLink": "https://notion.so/...",
    "ClickUpLink": "https://clickup.com/..."
  }
  ```
- **Success Response:**
  ```json
  {
    "success": true,
    "id": "e82cca72-29d1-4235-89c8-a9e90123b11d"
  }
  ```

## Activity Plan API

### Get all activities

- **Method:** `GET`
- **URL:** `/api/plano_atividades`
- **Description:** Retrieves a list of all activities from the activity plan.
- **Success Response:**
  ```json
  [
    {
      "Atividade": "Test Activity",
      "ID": "2503fdd0-8160-4081-9aa3-6b828dd6d724",
      "Prioridade": 1,
      "Resultado Esperado": "Test Result",
      "Status": "Planejado",
      "Tempo": 60
    }
  ]
  ```

### Add a new activity

- **Method:** `POST`
- **URL:** `/api/plano_atividades`
- **Description:** Adds a new activity to the activity plan.
- **Request Body:**
  ```json
  {
    "Atividade": "Your Activity Title",
    "Prioridade": 1,
    "Tempo": 120,
    "Resultado Esperado": "Expected Outcome"
  }
  ```
- **Success Response:**
  ```json
  {
    "success": true
  }
  ```

## Scrum Planner API

### Get all scrum items

- **Method:** `GET`
- **URL:** `/api/scrum_planner`
- **Description:** Retrieves a list of all items from the scrum planner.
- **Success Response:**
  ```json
  [
    {
      "AgentesAI": "MyAgent",
      "Concluido": false,
      "ID": "7fafb3ef-e418-4d85-a3ad-73d87c1a61c7",
      "InProgress": false,
      "Projetos Parados": false,
      "Todo": true
    }
  ]
  ```

### Add a new scrum item

- **Method:** `POST`
- **URL:** `/api/scrum_planner`
- **Description:** Adds a new item to the scrum planner.
- **Request Body:**
  ```json
  {
    "Todo": true,
    "InProgress": false,
    "Concluido": false,
    "AgentesAI": "Your Agent",
    "Projetos Parados": false
  }
  ```
- **Success Response:**
  ```json
  {
    "success": true,
    "id": "7fafb3ef-e418-4d85-a3ad-73d87c1a61c7"
  }
  ```

### Move a scrum item

- **Method:** `POST`
- **URL:** `/api/scrum_planner/move`
- **Description:** Moves an item from one column to another in the scrum planner.
- **Request Body:**
  ```json
  {
    "id": "7fafb3ef-e418-4d85-a3ad-73d87c1a61c7",
    "from": "Todo",
    "to": "InProgress"
  }
  ```
- **Success Response:**
  ```json
  {
    "success": true
  }
  ```

## Export API

### Export data

- **Method:** `GET`
- **URL:** `/api/export/<file_type>`
- **Description:** Exports data to a file. The `file_type` can be `todo`, `plano`, `scrum`, or `sqlite`.
- **Success Response:** The requested file to download.
