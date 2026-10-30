-- New compact leaderboard. Historical scores remain intact in their old table.
begin;
alter table public.players add column if not exists total_score_v2 bigint not null default 0;
create table if not exists public.level_scores_v2 (
 player_id uuid not null references auth.users(id) on delete cascade,
 level_index integer not null check(level_index>=0 and level_index<100000),
 best_score integer not null check(best_score between 20 and 50),
 primary key(player_id,level_index)
);
alter table public.level_scores_v2 enable row level security;
revoke all on public.level_scores_v2 from anon,authenticated;
-- Keep score columns protected; profiles are updated through their existing RPC.
revoke update on public.players from anon,authenticated;
create or replace function public.submit_level_score_v2(p_level integer,p_score integer)
returns bigint language plpgsql security definer set search_path='' as $$
declare v_uid uuid:=auth.uid();v_old integer:=0;v_total bigint;
begin
 if v_uid is null then raise exception 'Authentication required';end if;
 if p_level is null or p_score is null or p_level<0 or p_level>=100000 or p_score<20 or p_score>50 then raise exception 'Invalid score';end if;
 perform 1 from public.players where id=v_uid for update;
 if not found then raise exception 'Player profile not found';end if;
 select best_score into v_old from public.level_scores_v2 where player_id=v_uid and level_index=p_level;
 v_old:=coalesce(v_old,0);
 if p_score>v_old then
  insert into public.level_scores_v2(player_id,level_index,best_score) values(v_uid,p_level,p_score)
  on conflict(player_id,level_index) do update set best_score=excluded.best_score;
  update public.players set total_score_v2=total_score_v2+(p_score-v_old) where id=v_uid returning total_score_v2 into v_total;
 else select total_score_v2 into v_total from public.players where id=v_uid;
 end if;
 return v_total;
end $$;
revoke all on function public.submit_level_score_v2(integer,integer) from public;
grant execute on function public.submit_level_score_v2(integer,integer) to authenticated;
commit;
select player_name,total_score_v2 from public.players order by total_score_v2 desc;
