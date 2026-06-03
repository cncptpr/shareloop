UPDATE item_images SET sort_order=$3 WHERE id=$1 AND item_id=$2
returning id
