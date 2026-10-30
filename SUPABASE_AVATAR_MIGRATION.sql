-- Run in Supabase SQL Editor. Existing names and scores are preserved.
begin;
alter table public.players add column if not exists avatar_id text not null default 'orange';
create or replace function public.set_player_avatar(p_avatar text, p_name text default null)
returns text language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if p_avatar is null or p_avatar not in ('orange','silver','black','white','siamese','clover','dreamer','calico') then
    raise exception 'Invalid avatar';
  end if;
  if p_name is not null and (char_length(trim(p_name)) < 2 or char_length(trim(p_name)) > 20) then
    raise exception 'Name must be 2-20 characters';
  end if;
  update public.players set avatar_id=p_avatar,player_name=coalesce(trim(p_name),player_name) where id=auth.uid();
  if not found then raise exception 'Player profile not found'; end if;
  return p_avatar;
end $$;
revoke all on function public.set_player_avatar(text,text) from public;
grant execute on function public.set_player_avatar(text,text) to authenticated;
commit;
-- Inspect player avatars alongside the results:
select player_name, avatar_id, total_score from public.players order by total_score desc;
