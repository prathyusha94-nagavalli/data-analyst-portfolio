-- Goal: Analyze Annual Wellness Visit (AWV) campaign effectiveness across years
-- Key Metrics: AWV completion rate, outreach response rate, report delivery status to PCPs

WITH eligible_members AS (
    SELECT 
        m.member_id,
        m.plan_year,
        m.age,
        m.risk_tier,
        m.region,
        m.primary_care_provider_id
    FROM members m
    WHERE m.plan_year IN (2022, 2023)
      AND m.eligibility_status = 'Active'
      AND m.age BETWEEN 50 AND 85
),
awv_claims AS (
    SELECT 
        c.member_id,
        c.claim_id,
        c.service_date,
        c.plan_year,
        ROW_NUMBER() OVER (PARTITION BY c.member_id, c.plan_year ORDER BY c.service_date) AS awv_rank
    FROM claims c
    WHERE c.procedure_code IN ('G0438', 'G0439')  -- AWV codes
),
outreach_activity AS (
    SELECT 
        o.member_id,
        o.outreach_date,
        o.channel,
        o.plan_year,
        DENSE_RANK() OVER (PARTITION BY o.member_id ORDER BY o.outreach_date) AS outreach_round
    FROM outreach_log o
    WHERE o.outreach_type = 'AWV Reminder'
),
provider_reports AS (
    SELECT 
        p.member_id,
        p.delivery_date,
        p.plan_year,
        p.status AS report_status
    FROM awv_summary_reports p
    WHERE p.status IN ('Delivered', 'Failed')
)

SELECT 
    em.plan_year,
    em.region,
    em.risk_tier,
    COUNT(DISTINCT em.member_id) AS eligible_members,
    COUNT(DISTINCT ac.member_id) AS members_completed_awv,
    ROUND(COUNT(DISTINCT ac.member_id) * 100.0 / COUNT(DISTINCT em.member_id), 2) AS awv_completion_rate_pct,
    COUNT(DISTINCT oa.member_id) AS members_reached_out,
    ROUND(COUNT(DISTINCT oa.member_id) * 100.0 / COUNT(DISTINCT em.member_id), 2) AS outreach_coverage_pct,
    COUNT(DISTINCT pr.member_id) AS reports_delivered_to_providers,
    ROUND(COUNT(DISTINCT pr.member_id) * 100.0 / COUNT(DISTINCT ac.member_id), 2) AS report_delivery_pct
FROM eligible_members em
LEFT JOIN awv_claims ac
    ON em.member_id = ac.member_id AND em.plan_year = ac.plan_year AND ac.awv_rank = 1
LEFT JOIN outreach_activity oa
    ON em.member_id = oa.member_id AND em.plan_year = oa.plan_year AND oa.outreach_round = 1
LEFT JOIN provider_reports pr
    ON em.member_id = pr.member_id AND em.plan_year = pr.plan_year AND pr.report_status = 'Delivered'
GROUP BY em.plan_year, em.region, em.risk_tier
ORDER BY em.plan_year DESC, em.region, em.risk_tier;
