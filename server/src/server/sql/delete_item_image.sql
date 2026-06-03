DELETE FROM item_images WHERE id=$1 AND item_id=$2
returning original_name
