create table if not exists public.races (
	code text primary key check (code ~ '^[A-Z]{4}$'),
	status smallint not null default 0 check (status in (-1, 0, 1)),
	map text not null,
	created_at timestamptz not null default now(),
	host_id uuid not null references auth.users(id)
);

alter table public.races enable row level security;

grant select, insert, update on public.races to authenticated;

drop policy if exists "Signed-in users can read races" on public.races;
create policy "Signed-in users can read races"
	on public.races for select to authenticated
	using (true);

drop policy if exists "Signed-in users can create their races" on public.races;
create policy "Signed-in users can create their races"
	on public.races for insert to authenticated
	with check (host_id = auth.uid());

drop policy if exists "Hosts can update their races or replace expired races" on public.races;
create policy "Hosts can update their races or replace expired races"
	on public.races for update to authenticated
	using (host_id = auth.uid() or created_at < now() - interval '24 hours')
	with check (host_id = auth.uid());