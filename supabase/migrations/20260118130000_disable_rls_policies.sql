-- =====================================================
-- migration: disable rls policies for flashcards, generations, and generation_error_logs
-- description: drops all rls policies from flashcards, generations, and generation_error_logs tables
-- tables affected: flashcards, generations, generation_error_logs
-- notes: 
--   - rls remains enabled on tables, only policies are dropped
--   - this effectively blocks all access unless new policies are added
-- =====================================================

-- =====================================================
-- 1. drop all policies from generations table
-- =====================================================
drop policy if exists "generations_select_own_authenticated" on public.generations;
drop policy if exists "generations_select_own_anon" on public.generations;
drop policy if exists "generations_insert_own_authenticated" on public.generations;
drop policy if exists "generations_insert_own_anon" on public.generations;
drop policy if exists "generations_update_own_authenticated" on public.generations;
drop policy if exists "generations_update_own_anon" on public.generations;
drop policy if exists "generations_delete_own_authenticated" on public.generations;
drop policy if exists "generations_delete_own_anon" on public.generations;

-- =====================================================
-- 2. drop all policies from flashcards table
-- =====================================================
drop policy if exists "flashcards_select_own_authenticated" on public.flashcards;
drop policy if exists "flashcards_select_own_anon" on public.flashcards;
drop policy if exists "flashcards_insert_own_authenticated" on public.flashcards;
drop policy if exists "flashcards_insert_own_anon" on public.flashcards;
drop policy if exists "flashcards_update_own_authenticated" on public.flashcards;
drop policy if exists "flashcards_update_own_anon" on public.flashcards;
drop policy if exists "flashcards_delete_own_authenticated" on public.flashcards;
drop policy if exists "flashcards_delete_own_anon" on public.flashcards;

-- =====================================================
-- 3. drop all policies from generation_error_logs table
-- =====================================================
drop policy if exists "generation_error_logs_select_own_authenticated" on public.generation_error_logs;
drop policy if exists "generation_error_logs_select_own_anon" on public.generation_error_logs;
drop policy if exists "generation_error_logs_insert_own_authenticated" on public.generation_error_logs;
drop policy if exists "generation_error_logs_insert_own_anon" on public.generation_error_logs;
drop policy if exists "generation_error_logs_update_own_authenticated" on public.generation_error_logs;
drop policy if exists "generation_error_logs_update_own_anon" on public.generation_error_logs;
drop policy if exists "generation_error_logs_delete_own_authenticated" on public.generation_error_logs;
drop policy if exists "generation_error_logs_delete_own_anon" on public.generation_error_logs;

