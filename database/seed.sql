-- Optional development seed data.
-- No login user is created here because password_hash must be generated with bcrypt.
INSERT INTO farm (farm_name, location, contact_phone)
VALUES ('Demo Farm', 'Eldoret, Kenya', NULL)
ON CONFLICT DO NOTHING;
