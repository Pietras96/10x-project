-- =====================================================
-- migration: create initial schema for 10x-cards
-- description: creates users, generations, flashcards, and generation_error_logs tables
-- tables affected: users, generations, flashcards, generation_error_logs
-- notes: 
--   - all tables have rls enabled
--   - users table extends auth.users with 1:1 relationship
--   - supermemo-2 columns intentionally omitted for future migration
-- =====================================================

-- =====================================================
-- 1. create users table (extends auth.users)
-- =====================================================
-- this table stores user profile data and gamification state
-- it has a 1:1 relationship with supabase auth.users table
create table public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  english_level text check (english_level in ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  daily_generations integer not null default 0,
  last_generation_date date default current_date,
  streak integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- enable row level security
alter table public.users enable row level security;

-- create rls policies for users table
-- authenticated users can view their own profile
create policy "users_select_own_authenticated"
  on public.users
  for select
  to authenticated
  using (auth.uid() = id);

-- anonymous users cannot view profiles
create policy "users_select_own_anon"
  on public.users
  for select
  to anon
  using (false);

-- authenticated users can update their own profile
create policy "users_update_own_authenticated"
  on public.users
  for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- anonymous users cannot update profiles
create policy "users_update_own_anon"
  on public.users
  for update
  to anon
  using (false);

-- insert is typically handled by trigger on auth.users
-- but we allow authenticated users to insert their own profile
create policy "users_insert_own_authenticated"
  on public.users
  for insert
  to authenticated
  with check (auth.uid() = id);

-- anonymous users cannot insert profiles
create policy "users_insert_own_anon"
  on public.users
  for insert
  to anon
  with check (false);

-- authenticated users can delete their own profile
create policy "users_delete_own_authenticated"
  on public.users
  for delete
  to authenticated
  using (auth.uid() = id);

-- anonymous users cannot delete profiles
create policy "users_delete_own_anon"
  on public.users
  for delete
  to anon
  using (false);

-- add index on id for faster lookups (primary key already creates this, but explicit for clarity)
comment on table public.users is 'user profile data extending auth.users with gamification state';

-- =====================================================
-- 2. create generations table
-- =====================================================
-- stores source texts submitted to ai for flashcard generation
create table public.generations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  source_text varchar(10000) not null,
  created_at timestamptz not null default now()
);

-- enable row level security
alter table public.generations enable row level security;

-- create index on user_id for fast history retrieval
create index generations_user_id_idx on public.generations(user_id);

-- create rls policies for generations table
-- authenticated users can view their own generations
create policy "generations_select_own_authenticated"
  on public.generations
  for select
  to authenticated
  using (auth.uid() = user_id);

-- anonymous users cannot view generations
create policy "generations_select_own_anon"
  on public.generations
  for select
  to anon
  using (false);

-- authenticated users can insert their own generations
create policy "generations_insert_own_authenticated"
  on public.generations
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- anonymous users cannot insert generations
create policy "generations_insert_own_anon"
  on public.generations
  for insert
  to anon
  with check (false);

-- authenticated users can update their own generations
create policy "generations_update_own_authenticated"
  on public.generations
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- anonymous users cannot update generations
create policy "generations_update_own_anon"
  on public.generations
  for update
  to anon
  using (false);

-- authenticated users can delete their own generations
create policy "generations_delete_own_authenticated"
  on public.generations
  for delete
  to authenticated
  using (auth.uid() = user_id);

-- anonymous users cannot delete generations
create policy "generations_delete_own_anon"
  on public.generations
  for delete
  to anon
  using (false);

comment on table public.generations is 'source texts submitted for ai flashcard generation';

