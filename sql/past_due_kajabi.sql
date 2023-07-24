--
-- Vender Sin Vender
-- AED Offers [WIP]
-- Estas son las personas que nos deben dinero
-- 
-- 
SELECT
  TO_TIMESTAMP(stripe_payment_intents.created) AS payment_intent_date,
  stripe_subscriptions.metadata->>'kjb_offer_id' AS kjb_offer_id,
  stripe_customers.name AS customer_name,
  stripe_customers.email AS customer_email,
  stripe_invoices.amount_due::decimal / 100 AS invoice_amount_due,
  stripe_invoices.amount_paid::decimal / 100 AS invoice_amount_paid,  
  stripe_invoices.amount_remaining::decimal / 100 AS invoice_amount_remaining,
  stripe_invoices.number AS invoice_number,
  stripe_subscriptions.latest_invoice_id AS latest_invoice_id,
  stripe_subscriptions.customer_id AS customer_id,
  stripe_payment_intents.id AS payment_intent_id,
  stripe_invoices.attempt_count AS invoice_attempt_count,
  stripe_subscriptions.id AS subscription_id,
  CONCAT('https://dashboard.stripe.com/subscriptions/', stripe_subscriptions.id) AS subscription_link,
  stripe_subscriptions.status AS subscription_status,
  stripe_invoices.status AS invoice_status
FROM
  stripe_subscriptions
INNER JOIN stripe_customers
  ON stripe_customers.id = stripe_subscriptions.customer_id
LEFT JOIN stripe_invoices
  ON stripe_invoices.subscription_id = stripe_subscriptions.id
LEFT JOIN stripe_payment_intents
  ON stripe_invoices.payment_intent_id = stripe_payment_intents.id
WHERE
  -- Subscription Status Types
  --    active   - the subscription is in good standing.
  --    past_due - the most recent invoice failed or hasn’t been attempted
  --    canceled - the subscription has been canceled.
  --    unpaid   - alternative to canceled and leaves invoices open, 
  --               but doesn’t attempt to pay them until a new payment method is added.
  stripe_subscriptions.status = 'past_due'
  AND (stripe_subscriptions.metadata->>'kjb_offer_id' = '2148878239'
  OR stripe_subscriptions.metadata->>'kjb_offer_id' = '2148878215'
  OR stripe_subscriptions.metadata->>'kjb_offer_id' = '2148878173'
  OR stripe_subscriptions.metadata->>'kjb_offer_id' = '2148878203'
  OR stripe_subscriptions.metadata->>'kjb_offer_id' = '2148889673')
  -- Invoice Status States (https://stripe.com/docs/billing/migration/invoice-states)
  --    draft - invoice is modifiable
  --    open  - invoice is ready for payment, cannot be modified
  --    paid  - invoice has been paid in full
  --    void  - invoice is no longer valid
  --    uncollectible - unlikely to be paid, could be considered bad debt
  -- AND (stripe_invoices.status != 'draft' AND stripe_invoices.status != 'open')
  AND stripe_invoices.amount_remaining > 0
ORDER BY 
  TO_TIMESTAMP(stripe_payment_intents.created) DESC;
