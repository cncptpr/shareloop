UPDATE items SET title=$1, description=$2, city=$3, postal_code=$4, location=st_setsrid(st_makepoint($5, $6), 4326)::geography WHERE id=$7 AND author_id=$8
returning id
