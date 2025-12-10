
-- Function to get invoice settings
CREATE OR REPLACE FUNCTION public.get_invoice_settings()
RETURNS TABLE (
  id INTEGER,
  company_name TEXT,
  email TEXT,
  phone TEXT,
  address TEXT,
  currency TEXT,
  logo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
) 
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT * FROM public.invoice_settings WHERE id = 1;
$$;

-- Function to update invoice settings
CREATE OR REPLACE FUNCTION public.update_invoice_settings(
  p_company_name TEXT,
  p_email TEXT,
  p_phone TEXT,
  p_address TEXT,
  p_currency TEXT,
  p_logo_url TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.invoice_settings (
    id, company_name, email, phone, address, currency, logo_url, updated_at
  ) VALUES (
    1, p_company_name, p_email, p_phone, p_address, p_currency, p_logo_url, NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    company_name = p_company_name,
    email = p_email,
    phone = p_phone,
    address = p_address,
    currency = p_currency,
    logo_url = p_logo_url,
    updated_at = NOW();
END;
$$;
