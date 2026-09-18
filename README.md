# Ruby on Rails Task App

## 線上網站

- Render：<https://ruby-on-rails-test.onrender.com>
- Health check：<https://ruby-on-rails-test.onrender.com/up>

Render 免費方案可能會讓閒置服務休眠，因此第一次開啟網站時可能需要等待幾十秒。

## 使用的 framework 與主要版本

版本以 `Gemfile` 與 `Gemfile.lock` 為準：

- Ruby `4.0.6`
- Rails `8.1.3.1`
- PostgreSQL adapter `pg 1.6.3`
- Puma `8.0.2`
- Propshaft `1.3.2`
- Tailwind CSS Rails `4.6.0`
- Importmap Rails `2.2.3`
- Turbo Rails `2.0.23`
- Stimulus Rails `1.3.4`
- Solid Cache `1.0.10`
- Solid Queue `1.7.0`

## 網站操作

網站首頁會顯示所有任務，任務依建立時間排序。可使用以下功能：

1. **新增任務**：按下新增任務，填寫標題、內容與狀態後儲存。
2. **查看任務**：在列表中選擇任務，查看詳細內容。
3. **編輯任務**：在任務詳細頁按下編輯，修改資料後儲存。
4. **刪除任務**：在任務詳細頁按下刪除，確認後移除任務。

目前任務可編輯的欄位為 `title`、`content` 與 `status`。

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

## 部署到 Render

本專案使用 Render Web Service 部署 Rails app，並使用 Neon 或 Supabase 的免費 PostgreSQL 作為外部資料庫。Render 不使用免費 PostgreSQL，避免其 30 天期限。

### Render Service 設定

在 Render 建立 Web Service，連接 GitHub repository 的 `main` branch，設定：

- Environment：`Ruby`
- Build Command：
  ```bash
  bash bin/render-build.sh
  ```
- Start Command：
  ```bash
  bundle exec puma -C config/puma.rb
  ```

`bin/render-build.sh` 會依序執行 `bundle install`、資產編譯、資產清理與 `db:migrate`。

### Render 環境變數

在 Render Web Service 的 Environment 設定：

| Key | Value |
| --- | --- |
| `DATABASE_URL` | Neon 或 Supabase 提供的完整 PostgreSQL connection string |
| `RAILS_ENV` | `production` |
| `RAILS_MASTER_KEY` | 本機 `config/master.key` 的內容 |
| `RAILS_MAX_THREADS` | `3` |

`DATABASE_URL` 應包含 `postgresql://` 與 SSL 參數，例如：

```text
postgresql://USER:PASSWORD@HOST/DATABASE?sslmode=require
```

不要將 `config/master.key`、資料庫密碼或完整 `DATABASE_URL` 提交到 GitHub。`config/master.key` 只應透過 Render 的環境變數提供。

### 發布新版本

在 WSL 的專案目錄完成修改與測試後：

```bash
git add .
git commit -m "Describe the change"
git push origin main
```

Render 連接 `main` branch 後會自動部署。若未自動部署，可在 Render Dashboard 選擇 **Manual Deploy → Deploy latest commit**。

部署流程會：

1. 取得 GitHub 最新 commit。
2. 安裝 Ruby gems。
3. 編譯前端資產。
4. 執行資料庫 migration。
5. 使用 Puma 啟動 Rails production server。

Build 失敗時查看 Render 的 **Build Logs**；服務啟動後的錯誤查看 **Runtime Logs**。Render 的環境變數會保留在平台上，不會被 GitHub push 覆蓋。