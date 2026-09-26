class CreateCalculateLateFeeFunction < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION calculate_late_fee(
        p_due_date DATE,
        p_returned_at TIMESTAMP,
        p_daily_rate NUMERIC DEFAULT 2.50
      )
      RETURNS NUMERIC
      AS $$
      DECLARE
        v_effective_return DATE;
        v_days_overdue INTEGER;
      BEGIN
        -- calcula em relação à data atual
        v_effective_return := COALESCE(p_returned_at::date, CURRENT_DATE);

        v_days_overdue := v_effective_return - p_due_date;

        IF v_days_overdue > 0 THEN
          RETURN ROUND(v_days_overdue * p_daily_rate, 2);
        ELSE
          RETURN 0.00;
        END IF;
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end

  def down
    execute "DROP FUNCTION IF EXISTS calculate_late_fee(DATE, TIMESTAMP, NUMERIC);"
  end
end
