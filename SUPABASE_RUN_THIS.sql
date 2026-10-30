
-- RUN ONCE in Supabase SQL Editor. Keeps existing players table.
create table if not exists public.level_scores (
  player_id uuid not null references auth.users(id) on delete cascade,
  level_index integer not null check (level_index >= 0 and level_index < 100000),
  best_score integer not null check (best_score >= 0 and best_score <= 10000),
  primary key (player_id, level_index)
);
alter table public.level_scores enable row level security;
-- No direct client writes to scores; only SECURITY DEFINER RPC.
revoke all on public.level_scores from anon, authenticated;
revoke update, delete on public.players from anon, authenticated;

create or replace function public.submit_level_score(p_level integer, p_score integer)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_old integer := 0;
  v_new bigint;
begin
  if v_uid is null then raise exception 'Authentication required'; end if;
  if p_level < 0 or p_level >= 100000 or p_score < 50 or p_score > 10000 then
    raise exception 'Invalid score';
  end if;
  -- Serialize concurrent updates for this player.
  perform 1 from public.players where id = v_uid for update;
  if not found then raise exception 'Player profile not found'; end if;
  select best_score into v_old from public.level_scores
    where player_id=v_uid and level_index=p_level;
  v_old := coalesce(v_old,0);
  if p_score > v_old then
    insert into public.level_scores(player_id,level_index,best_score)
      values(v_uid,p_level,p_score)
      on conflict(player_id,level_index)
      do update set best_score=excluded.best_score;
    update public.players
      set total_score=total_score+(p_score-v_old),updated_at=now()
      where id=v_uid returning total_score into v_new;
  else
    select total_score into v_new from public.players where id=v_uid;
  end if;
  return v_new;
end $$;
revoke all on function public.submit_level_score(integer,integer) from public;
grant execute on function public.submit_level_score(integer,integer) to authenticated;

-- Existing select/insert policies on public.players remain in place.
-- This limits writes but does NOT fully prevent modified clients forging scores.
