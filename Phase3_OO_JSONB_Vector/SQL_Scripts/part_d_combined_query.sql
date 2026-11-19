-- Part D: Combined vector + class hierarchy + JSONB query
-- Search prompt id 1 is 'family suv' in the searches table.
-- Returns the five closest matching SUVs that have both GPS and Bluetooth.

WITH customer_search AS (
    SELECT search, embedding
    FROM searches
    WHERE id = 1
)
SELECT
    veh.vehicle_id,
    veh.make,
    veh.model,
    veh.category,
    suv_type.seating_capacity,
    suv_type.four_wheel_drive,
    vv.description,
    1 - (vv.embedding <=> cs.embedding) AS similarity
FROM vehicle AS veh
JOIN suv AS suv_type
    ON suv_type.vehicle_id = veh.vehicle_id
JOIN vehicle_vectors AS vv
    ON vv.id = veh.vehicle_id
CROSS JOIN customer_search AS cs
WHERE veh.specifications @> '{"technology":{"gps":true,"bluetooth":true}}'::jsonb
ORDER BY vv.embedding <=> cs.embedding
LIMIT 5;
