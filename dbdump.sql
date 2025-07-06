--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: annullacondivisionetodo(character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.annullacondivisionetodo(IN utente character varying, IN idtodocondiviso integer)
    LANGUAGE plpgsql
    AS $$
            BEGIN
            DELETE FROM placement
            WHERE  idbacheca IN (SELECT "ID" FROM bacheca WHERE "Owner" LIKE utente) AND idtodo = idtodocondiviso;
            END; 
            $$;


ALTER PROCEDURE public.annullacondivisionetodo(IN utente character varying, IN idtodocondiviso integer) OWNER TO postgres;

--
-- Name: changedeafultbacheca(integer, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.changedeafultbacheca(IN idnewdefault integer, IN proprietario character varying)
    LANGUAGE plpgsql
    AS $$
            BEGIN
            UPDATE bacheca
            SET isdefault = false
            WHERE bacheca."Owner" LIKE proprietario AND isdefault = true;

            UPDATE bacheca
            set isdefault = true
            WHERE bacheca."ID" = idnewdefault;

            END;
            $$;


ALTER PROCEDURE public.changedeafultbacheca(IN idnewdefault integer, IN proprietario character varying) OWNER TO postgres;

--
-- Name: checkallexpireddates(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.checkallexpireddates()
    LANGUAGE plpgsql
    AS $$
            DECLARE
            tem record;
            BEGIN
            FOR tem IN (SELECT * FROM todo)
            LOOP
            UPDATE todo 
            SET completed = tem.completed
            WHERE "ID"= tem."ID";
            END LOOP;
            END;
            $$;


ALTER PROCEDURE public.checkallexpireddates() OWNER TO postgres;

--
-- Name: checkexpirationfunction(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.checkexpirationfunction() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
            IF new.complete_by_date < current_date AND new.completed = false THEN
            new.expired := true;
            ELSE
            new.expired := false;
            END IF;
            RETURN NEW;
            END;
            $$;


ALTER FUNCTION public.checkexpirationfunction() OWNER TO postgres;

--
-- Name: completebefore(character varying, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.completebefore(utente character varying, treshold date) RETURNS TABLE("ID" integer, title character varying, url character varying, description character varying, "Owner" character varying, icon integer, color integer, complete_by_date date, completed boolean, expired boolean)
    LANGUAGE sql
    AS $$
            SELECT todo."ID", todo.title, todo.url, todo.description, todo."Owner", todo.icon, todo.color, todo.complete_by_date, todo.completed, todo.expired
            FROM placement JOIN todo ON placement.idtodo = todo."ID" JOIN bacheca ON bacheca."ID" = placement.idbacheca
            WHERE bacheca."Owner" = utente AND todo.complete_By_Date <= treshold;
            $$;


ALTER FUNCTION public.completebefore(utente character varying, treshold date) OWNER TO postgres;

--
-- Name: condividitodo(character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.condividitodo(IN utente character varying, IN idtodocondiviso integer)
    LANGUAGE plpgsql
    AS $$
            DECLARE
            destination int;
            BEGIN

            SELECT "ID" INTO destination
            FROM bacheca
            WHERE "Owner" LIKE utente AND isdefault = true;

            INSERT INTO placement (idbacheca, idtodo) values
            (destination, idtodocondiviso);

            END; 
            $$;


ALTER PROCEDURE public.condividitodo(IN utente character varying, IN idtodocondiviso integer) OWNER TO postgres;

--
-- Name: controllobachechemaxfunction(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.controllobachechemaxfunction() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
num_bacheche int;
max_bacheche int;
BEGIN

SELECT count(*) into num_bacheche
FROM bacheca JOIN "user" on bacheca."Owner" LIKE "user".username
WHERE bacheca."Owner" LIKE new."Owner";

SELECT num_max_bacheche into max_bacheche
FROM "user"
WHERE username LIKE new."Owner";

IF num_bacheche >= max_bacheche THEN
RAISE EXCEPTION 'you have reached the maximum number of allowed bacheche, contact customer support for additional space';
RETURN null;
ELSE
RETURN new;
END IF;
END;
$$;


ALTER FUNCTION public.controllobachechemaxfunction() OWNER TO postgres;

--
-- Name: createdefaultbachechefunction(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.createdefaultbachechefunction() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

            BEGIN
            INSERT INTO bacheca (title, description, "Owner", Format, isDefault)
            values 
            ('Default', 'your default bacheca', new.username, 'Default', true),
            ('Università', 'your university bacheca', new.username, 'Università', false),
            ('Lavoro', 'your job bacheca', new.username, 'Lavoro', false),
            ('Tempo libero', 'your free time bacheca', new.username, 'Tempo libero', false);
            RETURN NULL;
            END;
            $$;


ALTER FUNCTION public.createdefaultbachechefunction() OWNER TO postgres;

--
-- Name: movetodo(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.movetodo(IN todotomove integer, IN origin integer, IN destination integer)
    LANGUAGE plpgsql
    AS $$
            BEGIN
            UPDATE placement
            SET idbacheca = destination
            WHERE idtodo = todotomove AND idbacheca = origin;
            END;
            $$;


ALTER PROCEDURE public.movetodo(IN todotomove integer, IN origin integer, IN destination integer) OWNER TO postgres;

--
-- Name: removetodofunction(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.removetodofunction() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

            DECLARE
            temporaneo1 varchar(100);
            temporaneo2 varchar(100);

            BEGIN
            Select "Owner" into temporaneo1
            From bacheca
            where bacheca."ID" = OLD.IDBacheca;

            Select "Owner" into temporaneo2
            From todo 
            Where todo."ID" = OLD.IDToDo;

            IF temporaneo1 LIKE temporaneo2 THEN
            Delete from todo where todo."ID" = OLD.IDToDo;
            END IF;
            RETURN OLD;
            END;
            $$;


ALTER FUNCTION public.removetodofunction() OWNER TO postgres;

--
-- Name: searchtodo(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.searchtodo(utente character varying, testo character varying) RETURNS integer[]
    LANGUAGE plpgsql
    AS $$

            DECLARE
            ret integer ARRAY;
            tem int;

            BEGIN
            FOR tem in 
            SELECT todo."ID" 
            FROM Todo JOIN placement ON Todo."ID" = placement.idtodo JOIN bacheca ON bacheca."ID" = placement.idbacheca
            WHERE bacheca."Owner" LIKE utente AND lower(Todo.title) LIKE lower('%'||testo||'%')

            LOOP
            ret := array_append(ret, tem);
            END LOOP;
            RETURN ret;
            END;
            $$;


ALTER FUNCTION public.searchtodo(utente character varying, testo character varying) OWNER TO postgres;

--
-- Name: selectcompleted(character varying, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.selectcompleted(utente character varying, status boolean) RETURNS TABLE("ID" integer, title character varying, url character varying, description character varying, "Owner" character varying, icon integer, color integer, complete_by_date date, completed boolean, expired boolean)
    LANGUAGE sql
    AS $$
            SELECT todo."ID", todo.title, todo.url, todo.description, todo."Owner", todo.icon, todo.color, todo.complete_by_date, todo.completed, todo.expired
            FROM placement JOIN todo ON placement.idtodo = todo."ID" JOIN bacheca ON placement.idbacheca = bacheca."ID"
            WHERE bacheca."Owner" = utente AND todo.completed = status;
            $$;


ALTER FUNCTION public.selectcompleted(utente character varying, status boolean) OWNER TO postgres;

--
-- Name: selectexpired(character varying, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.selectexpired(utente character varying, status boolean) RETURNS TABLE("ID" integer, title character varying, url character varying, description character varying, "Owner" character varying, icon integer, color integer, complete_by_date date, completed boolean, expired boolean)
    LANGUAGE sql
    AS $$
            SELECT todo."ID", todo.title, todo.url, todo.description, todo."Owner", todo.icon, todo.color, todo.complete_by_date, todo.completed, todo.expired
            FROM placement JOIN todo ON placement.idtodo = todo."ID" JOIN bacheca ON placement.idbacheca = bacheca."ID"
            WHERE bacheca."Owner" = utente AND todo.expired = status;
            $$;


ALTER FUNCTION public.selectexpired(utente character varying, status boolean) OWNER TO postgres;

--
-- Name: sortalphabetical(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sortalphabetical(bachecatosort integer) RETURNS TABLE("ID" integer, title character varying, url character varying, description character varying, "Owner" character varying, icon integer, color integer, complete_by_date date, completed boolean, expired boolean)
    LANGUAGE sql
    AS $$
            SELECT todo."ID", todo.title, todo.url, todo.description, todo."Owner", todo.icon, todo.color, todo.complete_by_date, todo.completed, todo.expired
            FROM placement JOIN todo ON placement.idtodo = todo."ID"
            WHERE placement.idbacheca = bachecaToSort
            ORDER BY todo.title ASC;
            $$;


ALTER FUNCTION public.sortalphabetical(bachecatosort integer) OWNER TO postgres;

--
-- Name: sortbydate(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sortbydate(bachecatosort integer) RETURNS TABLE("ID" integer, title character varying, url character varying, description character varying, "Owner" character varying, icon integer, color integer, complete_by_date date, completed boolean, expired boolean)
    LANGUAGE sql
    AS $$
            SELECT todo."ID", todo.title, todo.url, todo.description, todo."Owner", todo.icon, todo.color, todo.complete_by_date, todo.completed, todo.expired
            FROM placement JOIN todo ON placement.idtodo = todo."ID"
            WHERE placement.idbacheca = bachecaToSort
            ORDER BY todo.complete_by_date ASC;
            $$;


ALTER FUNCTION public.sortbydate(bachecatosort integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bacheca; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bacheca (
    "ID" integer NOT NULL,
    title character varying(100),
    description character varying(1000),
    "Owner" character varying(100),
    format character varying(12) DEFAULT 'Default'::character varying,
    isdefault boolean DEFAULT false
);


ALTER TABLE public.bacheca OWNER TO postgres;

--
-- Name: bacheca_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.bacheca ALTER COLUMN "ID" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."bacheca_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: max_bacheche; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.max_bacheche (
    num_max_bacheche integer
);


ALTER TABLE public.max_bacheche OWNER TO postgres;

--
-- Name: placement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.placement (
    idbacheca integer NOT NULL,
    idtodo integer NOT NULL
);


ALTER TABLE public.placement OWNER TO postgres;

--
-- Name: todo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.todo (
    "ID" integer NOT NULL,
    title character varying(100),
    url character varying(256),
    description character varying(1000),
    "Owner" character varying(100),
    icon integer DEFAULT 0,
    color integer DEFAULT 0,
    complete_by_date date,
    completed boolean DEFAULT false,
    expired boolean DEFAULT false
);


ALTER TABLE public.todo OWNER TO postgres;

--
-- Name: todo_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.todo ALTER COLUMN "ID" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."todo_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    username character varying(100) NOT NULL,
    "Password" character varying(100) NOT NULL,
    num_max_bacheche integer DEFAULT 10
);


ALTER TABLE public."user" OWNER TO postgres;

--
-- Data for Name: bacheca; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bacheca ("ID", title, description, "Owner", format, isdefault) FROM stdin;
\.


--
-- Data for Name: max_bacheche; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.max_bacheche (num_max_bacheche) FROM stdin;
\.


--
-- Data for Name: placement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.placement (idbacheca, idtodo) FROM stdin;
\.


--
-- Data for Name: todo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.todo ("ID", title, url, description, "Owner", icon, color, complete_by_date, completed, expired) FROM stdin;
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."user" (username, "Password", num_max_bacheche) FROM stdin;
\.


--
-- Name: bacheca_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."bacheca_ID_seq"', 59, true);


--
-- Name: todo_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."todo_ID_seq"', 24, true);


--
-- Name: bacheca bacheca_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacheca
    ADD CONSTRAINT bacheca_pkey PRIMARY KEY ("ID");


--
-- Name: placement placement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.placement
    ADD CONSTRAINT placement_pkey PRIMARY KEY (idbacheca, idtodo);


--
-- Name: todo todo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.todo
    ADD CONSTRAINT todo_pkey PRIMARY KEY ("ID");


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (username);


--
-- Name: todo checkexpiration; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER checkexpiration BEFORE INSERT OR UPDATE ON public.todo FOR EACH ROW EXECUTE FUNCTION public.checkexpirationfunction();


--
-- Name: bacheca controllobachechemax; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER controllobachechemax BEFORE INSERT ON public.bacheca FOR EACH ROW EXECUTE FUNCTION public.controllobachechemaxfunction();


--
-- Name: user createdefaultbacheche; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER createdefaultbacheche AFTER INSERT ON public."user" FOR EACH ROW EXECUTE FUNCTION public.createdefaultbachechefunction();


--
-- Name: placement removetodo; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER removetodo AFTER DELETE ON public.placement FOR EACH ROW EXECUTE FUNCTION public.removetodofunction();


--
-- Name: bacheca bacheca_Owner_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacheca
    ADD CONSTRAINT "bacheca_Owner_fkey" FOREIGN KEY ("Owner") REFERENCES public."user"(username) ON DELETE CASCADE;


--
-- Name: placement placement_idbacheca_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.placement
    ADD CONSTRAINT placement_idbacheca_fkey FOREIGN KEY (idbacheca) REFERENCES public.bacheca("ID") ON DELETE CASCADE;


--
-- Name: placement placement_idtodo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.placement
    ADD CONSTRAINT placement_idtodo_fkey FOREIGN KEY (idtodo) REFERENCES public.todo("ID") ON DELETE CASCADE;


--
-- Name: todo todo_Owner_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.todo
    ADD CONSTRAINT "todo_Owner_fkey" FOREIGN KEY ("Owner") REFERENCES public."user"(username) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

