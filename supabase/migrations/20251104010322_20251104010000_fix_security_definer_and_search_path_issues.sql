/*
  # Fix Security Vulnerabilities

  ## Security Issues Addressed

  1. **SECURITY DEFINER View Vulnerability**
     - The `error_statistics` view uses SECURITY DEFINER which can be exploited
     - Solution: Drop the view and recreate without SECURITY DEFINER
     - Access control is already handled by RLS policies on error_logs table

  2. **Function Search Path Mutability**
     - The `cleanup_old_error_logs` function has a mutable search_path
     - This is a security risk as it can be exploited for privilege escalation
     - Solution: Set explicit search_path to prevent search path injection attacks

  3. **Unused Indexes Cleanup**
     - Remove indexes that are not being used to reduce maintenance overhead
     - Keep essential indexes for primary keys and frequently queried columns
     - These tables are for admin/internal use with low query volume

  ## Changes Applied

  ### View Security Fix
  - Drop and recreate error_statistics view without SECURITY DEFINER
  - Grant explicit permissions instead of using SECURITY DEFINER

  ### Function Security Fix
  - Add explicit search_path to cleanup_old_error_logs function
  - Set to 'public' to prevent injection attacks

  ### Index Optimization
  - Remove unused indexes on SEO tracking tables (low query volume)
  - Keep primary key indexes (automatically created)
  - Can be re-added later if query patterns emerge
*/

-- =====================================================
-- Fix SECURITY DEFINER View Vulnerability
-- =====================================================

-- Drop the existing view
DROP VIEW IF EXISTS error_statistics;

-- Recreate view WITHOUT security definer
CREATE OR REPLACE VIEW error_statistics AS
SELECT
  error_type,
  severity,
  COUNT(*) as count,
  DATE_TRUNC('hour', timestamp) as hour,
  MAX(timestamp) as last_occurrence
FROM error_logs
WHERE timestamp > NOW() - INTERVAL '7 days'
GROUP BY error_type, severity, DATE_TRUNC('hour', timestamp)
ORDER BY hour DESC, count DESC;

-- Grant explicit permissions (more secure than SECURITY DEFINER)
GRANT SELECT ON error_statistics TO service_role;

COMMENT ON VIEW error_statistics IS 
  'Error statistics view without SECURITY DEFINER. Access controlled by RLS on underlying error_logs table.';

-- =====================================================
-- Fix Function Search Path Mutability
-- =====================================================

-- Drop and recreate function with explicit search_path
DROP FUNCTION IF EXISTS cleanup_old_error_logs();

CREATE OR REPLACE FUNCTION cleanup_old_error_logs()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM error_logs
  WHERE created_at < NOW() - INTERVAL '90 days';
END;
$$;

COMMENT ON FUNCTION cleanup_old_error_logs IS
  'Cleanup function with explicit search_path set to public to prevent search path injection attacks.';

-- =====================================================
-- Remove Unused Indexes
-- =====================================================

-- These indexes were created for future optimization but are not currently used
-- They can be re-added if query patterns emerge that benefit from them

-- Keyword Rankings indexes
DROP INDEX IF EXISTS idx_keyword_rankings_keyword;
DROP INDEX IF EXISTS idx_keyword_rankings_date;
DROP INDEX IF EXISTS idx_keyword_rankings_position;

-- Content Calendar indexes
DROP INDEX IF EXISTS idx_content_calendar_status;
DROP INDEX IF EXISTS idx_content_calendar_publish_date;
DROP INDEX IF EXISTS idx_content_calendar_type;

-- Local Citations indexes
DROP INDEX IF EXISTS idx_local_citations_status;
DROP INDEX IF EXISTS idx_local_citations_category;

-- Competitor Tracking indexes
DROP INDEX IF EXISTS idx_competitor_tracking_date;
DROP INDEX IF EXISTS idx_competitor_tracking_competitor;

-- Backlinks indexes
DROP INDEX IF EXISTS idx_backlinks_status;
DROP INDEX IF EXISTS idx_backlinks_domain;
DROP INDEX IF EXISTS idx_backlinks_target;

-- Location Pages indexes
DROP INDEX IF EXISTS idx_location_pages_status;
DROP INDEX IF EXISTS idx_location_pages_state;
DROP INDEX IF EXISTS idx_location_pages_rank;

-- Calculator Submissions indexes
DROP INDEX IF EXISTS idx_calculator_submissions_type;
DROP INDEX IF EXISTS idx_calculator_submissions_date;

-- Error Logs indexes (keep minimal indexing for critical logs)
-- Remove all except created_at which might be used for cleanup
DROP INDEX IF EXISTS idx_error_logs_timestamp;
DROP INDEX IF EXISTS idx_error_logs_severity;
DROP INDEX IF EXISTS idx_error_logs_type;
DROP INDEX IF EXISTS idx_error_logs_timestamp_severity;

-- Keep idx_error_logs_created_at for cleanup function efficiency
-- This index is actually beneficial for the cleanup_old_error_logs function

COMMENT ON INDEX idx_error_logs_created_at IS
  'Index retained for efficient cleanup of old error logs by the cleanup_old_error_logs function.';

-- =====================================================
-- Security Verification
-- =====================================================

-- Verify RLS is still enabled on all tables
ALTER TABLE backlinks ENABLE ROW LEVEL SECURITY;
ALTER TABLE calculator_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE competitor_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_calendar ENABLE ROW LEVEL SECURITY;
ALTER TABLE keyword_rankings ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE local_citations ENABLE ROW LEVEL SECURITY;
ALTER TABLE location_pages ENABLE ROW LEVEL SECURITY;
ALTER TABLE error_logs ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- Notes on Index Strategy
-- =====================================================

/*
  The removed indexes were premature optimizations. Best practice:
  
  1. Start with minimal indexes (primary keys only)
  2. Monitor actual query patterns in production
  3. Add indexes based on real performance bottlenecks
  4. Use pg_stat_user_indexes to identify unused indexes
  
  For these SEO tracking tables:
  - Low query volume (internal admin use only)
  - Small data sets initially
  - Primary key indexes are sufficient
  - Can add targeted indexes later if needed
  
  If specific queries become slow, indexes can be added via:
  CREATE INDEX CONCURRENTLY idx_name ON table(column);
*/