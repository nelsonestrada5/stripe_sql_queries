WITH charges_timezone_conversion AS (
  SELECT
    to_timestamp(created) AT time zone 'America/New_York' AS timestamp_est,
    currency,
    amount,
    id
  FROM stripe_charges
  WHERE captured -- filter out uncaptured charges
)

SELECT
  to_char(timestamp_est, 'YYYY-MM') as month,
  currency,
  round(sum(amount)/100.0, 2) AS gross_charges
FROM charges_timezone_conversion
WHERE timestamp_est >= current_timestamp AT time zone 'America/New_York' - interval '24 months'
GROUP BY 1, 2
ORDER BY 1 DESC, 2;
