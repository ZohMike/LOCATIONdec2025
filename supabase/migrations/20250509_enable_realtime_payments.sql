
-- Enable realtime for the paiements table
ALTER TABLE paiements REPLICA IDENTITY FULL;
ALTER PUBLICATION supabase_realtime ADD TABLE paiements;
