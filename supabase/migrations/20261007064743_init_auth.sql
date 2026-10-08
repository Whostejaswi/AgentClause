
declare
  claims jsonb;
  user_role text;
  user_org_id uuid;
begin
  select role, org_id into user_role, user_org_id
  from public.profiles
  where id = (event->>'user_id')::uuid;

  claims := event->'claims';
  claims := jsonb_set(claims, '{role}', to_jsonb(coalesce(user_role, 'startup_user')::text));

  if user_org_id is not null then
    claims := jsonb_set(claims, '{org_id}', to_jsonb(user_org_id::text));
  end if;

  event := jsonb_set(event, '{claims}', claims);
  return event;
end;


begin
  insert into public.profiles (id, role, full_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'role', 'startup_user'),
    new.raw_user_meta_data->>'full_name'
  );
  return new;
end;