-- =====================================================
-- 3. create flashcards table
-- =====================================================
-- main table storing flashcards (both drafts and approved)
-- note: supermemo-2 columns (interval, repetition_count, ease_factor) 
-- intentionally omitted for future migration per design decision
create table public.flashcards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  generation_id uuid references public.generations(id) on delete set null,
  front varchar(200) not null,
  back_translation varchar(500) not null,
  back_definition varchar(500),
  back_example varchar(500),
  is_draft boolean not null default true,
  source varchar(20) not null default 'ai-full' check (source in ('ai-full', 'ai-edited', 'manual')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- enable row level security
alter table public.flashcards enable row level security;

-- create unique index to prevent duplicate flashcards per user
-- also speeds up existence checks
create unique index flashcards_user_id_front_unique_idx 
  on public.flashcards(user_id, front);

-- create index on user_id for fast user filtering
create index flashcards_user_id_idx on public.flashcards(user_id);

-- create index on generation_id for fast draft view retrieval
create index flashcards_generation_id_idx on public.flashcards(generation_id);

-- create index on front for sorting and searching optimization
create index flashcards_front_idx on public.flashcards(front);

-- create rls policies for flashcards table
-- authenticated users can view their own flashcards
create policy "flashcards_select_own_authenticated"
  on public.flashcards
  for select
  to authenticated
  using (auth.uid() = user_id);

-- anonymous users cannot view flashcards
create policy "flashcards_select_own_anon"
  on public.flashcards
  for select
  to anon
  using (false);

-- authenticated users can insert their own flashcards
create policy "flashcards_insert_own_authenticated"
  on public.flashcards
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- anonymous users cannot insert flashcards
create policy "flashcards_insert_own_anon"
  on public.flashcards
  for insert
  to anon
  with check (false);

-- authenticated users can update their own flashcards
create policy "flashcards_update_own_authenticated"
  on public.flashcards
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- anonymous users cannot update flashcards
create policy "flashcards_update_own_anon"
  on public.flashcards
  for update
  to anon
  using (false);

-- authenticated users can delete their own flashcards
create policy "flashcards_delete_own_authenticated"
  on public.flashcards
  for delete
  to authenticated
  using (auth.uid() = user_id);

-- anonymous users cannot delete flashcards
create policy "flashcards_delete_own_anon"
  on public.flashcards
  for delete
  to anon
  using (false);

comment on table public.flashcards is 'main flashcard storage for both drafts and approved cards';

-- =====================================================
-- 4. create generation_error_logs table
-- =====================================================
-- technical table for monitoring ai integration errors
create table public.generation_error_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  error_code varchar(50),
  error_message text not null,
  created_at timestamptz not null default now()
);

-- enable row level security
alter table public.generation_error_logs enable row level security;

-- create index on created_at for time-based error analysis
create index generation_error_logs_created_at_idx 
  on public.generation_error_logs(created_at);

-- create rls policies for generation_error_logs table
-- authenticated users can view their own error logs
create policy "generation_error_logs_select_own_authenticated"
  on public.generation_error_logs
  for select
  to authenticated
  using (auth.uid() = user_id);

-- anonymous users cannot view error logs
create policy "generation_error_logs_select_own_anon"
  on public.generation_error_logs
  for select
  to anon
  using (false);

-- authenticated users can insert their own error logs
create policy "generation_error_logs_insert_own_authenticated"
  on public.generation_error_logs
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- anonymous users cannot insert error logs
create policy "generation_error_logs_insert_own_anon"
  on public.generation_error_logs
  for insert
  to anon
  with check (false);

-- authenticated users can update their own error logs (unlikely use case)
create policy "generation_error_logs_update_own_authenticated"
  on public.generation_error_logs
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- anonymous users cannot update error logs
create policy "generation_error_logs_update_own_anon"
  on public.generation_error_logs
  for update
  to anon
  using (false);

-- authenticated users can delete their own error logs
create policy "generation_error_logs_delete_own_authenticated"
  on public.generation_error_logs
  for delete
  to authenticated
  using (auth.uid() = user_id);

-- anonymous users cannot delete error logs
create policy "generation_error_logs_delete_own_anon"
  on public.generation_error_logs
  for delete
  to anon
  using (false);

comment on table public.generation_error_logs is 'technical log for monitoring ai integration errors';

-- =====================================================
-- 5. create triggers for updated_at columns
-- =====================================================
-- function to automatically update updated_at timestamp
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- attach trigger to users table
create trigger update_users_updated_at
  before update on public.users
  for each row
  execute function update_updated_at_column();

-- attach trigger to flashcards table
create trigger update_flashcards_updated_at
  before update on public.flashcards
  for each row
  execute function update_updated_at_column();

-- =====================================================
-- 6. create function to handle new user creation
-- =====================================================
-- automatically create user profile when auth.users record is created
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into public.users (id)
  values (new.id);
  return new;
end;
$$ language plpgsql security definer;

-- trigger on auth.users to automatically create profile
create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function handle_new_user();

comment on function handle_new_user() is 'automatically creates user profile in public.users when auth user is created';

