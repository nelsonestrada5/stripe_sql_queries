--
-- Recent Refunds
-- Sanity check: https://dashboard.stripe.com/balance?type=refund
--
SELECT
  TO_TIMESTAMP(stripe_balance_transactions.created) AS date,
  stripe_balance_transactions.amount::decimal / 100 AS refund_amount_in_dollars,
  stripe_balance_transactions.currency,
  stripe_balance_transactions.description,
  stripe_balance_transactions.source_id,
  stripe_refunds.charge_id
FROM
  stripe_balance_transactions
INNER JOIN stripe_refunds -- Joining these tables to retrieve additional information
  ON stripe_balance_transactions.source_id = stripe_refunds.id
WHERE stripe_balance_transactions.type = 'refund'
ORDER BY date DESC
LIMIT 30;
