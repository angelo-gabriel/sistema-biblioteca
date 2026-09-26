SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: borrow_book_procedure(bigint, bigint, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.borrow_book_procedure(IN p_user_id bigint, IN p_book_id bigint, IN p_days_to_return integer DEFAULT 14)
    LANGUAGE plpgsql
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
      $$;


--
-- Name: calculate_late_fee(date, timestamp without time zone, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_late_fee(p_due_date date, p_returned_at timestamp without time zone, p_daily_rate numeric DEFAULT 2.50) RETURNS numeric
    LANGUAGE plpgsql
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
      $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: book_catalog_summaries; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.book_catalog_summaries AS
SELECT
    NULL::bigint AS book_id,
    NULL::character varying AS title,
    NULL::character varying AS author,
    NULL::character varying AS isbn,
    NULL::integer AS available_copies,
    NULL::integer AS total_copies,
    NULL::bigint AS total_borrows,
    NULL::text AS availability_status;


--
-- Name: books; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.books (
    id bigint NOT NULL,
    title character varying NOT NULL,
    author character varying NOT NULL,
    isbn character varying NOT NULL,
    total_copies integer DEFAULT 1 NOT NULL,
    available_copies integer DEFAULT 1 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: books_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.books_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.books_id_seq OWNED BY public.books.id;


--
-- Name: loans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.loans (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    book_id bigint NOT NULL,
    borrowed_at timestamp(6) without time zone,
    due_date date,
    returned_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: loans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.loans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: loans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.loans_id_seq OWNED BY public.loans.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying,
    email character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: books id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.books ALTER COLUMN id SET DEFAULT nextval('public.books_id_seq'::regclass);


--
-- Name: loans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loans ALTER COLUMN id SET DEFAULT nextval('public.loans_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: books books_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_pkey PRIMARY KEY (id);


--
-- Name: loans loans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loans
    ADD CONSTRAINT loans_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_books_on_isbn; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_books_on_isbn ON public.books USING btree (isbn);


--
-- Name: index_loans_on_book_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_loans_on_book_id ON public.loans USING btree (book_id);


--
-- Name: index_loans_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_loans_on_user_id ON public.loans USING btree (user_id);


--
-- Name: book_catalog_summaries _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.book_catalog_summaries AS
 SELECT b.id AS book_id,
    b.title,
    b.author,
    b.isbn,
    b.available_copies,
    b.total_copies,
    count(l.id) AS total_borrows,
        CASE
            WHEN (b.available_copies > 0) THEN 'Disponível'::text
            ELSE 'Esgotado'::text
        END AS availability_status
   FROM (public.books b
     LEFT JOIN public.loans l ON ((l.book_id = b.id)))
  GROUP BY b.id;


--
-- Name: loans fk_rails_0bae58a826; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loans
    ADD CONSTRAINT fk_rails_0bae58a826 FOREIGN KEY (book_id) REFERENCES public.books(id);


--
-- Name: loans fk_rails_c15c911198; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loans
    ADD CONSTRAINT fk_rails_c15c911198 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260924134559'),
('20260924134035'),
('20260924133622'),
('20260924133434'),
('20260924133425'),
('20260924133356');

