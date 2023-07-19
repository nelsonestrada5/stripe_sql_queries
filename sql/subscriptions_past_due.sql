SELECT
  stripe_subscriptions.status AS subscription_status,
  stripe_subscriptions.id AS subscription_id,
  stripe_customers.name AS customer_name,
  stripe_customers.email AS customer_email,
  stripe_invoices.attempt_count AS attempt_count,
  TO_TIMESTAMP(stripe_invoices.next_payment_attempt) AS next_payment_attempt,
  stripe_invoices.amount_paid::decimal / 100 AS amount_paid,
  stripe_invoices.amount_due::decimal / 100 AS amount_due,
  stripe_invoices.amount_due::decimal / 100 AS amount_remaining,
  stripe_subscriptions.metadata->>'kjb_offer_id' AS kjb_offer_id,
  TO_TIMESTAMP(stripe_subscriptions.created) AS created,
  TO_TIMESTAMP(stripe_subscriptions.start_date) AS start_date,
  TO_TIMESTAMP(stripe_subscriptions.current_period_start) AS current_period_start,
  TO_TIMESTAMP(stripe_subscriptions.current_period_end) AS current_period_end,
  --stripe_subscriptions.latest_invoice_id AS latest_invoice_id,
  stripe_invoices.status AS invoice_status
FROM
  stripe_subscriptions
INNER JOIN stripe_customers
  ON stripe_customers.id = stripe_subscriptions.customer_id
LEFT JOIN stripe_invoices
  ON stripe_invoices.subscription_id = stripe_subscriptions.id
WHERE
  -- Subscription Status Types
  --    active   - the subscription is in good standing.
  --    past_due - the most recent invoice failed or hasn’t been attempted
  --    canceled - the subscription has been canceled.
  --    unpaid   - alternative to canceled and leaves invoices open, 
  --               but doesn’t attempt to pay them until a new payment method is added.
  stripe_subscriptions.status = 'past_due'
ORDER BY 
  current_period_end ASC;
