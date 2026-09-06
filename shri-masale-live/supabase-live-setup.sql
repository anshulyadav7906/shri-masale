-- SHRI MASALE - LIVE SECURITY + ORDER TRACKING SETUP
-- Run this AFTER the first database setup SQL.

-- Admins (authenticated users) can read and update orders.
create policy if not exists "Admins can view orders"
on public.orders
for select
to authenticated
using (true);

create policy if not exists "Admins can update orders"
on public.orders
for update
to authenticated
using (true)
with check (true);

-- Authenticated admins can view status history.
create policy if not exists "Admins can view order history"
on public.order_status_history
for select
to authenticated
using (true);

-- Public tracking RPC: exposes only tracking-safe fields, not phone/address/UTR.
create or replace function public.get_order_for_tracking(p_order_id text)
returns table (
  order_id text,
  quantity integer,
  product_name text,
  product_weight text,
  payment_status text,
  order_status text,
  created_at timestamptz
)
language sql
security definer
set search_path = public
as $$
  select
    o.order_id,
    o.quantity,
    o.product_name,
    o.product_weight,
    o.payment_status,
    o.order_status,
    o.created_at
  from public.orders o
  where upper(o.order_id) = upper(trim(p_order_id))
  limit 1;
$$;

revoke all on function public.get_order_for_tracking(text) from public;
grant execute on function public.get_order_for_tracking(text) to anon, authenticated;
