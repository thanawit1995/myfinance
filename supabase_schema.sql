-- =============================================================================
-- myfinance — Supabase Schema Setup
-- Run this entire script in Supabase SQL Editor (once)
-- =============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- TABLES (mirror SQLite schema + user_id for RLS)
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.accounts (
  id                TEXT PRIMARY KEY,
  user_id           UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name              TEXT NOT NULL,
  account_type      TEXT NOT NULL,
  currency_code     TEXT NOT NULL DEFAULT 'THB',
  is_domestic       BOOLEAN NOT NULL DEFAULT TRUE,
  closing_day       INTEGER,
  due_day           INTEGER,
  credit_limit_satang BIGINT,
  is_active         BOOLEAN NOT NULL DEFAULT TRUE,
  sync_version      INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at        TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.categories (
  id              TEXT PRIMARY KEY,
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name_th         TEXT NOT NULL DEFAULT '',
  name_en         TEXT NOT NULL DEFAULT '',
  category_type   TEXT NOT NULL,
  parent_id       TEXT,
  tax_income_type TEXT,
  icon            TEXT,
  color           TEXT,
  is_system       BOOLEAN NOT NULL DEFAULT FALSE,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order      INTEGER NOT NULL DEFAULT 0,
  sync_version    INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.transactions (
  id                      TEXT PRIMARY KEY,
  user_id                 UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  transaction_type        TEXT NOT NULL,
  source_account_id       TEXT,
  destination_account_id  TEXT,
  category_id             TEXT,
  asset_id                TEXT,
  import_batch_id         TEXT,
  amount_original_satang  BIGINT NOT NULL DEFAULT 0,
  currency_code           TEXT NOT NULL DEFAULT 'THB',
  fx_rate                 TEXT DEFAULT '1.000000',
  amount_thb_satang       BIGINT NOT NULL DEFAULT 0,
  fee_thb_satang          BIGINT NOT NULL DEFAULT 0,
  tag                     TEXT,
  tax_category            TEXT,
  withholding_tax_satang  BIGINT NOT NULL DEFAULT 0,
  transaction_date        TIMESTAMPTZ NOT NULL,
  work_period             TEXT,
  expected_amount_satang  BIGINT,
  note                    TEXT,
  is_cleared              BOOLEAN NOT NULL DEFAULT TRUE,
  sync_version            INTEGER NOT NULL DEFAULT 1,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at              TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.budgets (
  id            TEXT PRIMARY KEY,
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id   TEXT NOT NULL,
  limit_satang  BIGINT NOT NULL,
  period        TEXT NOT NULL DEFAULT 'monthly',
  sync_version  INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at    TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.insurance_policies (
  id                      TEXT PRIMARY KEY,
  user_id                 UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  policy_name             TEXT NOT NULL,
  insurance_type          TEXT NOT NULL,
  company                 TEXT,
  policy_number           TEXT,
  start_date              DATE,
  end_date                DATE,
  due_date                DATE,
  annual_premium_satang   BIGINT NOT NULL DEFAULT 0,
  sum_insured_satang      BIGINT NOT NULL DEFAULT 0,
  medical_coverage_satang BIGINT NOT NULL DEFAULT 0,
  total_periods           INTEGER,
  note                    TEXT,
  sync_version            INTEGER NOT NULL DEFAULT 1,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at              TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.liabilities (
  id                TEXT PRIMARY KEY,
  user_id           UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name              TEXT NOT NULL,
  liability_type    TEXT NOT NULL,
  principal_satang  BIGINT NOT NULL DEFAULT 0,
  interest_rate     TEXT,
  monthly_payment_satang BIGINT NOT NULL DEFAULT 0,
  start_date        DATE,
  end_date          DATE,
  note              TEXT,
  sync_version      INTEGER NOT NULL DEFAULT 1,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at        TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.assets (
  id            TEXT PRIMARY KEY,
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  symbol        TEXT NOT NULL,
  name          TEXT NOT NULL,
  asset_type    TEXT NOT NULL,
  currency_code TEXT NOT NULL DEFAULT 'THB',
  note          TEXT,
  sync_version  INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at    TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.recurring_rules (
  id              TEXT PRIMARY KEY,
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  account_id      TEXT,
  category_id     TEXT,
  transaction_type TEXT NOT NULL,
  amount_satang   BIGINT NOT NULL DEFAULT 0,
  frequency       TEXT NOT NULL,
  next_due_date   DATE,
  note            TEXT,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  sync_version    INTEGER NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ
);

-- =============================================================================
-- INDEXES (performance for sync queries)
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_transactions_user_updated ON public.transactions(user_id, updated_at);
CREATE INDEX IF NOT EXISTS idx_accounts_user_updated     ON public.accounts(user_id, updated_at);
CREATE INDEX IF NOT EXISTS idx_categories_user_updated   ON public.categories(user_id, updated_at);
CREATE INDEX IF NOT EXISTS idx_budgets_user_updated      ON public.budgets(user_id, updated_at);

-- =============================================================================
-- ROW LEVEL SECURITY (users can only see their own data)
-- =============================================================================

ALTER TABLE public.accounts          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.budgets           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.insurance_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.liabilities       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assets            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recurring_rules   ENABLE ROW LEVEL SECURITY;

-- Policies: each user sees only their own rows
-- (DROP first to allow re-running this script safely)
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOREACH tbl IN ARRAY ARRAY[
    'accounts','categories','transactions','budgets',
    'insurance_policies','liabilities','assets','recurring_rules'
  ] LOOP
    EXECUTE format('DROP POLICY IF EXISTS "user_owns_%1$s" ON public.%1$s;', tbl);
    EXECUTE format('
      CREATE POLICY "user_owns_%1$s"
      ON public.%1$s
      FOR ALL
      TO authenticated
      USING (user_id = auth.uid())
      WITH CHECK (user_id = auth.uid());
    ', tbl);
  END LOOP;
END $$;

-- =============================================================================
-- REALTIME (enable for high-frequency tables)
-- =============================================================================

ALTER PUBLICATION supabase_realtime ADD TABLE public.transactions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.accounts;

-- =============================================================================
-- DONE — copy the output URL to your Flutter app config
-- Project URL: https://dohnjjzypsvqdsjkqwli.supabase.co
-- =============================================================================
