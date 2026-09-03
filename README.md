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

