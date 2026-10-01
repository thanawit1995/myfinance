-- =============================================================================
-- myfinance — Supabase Schema Setup (Full System Sync)
-- Run this entire script in Supabase SQL Editor
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- 1. TABLES
-- =============================================================================

-- Accounts
CREATE TABLE IF NOT EXISTS public.accounts (
  id                  TEXT PRIMARY KEY,
  user_id             UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name                TEXT NOT NULL,
  account_type        TEXT NOT NULL,
  currency_code       TEXT NOT NULL DEFAULT 'THB',
  is_domestic         BOOLEAN NOT NULL DEFAULT TRUE,
  closing_day         INTEGER,
  due_day             INTEGER,
  credit_limit_satang BIGINT,
  is_active           BOOLEAN NOT NULL DEFAULT TRUE,
  sync_version        INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at          TIMESTAMPTZ
);

-- Categories
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

-- Transactions
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

-- Budgets
CREATE TABLE IF NOT EXISTS public.budgets (
  id            TEXT PRIMARY KEY,
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id   TEXT NOT NULL,
  limit_satang  BIGINT NOT NULL,
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  sync_version  INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at    TIMESTAMPTZ
);

-- Assets (Investments)
CREATE TABLE IF NOT EXISTS public.assets (
  id                  TEXT PRIMARY KEY,
  user_id             UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  symbol              TEXT NOT NULL,
  name                TEXT NOT NULL,
  asset_type          TEXT NOT NULL,
  currency_code       TEXT NOT NULL DEFAULT 'THB',
  default_account_id  TEXT,
  market              TEXT,
  note                TEXT,
  extra_details_json  TEXT,
  sync_version        INTEGER NOT NULL DEFAULT 1,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at          TIMESTAMPTZ
);

-- Insurance Policies
CREATE TABLE IF NOT EXISTS public.insurance_policies (
  id                      TEXT PRIMARY KEY,
  user_id                 UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  policy_name             TEXT NOT NULL,
  insurance_type          TEXT NOT NULL,
  sum_insured_satang      BIGINT NOT NULL DEFAULT 0,
  medical_coverage_satang BIGINT NOT NULL DEFAULT 0,
  annual_premium_satang   BIGINT NOT NULL DEFAULT 0,
  due_date                TIMESTAMPTZ,
  total_periods           INTEGER NOT NULL DEFAULT 1,
  payment_due_day         INTEGER,
  payment_due_month       INTEGER,
  note                    TEXT,
  sync_version            INTEGER NOT NULL DEFAULT 1,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at              TIMESTAMPTZ
);

-- Liabilities (Debts)
CREATE TABLE IF NOT EXISTS public.liabilities (
  id                        TEXT PRIMARY KEY,
  user_id                   UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name                      TEXT NOT NULL,
  liability_type            TEXT NOT NULL,
  remaining_principal_satang BIGINT NOT NULL DEFAULT 0,
  monthly_payment_satang    BIGINT NOT NULL DEFAULT 0,
  interest_rate_percent     TEXT,
  is_short_term             BOOLEAN NOT NULL DEFAULT FALSE,
  linked_account_id         TEXT,
  note                      TEXT,
  sync_version              INTEGER NOT NULL DEFAULT 1,
  created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at                TIMESTAMPTZ
);

-- Recurring Rules
CREATE TABLE IF NOT EXISTS public.recurring_rules (
  id                      TEXT PRIMARY KEY,
  user_id                 UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title                   TEXT NOT NULL,
  transaction_type        TEXT NOT NULL,
  source_account_id       TEXT NOT NULL,
  destination_account_id  TEXT,
  category_id             TEXT,
  amount_satang           BIGINT NOT NULL DEFAULT 0,
  currency_code           TEXT NOT NULL DEFAULT 'THB',
  frequency               TEXT NOT NULL,
  day_of_month            INTEGER,
  next_run_date           TIMESTAMPTZ NOT NULL,
  end_date                TIMESTAMPTZ,
  is_active               BOOLEAN NOT NULL DEFAULT TRUE,
  interval_units          INTEGER NOT NULL DEFAULT 1,
  auto_post               BOOLEAN NOT NULL DEFAULT TRUE,
  last_posted_date        TIMESTAMPTZ,
  note                    TEXT,
  sync_version            INTEGER NOT NULL DEFAULT 1,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at              TIMESTAMPTZ
);

-- Device State & Conflict Tracking
CREATE TABLE IF NOT EXISTS public.sync_device_state (
  user_id             UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  active_device_id    TEXT NOT NULL,
  active_device_name  TEXT NOT NULL,
  total_transactions  INTEGER NOT NULL DEFAULT 0,
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- 2. INDEXES
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_tx_user_updated   ON public.transactions(user_id, updated_at);
CREATE INDEX IF NOT EXISTS idx_acc_user_updated  ON public.accounts(user_id, updated_at);
CREATE INDEX IF NOT EXISTS idx_cat_user_updated  ON public.categories(user_id, updated_at);
CREATE INDEX IF NOT EXISTS idx_bdg_user_updated  ON public.budgets(user_id, updated_at);
CREATE INDEX IF NOT EXISTS idx_ast_user_updated  ON public.assets(user_id, updated_at);
CREATE INDEX IF NOT EXISTS idx_ins_user_updated  ON public.insurance_policies(user_id, updated_at);
CREATE INDEX IF NOT EXISTS idx_lia_user_updated  ON public.liabilities(user_id, updated_at);
CREATE INDEX IF NOT EXISTS idx_rec_user_updated  ON public.recurring_rules(user_id, updated_at);

-- =============================================================================
-- 3. ROW LEVEL SECURITY (RLS)
-- =============================================================================

ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.insurance_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.liabilities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recurring_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_device_state ENABLE ROW LEVEL SECURITY;

-- Helper to safely re-create policies
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN SELECT unnest(ARRAY[
    'accounts', 'categories', 'transactions', 'budgets',
    'assets', 'insurance_policies', 'liabilities', 'recurring_rules', 'sync_device_state'
  ]) LOOP
    EXECUTE format('DROP POLICY IF EXISTS "Users can view own %I" ON public.%I', tbl, tbl);
    EXECUTE format('DROP POLICY IF EXISTS "Users can insert own %I" ON public.%I', tbl, tbl);
    EXECUTE format('DROP POLICY IF EXISTS "Users can update own %I" ON public.%I', tbl, tbl);
    EXECUTE format('DROP POLICY IF EXISTS "Users can delete own %I" ON public.%I', tbl, tbl);

    EXECUTE format('CREATE POLICY "Users can view own %I" ON public.%I FOR SELECT USING (auth.uid() = user_id)', tbl, tbl);
    EXECUTE format('CREATE POLICY "Users can insert own %I" ON public.%I FOR INSERT WITH CHECK (auth.uid() = user_id)', tbl, tbl);
    EXECUTE format('CREATE POLICY "Users can update own %I" ON public.%I FOR UPDATE USING (auth.uid() = user_id)', tbl, tbl);
    EXECUTE format('CREATE POLICY "Users can delete own %I" ON public.%I FOR DELETE USING (auth.uid() = user_id)', tbl, tbl);
  END LOOP;
END $$;
