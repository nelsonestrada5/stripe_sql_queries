SELECT
  to_timestamp(charges.created) AT time zone 'America/New_York' AS timestamp_est,
  charges.currency,
  charges.amount,
  charges.amount::decimal / 100 AS charge_amount_in_dollars,
  charges.receipt_email,
  charges.customer_id,
  charges.description AS charge_description,
  charges.invoice_id,
  charges.id,
  prices.nickname
FROM stripe_charges AS charges
LEFT JOIN stripe_invoice_items AS invoice_items ON charges.invoice_id = invoice_items.invoice_id
LEFT JOIN stripe_prices AS prices ON invoice_items.price_id = prices.id
WHERE charges.captured = false -- filter out uncaptured charges
ORDER BY timestamp_est DESC;
