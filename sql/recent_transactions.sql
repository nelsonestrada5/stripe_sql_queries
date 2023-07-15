SELECT 
    ch.id AS charge_id,
    -- Stripe times are 7 hours ahead of EST so substracting 7 hours
    -- Note, this is not a robust strategy, daylight savings will unsync times
    (to_timestamp(ch.created) - INTERVAL '7 hours') AS charge_date, 
    c.name AS customer_name,
    ch.amount::decimal / 100 AS charge_amount_in_dollars,
    ch.status AS charge_status,
    ch.description AS charge_description,
    sp.nickname
FROM 
    stripe_charges AS ch
    INNER JOIN stripe_customers AS c ON ch.customer_id = c.id
    LEFT JOIN stripe_invoice_items AS si ON c.id = si.customer_id
    LEFT JOIN stripe_prices AS sp ON si.price_id = sp.id
ORDER BY 
    charge_date DESC;
