# Plan Schematu Bazy Danych - 10x-Cards

Ten dokument zawiera ostateczny plan schematu bazy danych PostgreSQL dla projektu 10x-Cards, oparty na wymaganiach PRD, notatkach z sesji planowania oraz wybranym stacku technologicznym (Supabase).

## 1. Struktura Tabel

Schemat wykorzystuje domyślny schemat `public` w PostgreSQL. Wszystkie tabele posiadają kolumny `created_at` i `updated_at` (gdzie dotyczy) dla celów audytowych.

### 1.1. `users`
Tabela rozszerzająca systemową tabelę `auth.users` Supabase. Tabela zarządzana przez Supabase Auth. Przechowuje profil użytkownika i stan gamifikacji.

| Nazwa kolumny | Typ danych | Ograniczenia / Domyślne | Opis |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | **PK**, FK -> `auth.users.id` (ON DELETE CASCADE) | Klucz główny tożsamy z ID użytkownika w Supabase Auth. |
| `english_level` | `TEXT` | CHECK (value IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')) | Poziom zaawansowania językowego użytkownika. |
| `daily_generations` | `INTEGER` | DEFAULT 0, NOT NULL | Licznik generacji wykonanych w bieżącym dniu. |
| `last_generation_date`| `DATE` | DEFAULT CURRENT_DATE | Data ostatniej próby generowania (do resetowania limitu). |
| `streak` | `INTEGER` | DEFAULT 0, NOT NULL | Liczba dni nauki z rzędu. |
| `created_at` | `TIMESTAMPTZ`| DEFAULT NOW(), NOT NULL | Data utworzenia profilu. |
| `updated_at` | `TIMESTAMPTZ`| DEFAULT NOW(), NOT NULL | Data ostatniej aktualizacji profilu. |

### 1.2. `generations`
Przechowuje teksty źródłowe wysłane do AI.

| Nazwa kolumny | Typ danych | Ograniczenia / Domyślne | Opis |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | **PK**, DEFAULT `gen_random_uuid()` | Unikalny identyfikator generacji. |
| `user_id` | `UUID` | NOT NULL, FK -> `public.users.id` (ON DELETE CASCADE) | Właściciel generacji. |
| `source_text` | `VARCHAR(10000)`| NOT NULL | Tekst źródłowy wklejony przez użytkownika. |
| `created_at` | `TIMESTAMPTZ`| DEFAULT NOW(), NOT NULL | Data wykonania generacji. |

### 1.3. `flashcards`
Główna tabela przechowująca fiszki (zarówno drafty, jak i zatwierdzone).

| Nazwa kolumny | Typ danych | Ograniczenia / Domyślne | Opis |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | **PK**, DEFAULT `gen_random_uuid()` | Unikalny identyfikator fiszki. |
| `user_id` | `UUID` | NOT NULL, FK -> `public.users.id` (ON DELETE CASCADE) | Właściciel fiszki. |
| `generation_id` | `UUID` | NULLABLE, FK -> `public.generations.id` (ON DELETE SET NULL) | Powiązanie z tekstem źródłowym. NULL dla fiszek ręcznych. |
| `front` | `VARCHAR(200)` | NOT NULL | Awers fiszki (słowo/zdanie). |
| `back_translation` | `VARCHAR(500)` | NOT NULL | Tłumaczenie na język polski. |
| `back_definition` | `VARCHAR(500)` | NULLABLE | Definicja w języku angielskim. |
| `back_example` | `VARCHAR(500)` | NULLABLE | Przykładowe zdanie. |
| `is_draft` | `BOOLEAN` | DEFAULT TRUE, NOT NULL | Flaga statusu (True = Draft/Recenzja, False = Baza wiedzy). |
| `source` | `VARCHAR(20)` | CHECK (value IN ('ai-full', 'ai-edited', 'manual')), DEFAULT 'ai-full' | Źródło pochodzenia fiszki. |
| `created_at` | `TIMESTAMPTZ`| DEFAULT NOW(), NOT NULL | Data utworzenia. |
| `updated_at` | `TIMESTAMPTZ`| DEFAULT NOW(), NOT NULL | Data ostatniej edycji. |

> **Uwaga:** Kolumny specyficzne dla algorytmu SuperMemo-2 (np. `interval`, `repetition_count`, `ease_factor`) zostały celowo pominięte na tym etapie zgodnie z decyzjami sesji planowania. Zostaną dodane w późniejszej migracji.

### 1.4. `generation_error_logs`
Tabela techniczna do monitorowania błędów integracji z AI.

| Nazwa kolumny | Typ danych | Ograniczenia / Domyślne | Opis |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | **PK**, DEFAULT `gen_random_uuid()` | ID logu błędu. |
| `user_id` | `UUID` | NOT NULL, FK -> `public.users.id` (ON DELETE CASCADE) | Użytkownik, którego dotyczył błąd. |
| `error_code` | `VARCHAR(50)` | NULLABLE | Kod błędu (np. od dostawcy API lub wewnętrzny). |
| `error_message` | `TEXT` | NOT NULL | Treść komunikatu błędu. |
| `created_at` | `TIMESTAMPTZ`| DEFAULT NOW(), NOT NULL | Czas wystąpienia błędu. |

---

## 2. Relacje (ERD)

1.  **Users - Generations (1:N):**
    *   Jeden użytkownik może mieć wiele historii generacji.
    *   Usunięcie użytkownika usuwa jego historię generacji (`CASCADE`).

2.  **Users - Flashcards (1:N):**
    *   Jeden użytkownik posiada wiele fiszek.
    *   Usunięcie użytkownika usuwa wszystkie jego fiszki (`CASCADE`).

3.  **Generations - Flashcards (1:N):**
    *   Jedna generacja może wyprodukować wiele fiszek.
    *   Usunięcie generacji (tekstu źródłowego) NIE usuwa fiszek, lecz ustawia `generation_id` na NULL (`SET NULL`), zachowując fiszki w bazie użytkownika.

4.  **Auth.Users - Public.Users (1:1):**
    *   Ścisłe powiązanie tabeli systemowej Supabase z tabelą profilową aplikacji.

---

## 3. Indeksy i Wydajność

| Tabela | Kolumny | Typ Indeksu | Cel |
| :--- | :--- | :--- | :--- |
| `flashcards` | `(user_id, front)` | **UNIQUE INDEX** | Zapobiega duplikatom tej samej fiszki dla danego użytkownika oraz przyspiesza sprawdzanie istnienia. |
| `flashcards` | `user_id` | BTREE | Szybkie filtrowanie fiszek dla zalogowanego użytkownika. |
| `flashcards` | `generation_id` | BTREE | Szybkie pobieranie fiszek dla konkretnej sesji generowania (widok draftu). |
| `flashcards` | `front` | BTREE | Optymalizacja sortowania i wyszukiwania po przodzie fiszki. |
| `generations`| `user_id` | BTREE | Szybki dostęp do historii generacji użytkownika. |
| `generation_error_logs` | `created_at` | BTREE | Analiza błędów w czasie. |

---

## 4. Polityki Bezpieczeństwa (RLS)

Row Level Security (RLS) musi być włączone dla wszystkich tabel w schemacie `public`.

### Globalna zasada
Użytkownik ma dostęp wyłącznie do wierszy, gdzie `user_id` jest równe jego `auth.uid()`.

### Szczegółowe definicje polityk

1.  **`users`**:
    *   `SELECT`: Użytkownik widzi tylko swój profil (`auth.uid() = id`).
    *   `UPDATE`: Użytkownik może edytować tylko swój profil (`auth.uid() = id`).
    *   `INSERT`: Trigger po stronie Supabase Auth automatycznie tworzy wpis, ale aplikacja może potrzebować uprawnień insert w specyficznych przypadkach (zazwyczaj obsługiwane przez funkcję systemową).

2.  **`flashcards`**:
    *   `ALL (SELECT, INSERT, UPDATE, DELETE)`: Dozwolone, gdy `auth.uid() = user_id`.

3.  **`generations`**:
    *   `ALL (SELECT, INSERT, UPDATE, DELETE)`: Dozwolone, gdy `auth.uid() = user_id`.

4.  **`generation_error_logs`**:
    *   `INSERT`: Dozwolone dla `auth.uid() = user_id`.
    *   `SELECT`: Dozwolone dla `auth.uid() = user_id` (użytkownik widzi swoje błędy) lub tylko dla roli `service_role` (admin).

---

## 5. Uwagi do implementacji

1.  **Typy Enum vs Check Constraints:** Ze względu na łatwość zarządzania migracjami w Supabase/Postgres, zastosowano proste typy tekstowe z `CHECK CONSTRAINT` zamiast natywnych typów `ENUM` PostgreSQL. Ułatwia to późniejsze modyfikacje dopuszczalnych wartości bez konieczności usuwania typu.
2.  **Wyszukiwanie:** Zgodnie z decyzją projektową, wyszukiwanie będzie realizowane za pomocą operatora `ILIKE` na kolumnach `front` oraz `back_translation`. W przyszłości, przy większej skali, zalecana jest migracja na indeksy GIN i `tsvector`.
3.  **Obsługa Danych:** Kolumny liczbowe (`streak`, `daily_generations`) posiadają `DEFAULT 0` i `NOT NULL`, aby uprościć logikę inkrementacji w kodzie aplikacji.

