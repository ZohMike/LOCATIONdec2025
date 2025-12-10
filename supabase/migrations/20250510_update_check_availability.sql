
-- Updated equipment availability function to use the junction table and handle no reservations case
CREATE OR REPLACE FUNCTION public.check_equipment_availability(
  equipment_id uuid, 
  start_date date, 
  end_date date, 
  exclude_reservation_id uuid DEFAULT NULL
) RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
  is_available BOOLEAN;
  reservation_count INTEGER;
BEGIN
  -- Check if there are any overlapping reservations for this equipment
  -- using the junction table for reservation-equipment relationships
  SELECT COUNT(*) INTO reservation_count
  FROM reservation_materiels rm
  JOIN reservations r ON rm.reservation_id = r.id
  WHERE 
    rm.materiel_id = equipment_id
    -- Exclude the current reservation if we're updating
    AND (exclude_reservation_id IS NULL OR r.id != exclude_reservation_id)
    -- Check for date overlap
    AND (
      (r.date_debut <= end_date AND r.date_fin >= start_date)
    )
    -- Don't count cancelled reservations
    AND NOT (r.remarques LIKE '%[Statut: cancelled]%');

  -- If there are no overlapping reservations, the equipment is available
  is_available := (reservation_count = 0);
  RETURN is_available;
END;
$$;

