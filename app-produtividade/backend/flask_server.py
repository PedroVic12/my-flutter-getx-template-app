from flask import Flask, request, jsonify
import pandas as pd
import os
from datetime import datetime
import uuid

DATA_DIR = "assets"
os.makedirs(DATA_DIR, exist_ok=True)

PLANO_ATIVIDADES_PATH = os.path.join(DATA_DIR, "PlanoAtividades.xlsx")
SCRUM_PLANNER_PATH = os.path.join(DATA_DIR, "ScrumPlanner.xlsx")
TODO_LIST_PATH = os.path.join(DATA_DIR, "TodoList.xlsx")

class Database:
    def __init__(self):
        self.paths = {
            "plano": PLANO_ATIVIDADES_PATH,
            "scrum": SCRUM_PLANNER_PATH,
            "todo": TODO_LIST_PATH
        }
        self.init_files()

    def init_files(self):
        self.check_and_create(self.paths["plano"], ["ID", "Prioridade", "Tempo", "Atividade", "Resultado Esperado", "Status"])
        self.check_and_create(self.paths["scrum"], ["ID", "Todo", "InProgress", "Concluido", "AgentesAI", "Projetos Parados"])
        self.check_and_create(self.paths["todo"], ["ID", "Atividade", "Categoria", "Tempo", "Data", "Status", "NotionLink", "ClickUpLink", "Deleted"])

    def check_and_create(self, path, columns):
        if not os.path.exists(path):
            pd.DataFrame(columns=columns).to_excel(path, index=False)

    def read(self, key):
        return pd.read_excel(self.paths[key])

    def save(self, key, df):
        df.to_excel(self.paths[key], index=False)

    def generate_id(self):
        return str(uuid.uuid4())

class Server:
    def __init__(self, db):
        self.db = db
        self.app = Flask(__name__)
        self.setup_routes()

    def setup_routes(self):
        @self.app.route("/", methods=["GET"])
        def index():
            return "<h1> Bem-vindo ao servidor Flask para produtividade! </h1>"

        @self.app.route('/api/todo', methods=['GET'])
        def get_todo_list():
            df = self.db.read("todo")
            df = df[df['Deleted'] != True]
            return jsonify(df.fillna('').to_dict(orient='records'))

        @self.app.route('/api/todo', methods=['POST'])
        def add_todo():
            data = request.json
            df = self.db.read("todo")
            new_row = {
                "ID": self.db.generate_id(),
                "Atividade": data.get("Atividade", ""),
                "Categoria": data.get("Categoria", "Geral"),
                "Tempo": data.get("Tempo", 0),
                "Data": datetime.now().strftime("%Y-%m-%d"),
                "Status": "Pendente",
                "NotionLink": data.get("NotionLink", ""),
                "ClickUpLink": data.get("ClickUpLink", ""),
                "Deleted": False
            }
            new_df = pd.concat([df, pd.DataFrame([new_row])], ignore_index=True)
            self.db.save("todo", new_df)
            return jsonify({"success": True, "id": new_row["ID"]})

        @self.app.route('/api/todo/<todo_id>', methods=['PUT'])
        def update_todo(todo_id):
            data = request.json
            df = self.db.read("todo")
            if todo_id not in df['ID'].values:
                return jsonify({"error": "Tarefa não encontrada"}), 404
            idx = df.index[df['ID'] == todo_id].tolist()[0]
            for key in data:
                if key in df.columns:
                    df.at[idx, key] = data[key]
            self.db.save("todo", df)
            return jsonify({"success": True})

        @self.app.route('/api/todo/<todo_id>', methods=['DELETE'])
        def delete_todo(todo_id):
            df = self.db.read("todo")
            if todo_id not in df['ID'].values:
                return jsonify({"error": "Tarefa não encontrada"}), 404
            idx = df.index[df['ID'] == todo_id].tolist()[0]
            df.at[idx, 'Deleted'] = True
            self.db.save("todo", df)
            return jsonify({"success": True})

        @self.app.route('/api/todo/<todo_id>/add_time', methods=['POST'])
        def add_time_to_todo(todo_id):
            data = request.json
            minutes = data.get("minutes", 0)
            df = self.db.read("todo")
            if todo_id not in df['ID'].values:
                return jsonify({"error": "Tarefa não encontrada"}), 404
            idx = df.index[df['ID'] == todo_id].tolist()[0]
            current_time = df.at[idx, 'Tempo'] or 0
            df.at[idx, 'Tempo'] = current_time + minutes
            self.db.save("todo", df)
            return jsonify({"success": True})

        @self.app.route('/api/plano_atividades', methods=['GET'])
        def get_plano_atividades():
            df = self.db.read("plano")
            return jsonify(df.fillna('').to_dict(orient='records'))

        @self.app.route('/api/plano_atividades', methods=['POST'])
        def add_plano_atividade():
            data = request.json
            df = self.db.read("plano")
            new_row = {
                "ID": self.db.generate_id(),
                "Prioridade": data.get("Prioridade", 1),
                "Tempo": data.get("Tempo", 0),
                "Atividade": data.get("Atividade", ""),
                "Resultado Esperado": data.get("Resultado Esperado", ""),
                "Status": "Planejado"
            }
            new_df = pd.concat([df, pd.DataFrame([new_row])], ignore_index=True)
            self.db.save("plano", new_df)
            return jsonify({"success": True})

        @self.app.route('/api/scrum_planner', methods=['GET'])
        def get_scrum_planner():
            df = self.db.read("scrum")
            return jsonify(df.fillna('').to_dict(orient='records'))

        @self.app.route('/api/scrum_planner/move', methods=['POST'])
        def move_scrum_item():
            data = request.json
            item_id = data["id"]
            from_col = data["from"]
            to_col = data["to"]
            df = self.db.read("scrum")
            if item_id not in df['ID'].values:
                return jsonify({"error": "Item não encontrado"}), 404
            idx = df.index[df['ID'] == item_id].tolist()[0]
            if from_col in df.columns and to_col in df.columns:
                df.at[idx, from_col] = False
                df.at[idx, to_col] = True
            self.db.save("scrum", df)
            return jsonify({"success": True})

def main():
    db = Database()
    server = Server(db)
    server.app.run(debug=True, port=5000)

if __name__ == '__main__':
    main()
