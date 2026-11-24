-- ============================================================================
-- AsaWicara: Skema Database PostgreSQL, Row Level Security (RLS), & Storage
-- Arsitektur: Full Supabase (1 Caregiver : N Pasien, 1 Perangkat Bergantian)
-- Jalankan seluruh skrip ini di Supabase Dashboard -> SQL Editor -> New Query
-- ============================================================================

create extension if not exists "pgcrypto";

-- ----------------------------------------------------------------------------
-- 1. TABEL CAREGIVERS (Terhubung 1:1 dengan auth.users)
-- ----------------------------------------------------------------------------
create table if not exists public.caregivers (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  email text not null,
  phone text,
  is_profile_completed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 2. TABEL PATIENTS (Multi-Pasien per Caregiver)
-- ----------------------------------------------------------------------------
create table if not exists public.patients (
  id uuid primary key default gen_random_uuid(),
  caregiver_id uuid not null references public.caregivers(id) on delete cascade,
  full_name text not null,
  nickname text not null,
  birth_date date,
  gender text check (gender in ('L', 'P')),
  relationship text not null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_patients_caregiver_id
  on public.patients(caregiver_id);

-- ----------------------------------------------------------------------------
-- 3. TABEL EXERCISE_SESSIONS (Ringkasan 1 Sesi Latihan AIUEO)
-- ----------------------------------------------------------------------------
create table if not exists public.exercise_sessions (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients(id) on delete cascade,
  caregiver_id uuid not null references public.caregivers(id) on delete cascade,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  duration_seconds integer not null default 0 check (duration_seconds >= 0),
  status text not null default 'in_progress'
    check (status in ('in_progress', 'completed', 'interrupted')),
  completed_vowels_count integer not null default 0
    check (completed_vowels_count between 0 and 5),
  created_at timestamptz not null default now()
);

create index if not exists idx_sessions_patient_started
  on public.exercise_sessions(patient_id, started_at desc);

-- ----------------------------------------------------------------------------
-- 4. TABEL EXERCISE_RECORDS (Rekaman Per Huruf Vokal A, I, U, E, O)
-- ----------------------------------------------------------------------------
create table if not exists public.exercise_records (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.exercise_sessions(id) on delete cascade,
  patient_id uuid not null references public.patients(id) on delete cascade,
  caregiver_id uuid not null references public.caregivers(id) on delete cascade,
  vowel text not null check (vowel in ('A', 'I', 'U', 'E', 'O')),
  audio_path text not null,
  duration_seconds integer not null default 0 check (duration_seconds >= 0),
  recorded_at timestamptz not null default now(),
  unique (session_id, vowel)
);

create index if not exists idx_records_session_id
  on public.exercise_records(session_id);

-- ----------------------------------------------------------------------------
-- 5. TRIGGER OTOMATIS: updated_at & PROFIL AWAL CAREGIVER SAAT REGISTER
-- ----------------------------------------------------------------------------
create or replace function public.handle_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_caregivers_updated_at on public.caregivers;
create trigger set_caregivers_updated_at
  before update on public.caregivers
  for each row execute function public.handle_updated_at();

drop trigger if exists set_patients_updated_at on public.patients;
create trigger set_patients_updated_at
  before update on public.patients
  for each row execute function public.handle_updated_at();

-- Membuat baris caregiver otomatis ketika akun baru terdaftar di Supabase Auth
create or replace function public.handle_new_caregiver()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.caregivers (id, email, full_name, is_profile_completed)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    false
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_caregiver();

-- ----------------------------------------------------------------------------
-- 6. ROW LEVEL SECURITY (RLS) UNTUK SEMUA TABEL
-- ----------------------------------------------------------------------------
alter table public.caregivers enable row level security;
alter table public.patients enable row level security;
alter table public.exercise_sessions enable row level security;
alter table public.exercise_records enable row level security;

-- Policy: caregivers
create policy "caregivers_select_own"
  on public.caregivers for select
  using (auth.uid() = id);

create policy "caregivers_insert_own"
  on public.caregivers for insert
  with check (auth.uid() = id);

create policy "caregivers_update_own"
  on public.caregivers for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Policy: patients
create policy "patients_all_own"
  on public.patients for all
  using (auth.uid() = caregiver_id)
  with check (auth.uid() = caregiver_id);

-- Policy: exercise_sessions
create policy "sessions_all_own"
  on public.exercise_sessions for all
  using (auth.uid() = caregiver_id)
  with check (auth.uid() = caregiver_id);

-- Policy: exercise_records
create policy "records_all_own"
  on public.exercise_records for all
  using (auth.uid() = caregiver_id)
  with check (auth.uid() = caregiver_id);

-- ----------------------------------------------------------------------------
-- 7. PRIVATE STORAGE BUCKET & STORAGE RLS POLICY
-- Format path wajib: {caregiver_id}/{patient_id}/{session_id}/{vowel}.m4a
-- ----------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'exercise-audio',
  'exercise-audio',
  false,
  15728640, -- Maksimal 15 MB per file rekaman
  array['audio/mp4', 'audio/m4a', 'audio/x-m4a', 'audio/aac', 'audio/mpeg']
)
on conflict (id) do nothing;

create policy "audio_select_own"
  on storage.objects for select
  using (
    bucket_id = 'exercise-audio'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "audio_insert_own"
  on storage.objects for insert
  with check (
    bucket_id = 'exercise-audio'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "audio_update_own"
  on storage.objects for update
  using (
    bucket_id = 'exercise-audio'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "audio_delete_own"
  on storage.objects for delete
  using (
    bucket_id = 'exercise-audio'
    and (storage.foldername(name))[1] = auth.uid()::text
  );