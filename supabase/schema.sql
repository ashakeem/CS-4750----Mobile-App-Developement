-- Create table for storing user swipe actions
create table public.swipes (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  gift jsonb not null,
  action text check (action in ('like', 'pass')) not null,
  created_at timestamp with time zone default now()
);

-- Set up Row Level Security (RLS)
alter table public.swipes enable row level security;

-- Create RLS policy: users can only access their own swipes
create policy "Users can view own swipes" 
  on public.swipes for select 
  using (auth.uid() = user_id);

create policy "Users can insert own swipes" 
  on public.swipes for insert 
  with check (auth.uid() = user_id);

create policy "Users can update own swipes" 
  on public.swipes for update 
  using (auth.uid() = user_id);

create policy "Users can delete own swipes" 
  on public.swipes for delete 
  using (auth.uid() = user_id);

-- Create index for faster queries
create index swipes_user_id_idx on public.swipes (user_id);
create index swipes_action_idx on public.swipes (action);
create index swipes_created_at_idx on public.swipes (created_at desc); 