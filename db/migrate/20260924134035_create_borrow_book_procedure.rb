class CreateBorrowBookProcedure < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL
      CREATE OR REPLACE PROCEDURE borrow_book_procedure(
        p_user_id BIGINT,
        p_book_id BIGINT,
        p_days_to_return INTEGER DEFAULT 14
      )
      AS $$
      DECLARE
        v_available INTEGER;
      BEGIN
        SELECT available_copies INTO v_available
        FROM books
        WHERE id = p_book_id
        FOR UPDATE;

        IF NOT FOUND THEN
          RAISE EXCEPTION 'Livo de ID % não encontrado.', p_book_id;
        END IF;

        IF v_available <= 0 THEN
          RAISE EXCEPTION 'Não há exemplares disponíveis.';
        END IF;

        -- decrementa o estoque
        UPDATE books
        SET available_copies = available_copies - 1,
          updated_at = NOW()
        WHERE id = p_book_id;

        -- registra o empréstime
        INSERT INTO loans (user_id, book_id, borrowed_at, due_date, created_at, updated_at)
        VALUES (
          p_user_id,
          p_book_id,
          NOW(),
          CURRENT_DATE + p_days_to_return,
          NOW(),
          NOW()
        );
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end

  def down
    execute "DROP PROCEDURE IF EXISTS borrow_book_procedure(BIGINT, BIGINT, INTEGER);"
  end
end
