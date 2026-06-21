# TaskCal

Aplicativo Flutter de calendário com lista de tarefas diárias.  
Projeto desenvolvido para a ACQA da disciplina **Desenvolvimento para Dispositivos Móveis** — Uniube.

---

## Telas do App

- **Login / Cadastro** — autenticação local com validação de campos
- **Calendário** — visualização mensal com marcadores de tarefas por dia
- **Lista de Tarefas** — adicionar, remover e marcar tarefas como concluídas

---

## Pré-requisitos

Antes de rodar, certifique-se de ter instalado:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão 3.0 ou superior)
- [Android Studio](https://developer.android.com/studio) com emulador Android configurado  
  **ou** um celular Android com modo desenvolvedor ativado
- Git (opcional, para clonar o repositório)

Para verificar se o Flutter está instalado corretamente, abra o terminal e execute:

```
flutter doctor
```

---

## Como rodar o projeto

### 1. Abra a pasta do projeto no terminal

```
cd caminho/para/task_calendar_app
```

### 2. Instale as dependências

```
flutter pub get
```

### 3. Inicie um emulador ou conecte um dispositivo

No Android Studio: **Device Manager > Play** para iniciar o emulador.  
Ou conecte um celular Android via USB com depuração USB ativada.

### 4. Execute o aplicativo

```
flutter run
```

Se houver mais de um dispositivo conectado, escolha com:

```
flutter run -d <id_do_dispositivo>
```

---

## Estrutura dos arquivos .dart

```
lib/
├── main.dart                   # Ponto de entrada
├── theme/
│   └── app_theme.dart          # Cores e estilo visual
├── models/
│   ├── task.dart               # Modelo de Tarefa
│   └── user.dart               # Modelo de Usuário
└── screens/
    ├── login_screen.dart       # Tela de Login
    ├── register_screen.dart    # Tela de Cadastro
    ├── calendar_screen.dart    # Tela do Calendário
    └── task_list_screen.dart   # Tela de Lista de Tarefas
```

---

## Dependências utilizadas

| Pacote | Versão | Uso |
|---|---|---|
| `table_calendar` | ^3.0.9 | Calendário interativo |
| `shared_preferences` | ^2.2.2 | Armazenamento local |
| `intl` | ^0.19.0 | Formatação de datas em pt-BR |

---

## Autor

Gabriel — Análise e Desenvolvimento de Sistemas — Uniube
