SELECT
  to_timestamp(sc.created) AT time zone 'America/New_York' AS timestamp_est,
  sc.currency,
  sc.amount,
  sc.amount::decimal / 100 AS charge_amount_in_dollars,
  sc.receipt_email,
  sc.customer_id,
  sc.description AS charge_description,
  sc.invoice_id,
  sc.id,
  sp.nickname
FROM stripe_charges AS sc
LEFT JOIN stripe_invoice_items AS sii ON sc.invoice_id = sii.invoice_id
LEFT JOIN stripe_prices AS sp ON sii.price_id = sp.id
WHERE sc.captured = false -- filter out uncaptured charges
ORDER BY timestamp_est DESC;
