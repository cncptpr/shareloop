select
  items.id,
  items.title,
  items.description,
  profiles.name as author_name,
  items.author_id,
  items.score,
  items.city,
  items.postal_code,
  items.category,
  first_img.id as first_image_uuid
from items, profiles
left join lateral (
  select id
  from item_images
  where item_images.item_id = items.id
  order by sort_order, created_at
  limit 1
) as first_img on true
where items.author_id = profiles.id
order by score desc