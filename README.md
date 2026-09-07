# README

ER圖

erDiagram
    USERS ||--o{ GROUP_MEMBERS : joins
    GROUPS ||--o{ GROUP_MEMBERS : includes
    USERS ||--o{ TASKS : creates
    GROUPS ||--o{ TASKS : belongs_to
    TASKS ||--o{ TASK_LABELS : has
    LABELS ||--o{ TASK_LABELS : applies_to
    GROUPS ||--o{ LABELS : defines
    USERS ||--o{ ACTIVITIES : performs
    GROUPS ||--o{ ACTIVITIES : logs_in

    USERS {
        bigint id PK
        string name
        string email
        string password_digest
    }
    GROUPS {
        bigint id PK
        string name
    }
    GROUP_MEMBERS {
        bigint id PK
        bigint group_id FK
        bigint user_id FK
        string role
    }
    TASKS {
        bigint id PK
        bigint group_id FK
        bigint creator_id FK
        string title
        text content
        integer status
        integer priority
        date start_date
        date due_date
    }
    LABELS {
        bigint id PK
        bigint group_id FK
        string name
        string color
    }
    TASK_LABELS {
        bigint id PK
        bigint task_id FK
        bigint label_id FK
    }
    ACTIVITIES {
        bigint id PK
        bigint group_id FK
        bigint user_id FK
        string action
        string target_title
    }


## 本地環境建置步驟

### 依賴環境
- Ruby (版本見 Gemfile)
- PostgreSQL
- Overmind & tmux

### 資料庫與伺服器設定
1. 啟動 PostgreSQL 服務：
   ```bash
   sudo service postgresql start
   ```
2. 安裝相依套件：
   ```bash
   bundle install
   ```
3. 建立並準備資料庫：
   ```bash
   bin/rails db:create
   ```
4. 啟動開發環境：
   ```bash
   bin/dev
   ```
   伺服器預設運行於 http://localhost:3000