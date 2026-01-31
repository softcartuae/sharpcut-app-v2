# Project Architecture & Data Flow

## 1. System Overview

The system optimizes for **Offline Availability** using a local SQLite database as the primary data source for the UI. Synchronization with the server is event-driven and periodic.

| Component              | Technology         | Responsibility                                         |
| :--------------------- | :----------------- | :----------------------------------------------------- |
| **Server**             | REST API           | Central Authority, Cloud Storage, Authentication.      |
| **Mobile App (Logic)** | Dart/Flutter       | Business Rules, Sync Orchestration, API Communication. |
| **Local Database**     | SQLite (`sqflite`) | Offline Cache, Transaction Storage, Reporting Source.  |
| **UI**                 | Flutter Widgets    | Displays data _only_ from Local DB (Read Model).       |

---

## 2. Database Structure (Local SQLite)

| Table Name             | Description                | Key Fields                                     | Sync Strategy             |
| :--------------------- | :------------------------- | :--------------------------------------------- | :------------------------ |
| `users`                | Staff & Admin login info   | `id`, `role`, `password`, `is_synced`          | **Pull Only** (Auth)      |
| `chairs`               | Salon chairs configuration | `id`, `shop_id`, `live_status`                 | **Pull Only** (Ref Data)  |
| `services`             | Service menu & pricing     | `id`, `charge`, `tax_option`                   | **Pull Only** (Ref Data)  |
| `transactions`         | **CORE**: Bookings & Sales | `id`, `status`, `final_total`, `is_synced`     | **Push & Pull** (Two-way) |
| `transaction_payments` | Payment breakdown          | `transaction_id`, `mode` (Cash/Card), `amount` | **Push** (Child of Txn)   |
| `cash_registers`       | Shift/Day tracking         | `id`, `opened_at`, `closed_at`, `is_synced`    | **Push** (Up-Sync)        |

---

## 3. Detailed Data Flows

### A. Data Pull (Down-Sync)

- **Trigger**: App Start, Manual Refresh, or Navigation to Home.
- **Action**: Fetch data from API $\rightarrow$ Save to DB $\rightarrow$ Send Acknowledgment.

```mermaid
sequenceDiagram
    participant UI as User Interface
    participant Repo as Repository
    participant API as Server API
    participant DB as Local SQLite

    UI->>Repo: 1. Request Data (e.g. Chairs)
    Repo->>API: 2. GET /api/chairs?is_synced=0
    activate API
    API-->>Repo: 3. Return JSON List
    deactivate API

    Repo->>DB: 4. INSERT / UPDATE Items
    activate DB
    DB-->>Repo: Success
    deactivate DB

    Repo->>API: 5. POST /api/chairs/sync (Ack IDs)
    Note right of Repo: "I received IDs: [1, 2, 5]"

    Repo->>UI: 6. Return Data (Load form DB if needed)
```

### B. Data Push (Up-Sync)

- **Trigger**: Timer, Manual Sync Button, or End of Transaction.
- **Logic**: `SyncToServer` checks for dirty records (`is_synced = 0`).

```mermaid
sequenceDiagram
    participant Sync as SyncToServer
    participant DB as Local SQLite
    participant API as Server API

    Sync->>DB: 1. SELECT * FROM transactions WHERE is_synced = 0
    activate DB
    DB-->>Sync: Returns [Txn A, Txn B]
    deactivate DB

    loop For Each Batch
        Sync->>DB: Fetch related Services & Payments
        Sync->>API: 2. POST /api/transactions/sync (JSON Payload)
        activate API
        API-->>Sync: 3. HTTP 200 OK
        deactivate API

        Sync->>DB: 4. UPDATE transactions SET is_synced = 1
    end
```

### C. Resettlement & Reporting

- **Resettlement**: Modifying a past transaction.
- **Reporting**: Generating views from local data.

```mermaid
flowchart TB
    subgraph Action_Resettle [Resettlement Action]
        direction TB
        R1[User modifies Discount/Payment]
        R2[TransactionDao.reSettlePayment]
        R3[UPDATE transaction details]
        R4[INSERT new payment rows]
        R5[SET is_synced = 0]

        R1 --> R2 --> R3 --> R4 --> R5
    end

    subgraph Action_Report [Report Generation]
        direction TB
        Rep1[User requests Daily Report]
        Rep2[TransactionDao.getOfflineReportData]
        Rep3[SQL JOIN: Transactions + Payments + Users]
        Rep4[Calculate Totals: Cash vs Card]
        Rep5[Return Report Object]

        Rep1 --> Rep2 --> Rep3 --> Rep4 --> Rep5
    end

    R5 -.->|Next Sync Cycle| Push_to_Server
    Rep5 -->|Display| UI_Screen
```

---

## 4. Architecture Swimlane Diagram

This diagram aligns the components side-by-side to show responsibilities clearly.

```mermaid
classDiagram
    class Server_Layer {
        <<Cloud>>
        +API Endpoints
        +Remote Database
    }

    class Logic_Layer {
        <<App Code>>
        +Repositories (Fetch)
        +SyncToServer (Push)
        +TransactionDao (Process)
        +ReportRepo (Analyze)
    }

    class Database_Layer {
        <<SQLite>>
        +Table: users
        +Table: chairs
        +Table: transactions
        +Table: payments
    }

    Server_Layer <..> Logic_Layer : JSON / HTTP
    Logic_Layer <..> Database_Layer : CRUD / SQL
```

```mermaid
graph TD
    %% Define Swimlanes using Subgraphs
    subgraph Server_Lane [SERVER (Cloud)]
        direction TB
        API_Get[GET Data endpoint]
        API_Post[POST Sync endpoint]
    end

    subgraph Logic_Lane [APP LOGIC (Dart)]
        direction TB
        Repo[Repository Layer]
        SyncMgr[Sync Manager]
        Resettle[Resettlement Logic]
    end

    subgraph DB_Lane [LOCAL DB (SQLite)]
        direction TB
        Table_Ref[Ref Data: Chairs/Services]
        Table_Txn[Txn Data: Bookings/Payments]
    end

    %% Flows

    %% Pull
    API_Get ==JSON==> Repo
    Repo --Save--> Table_Ref
    Repo --Ack IDs--> API_Post

    %% Push
    Table_Txn --Unsynced Records--> SyncMgr
    SyncMgr --Batch Upload--> API_Post
    SyncMgr --Mark Synced--> Table_Txn

    %% Interact
    Resettle --Update & Reset Sync Flag--> Table_Txn
```
