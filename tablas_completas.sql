--
-- PostgreSQL database dump
--

\restrict tCX03aInrsOVWjpuOBqzIdYcxJMLyl2zYflZnyo8uZQr7YWQhysdBejLDnpOHgk

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agenda; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agenda (
    id integer NOT NULL,
    usuario_id character varying(255) NOT NULL,
    otro_usuario character varying(255),
    producto_nombre character varying(255),
    ultimo_mensaje text,
    producto_imagen character varying(255),
    conversacion_id integer,
    fecha_guardado timestamp without time zone DEFAULT now(),
    producto_id integer,
    vendedor_id character varying(255),
    producto_precio character varying(50),
    producto_categoria character varying(100),
    productos_lista text
);


ALTER TABLE public.agenda OWNER TO postgres;

--
-- Name: agenda_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.agenda_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.agenda_id_seq OWNER TO postgres;

--
-- Name: agenda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.agenda_id_seq OWNED BY public.agenda.id;


--
-- Name: alertas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alertas (
    id integer NOT NULL,
    usuario_id text NOT NULL,
    producto_id integer,
    mensaje text NOT NULL,
    tipo text DEFAULT 'info'::text,
    leida boolean DEFAULT false,
    fecha timestamp without time zone DEFAULT now(),
    imagen_url character varying(255) DEFAULT ''::character varying
);


ALTER TABLE public.alertas OWNER TO postgres;

--
-- Name: alertas_caducidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alertas_caducidad (
    id integer NOT NULL,
    producto_id integer NOT NULL,
    usuario_id character varying(255) NOT NULL,
    aviso_dado boolean DEFAULT true,
    fecha_aviso timestamp without time zone DEFAULT now()
);


ALTER TABLE public.alertas_caducidad OWNER TO postgres;

--
-- Name: alertas_caducidad_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.alertas_caducidad_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.alertas_caducidad_id_seq OWNER TO postgres;

--
-- Name: alertas_caducidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.alertas_caducidad_id_seq OWNED BY public.alertas_caducidad.id;


--
-- Name: alertas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.alertas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.alertas_id_seq OWNER TO postgres;

--
-- Name: alertas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.alertas_id_seq OWNED BY public.alertas.id;


--
-- Name: bloqueos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bloqueos (
    id integer NOT NULL,
    usuario_bloquea character varying(255) NOT NULL,
    usuario_bloqueado character varying(255) NOT NULL,
    fecha timestamp without time zone DEFAULT now()
);


ALTER TABLE public.bloqueos OWNER TO postgres;

--
-- Name: bloqueos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bloqueos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bloqueos_id_seq OWNER TO postgres;

--
-- Name: bloqueos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bloqueos_id_seq OWNED BY public.bloqueos.id;


--
-- Name: busquedas_app; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.busquedas_app (
    id integer NOT NULL,
    usuario_id character varying(255) NOT NULL,
    termino character varying(255) NOT NULL,
    fecha timestamp without time zone DEFAULT now()
);


ALTER TABLE public.busquedas_app OWNER TO postgres;

--
-- Name: busquedas_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.busquedas_app_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.busquedas_app_id_seq OWNER TO postgres;

--
-- Name: busquedas_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.busquedas_app_id_seq OWNED BY public.busquedas_app.id;


--
-- Name: calificaciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calificaciones (
    id integer NOT NULL,
    usuario_id character varying(255) NOT NULL,
    calificador_id character varying(255) NOT NULL,
    producto_id integer NOT NULL,
    puntuacion integer NOT NULL,
    comentario text,
    fecha timestamp without time zone DEFAULT now(),
    CONSTRAINT chk_puntuacion CHECK (((puntuacion >= 1) AND (puntuacion <= 5)))
);


ALTER TABLE public.calificaciones OWNER TO postgres;

--
-- Name: calificaciones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.calificaciones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.calificaciones_id_seq OWNER TO postgres;

--
-- Name: calificaciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.calificaciones_id_seq OWNED BY public.calificaciones.id;


--
-- Name: conversaciones_app; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conversaciones_app (
    id integer NOT NULL,
    usuario1_id character varying(255) NOT NULL,
    usuario2_id character varying(255) NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT now(),
    producto_nombre text,
    producto_imagen text,
    producto_id integer,
    vendedor_id character varying(255),
    estado character varying(20) DEFAULT 'activa'::character varying
);


ALTER TABLE public.conversaciones_app OWNER TO postgres;

--
-- Name: conversaciones_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.conversaciones_app_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.conversaciones_app_id_seq OWNER TO postgres;

--
-- Name: conversaciones_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.conversaciones_app_id_seq OWNED BY public.conversaciones_app.id;


--
-- Name: denuncias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.denuncias (
    id integer NOT NULL,
    denunciante_id text NOT NULL,
    denunciado_id text NOT NULL,
    producto_id integer NOT NULL,
    motivo text,
    fecha timestamp without time zone DEFAULT now(),
    estado text DEFAULT 'pendiente'::text
);


ALTER TABLE public.denuncias OWNER TO postgres;

--
-- Name: denuncias_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.denuncias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.denuncias_id_seq OWNER TO postgres;

--
-- Name: denuncias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.denuncias_id_seq OWNED BY public.denuncias.id;


--
-- Name: mensajes_app; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mensajes_app (
    id integer NOT NULL,
    conversacion_id integer,
    usuario_id character varying(255) NOT NULL,
    texto text,
    imagen text,
    fecha timestamp without time zone DEFAULT now()
);


ALTER TABLE public.mensajes_app OWNER TO postgres;

--
-- Name: mensajes_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mensajes_app_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mensajes_app_id_seq OWNER TO postgres;

--
-- Name: mensajes_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mensajes_app_id_seq OWNED BY public.mensajes_app.id;


--
-- Name: productos_app; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productos_app (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    categoria character varying(50) NOT NULL,
    precio numeric(10,2) NOT NULL,
    imagen_url text,
    descripcion text,
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    estado character varying(20) DEFAULT 'activo'::character varying,
    subcategoria character varying(100),
    vendedor_id text,
    direccion text,
    vendedor_nombre text,
    provincia text,
    imagenes_reales text,
    imagen_destacada text,
    estado_moderacion text DEFAULT 'pendiente'::text,
    motivo_rechazo text,
    likes integer DEFAULT 0,
    vistas integer DEFAULT 0,
    estado_ia_destacada text DEFAULT 'pendiente'::text,
    motivo_rechazo_destacada text,
    destacada_publicada boolean DEFAULT false,
    fecha_expiracion timestamp without time zone,
    imagen_miniatura character varying(255)
);


ALTER TABLE public.productos_app OWNER TO postgres;

--
-- Name: productos_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.productos_app_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.productos_app_id_seq OWNER TO postgres;

--
-- Name: productos_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.productos_app_id_seq OWNED BY public.productos_app.id;


--
-- Name: productos_favoritos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productos_favoritos (
    id integer NOT NULL,
    usuario_id character varying(255) NOT NULL,
    producto_id character varying(255) NOT NULL,
    fecha timestamp without time zone DEFAULT now()
);


ALTER TABLE public.productos_favoritos OWNER TO postgres;

--
-- Name: productos_favoritos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.productos_favoritos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.productos_favoritos_id_seq OWNER TO postgres;

--
-- Name: productos_favoritos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.productos_favoritos_id_seq OWNED BY public.productos_favoritos.id;


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    uid character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    nombre character varying(255),
    foto_perfil text,
    telefono character varying(20),
    fecha_registro timestamp without time zone DEFAULT now(),
    acepta_recoleccion boolean DEFAULT false
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- Name: vistas_producto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vistas_producto (
    id integer NOT NULL,
    producto_id integer NOT NULL,
    usuario_id character varying(255),
    ip character varying(50),
    fecha timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vistas_producto OWNER TO postgres;

--
-- Name: vistas_producto_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vistas_producto_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vistas_producto_id_seq OWNER TO postgres;

--
-- Name: vistas_producto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vistas_producto_id_seq OWNED BY public.vistas_producto.id;


--
-- Name: vistas_resumen_diario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vistas_resumen_diario (
    id integer NOT NULL,
    producto_id integer NOT NULL,
    fecha date NOT NULL,
    total_vistas integer DEFAULT 0
);


ALTER TABLE public.vistas_resumen_diario OWNER TO postgres;

--
-- Name: vistas_resumen_diario_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vistas_resumen_diario_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vistas_resumen_diario_id_seq OWNER TO postgres;

--
-- Name: vistas_resumen_diario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vistas_resumen_diario_id_seq OWNED BY public.vistas_resumen_diario.id;


--
-- Name: agenda id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agenda ALTER COLUMN id SET DEFAULT nextval('public.agenda_id_seq'::regclass);


--
-- Name: alertas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alertas ALTER COLUMN id SET DEFAULT nextval('public.alertas_id_seq'::regclass);


--
-- Name: alertas_caducidad id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alertas_caducidad ALTER COLUMN id SET DEFAULT nextval('public.alertas_caducidad_id_seq'::regclass);


--
-- Name: bloqueos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bloqueos ALTER COLUMN id SET DEFAULT nextval('public.bloqueos_id_seq'::regclass);


--
-- Name: busquedas_app id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.busquedas_app ALTER COLUMN id SET DEFAULT nextval('public.busquedas_app_id_seq'::regclass);


--
-- Name: calificaciones id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calificaciones ALTER COLUMN id SET DEFAULT nextval('public.calificaciones_id_seq'::regclass);


--
-- Name: conversaciones_app id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversaciones_app ALTER COLUMN id SET DEFAULT nextval('public.conversaciones_app_id_seq'::regclass);


--
-- Name: denuncias id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.denuncias ALTER COLUMN id SET DEFAULT nextval('public.denuncias_id_seq'::regclass);


--
-- Name: mensajes_app id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mensajes_app ALTER COLUMN id SET DEFAULT nextval('public.mensajes_app_id_seq'::regclass);


--
-- Name: productos_app id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos_app ALTER COLUMN id SET DEFAULT nextval('public.productos_app_id_seq'::regclass);


--
-- Name: productos_favoritos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos_favoritos ALTER COLUMN id SET DEFAULT nextval('public.productos_favoritos_id_seq'::regclass);


--
-- Name: vistas_producto id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vistas_producto ALTER COLUMN id SET DEFAULT nextval('public.vistas_producto_id_seq'::regclass);


--
-- Name: vistas_resumen_diario id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vistas_resumen_diario ALTER COLUMN id SET DEFAULT nextval('public.vistas_resumen_diario_id_seq'::regclass);


--
-- Data for Name: agenda; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.agenda (id, usuario_id, otro_usuario, producto_nombre, ultimo_mensaje, producto_imagen, conversacion_id, fecha_guardado, producto_id, vendedor_id, producto_precio, producto_categoria, productos_lista) FROM stdin;
1	6r5NPWjpJ8gYExIAbFudQPYRxtl2	Marlon	pene	🎤 Mensaje de voz	/uploads/1787607347021-137935093.jpg	93	2026-08-31 14:23:21.300646	\N	\N	\N	\N	\N
\.


--
-- Data for Name: alertas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alertas (id, usuario_id, producto_id, mensaje, tipo, leida, fecha, imagen_url) FROM stdin;
247	BkYL26JrcgOg2uFRkN1WYyrSNkk2	155	⏰ Tu producto "tt" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 18:06:00.085442	
261	BkYL26JrcgOg2uFRkN1WYyrSNkk2	128	🔄 Tu producto "vagina" ha sido renovado por 10 minutos más.	exito	f	2026-09-04 00:32:28.395471	
249	BkYL26JrcgOg2uFRkN1WYyrSNkk2	128	🔄 Tu producto "vagina" ha sido renovado por 10 minutos más.	exito	f	2026-09-03 18:46:37.767879	
255	BkYL26JrcgOg2uFRkN1WYyrSNkk2	128	🔄 Tu producto "vagina" ha sido renovado por 10 minutos más.	exito	f	2026-09-03 19:27:04.255975	
257	BkYL26JrcgOg2uFRkN1WYyrSNkk2	128	🔄 Tu producto "vagina" ha sido renovado por 10 minutos más.	exito	f	2026-09-03 22:23:59.885802	
263	BkYL26JrcgOg2uFRkN1WYyrSNkk2	128	🔄 Tu producto "vagina" ha sido renovado por 10 minutos más.	exito	f	2026-09-04 01:00:36.957027	
267	BkYL26JrcgOg2uFRkN1WYyrSNkk2	128	🔄 Tu producto "vagina" ha sido renovado por 10 minutos más.	exito	f	2026-09-04 17:52:16.21071	
120	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	66	⏰ Tu producto "📱 iPad Pro 12.9"" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.230343	
123	1	100	⏰ Tu producto "tetas" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.234598	
124	1	101	⏰ Tu producto "lolo" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.236008	
125	1	102	⏰ Tu producto "yoyo" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.238003	
126	1	103	⏰ Tu producto "yuyu" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.239659	
127	1	104	⏰ Tu producto "gg" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.241574	
128	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	67	⏰ Tu producto "👟 Zapatos Deportivos Nike" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.243048	
129	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	68	⏰ Tu producto "👟 Zapatos Deportivos Nike" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.244481	
130	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	69	⏰ Tu producto "📱 iPhone 15 Pro Max" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.246444	
131	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	70	⏰ Tu producto "📱 Samsung Galaxy S24 Ultra" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.249424	
132	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	71	⏰ Tu producto "💻 MacBook Air M3" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.250847	
133	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	72	⏰ Tu producto "💻 MacBook Pro M3" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.252327	
251	BkYL26JrcgOg2uFRkN1WYyrSNkk2	128	🔄 Tu producto "vagina" ha sido renovado por 10 minutos más.	exito	f	2026-09-03 18:58:20.556697	
138	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	73	⏰ Tu producto "🎧 Sony WH-1000XM5" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.260408	
139	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	74	⏰ Tu producto "📱 iPad Pro 12.9"" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.261771	
268	BkYL26JrcgOg2uFRkN1WYyrSNkk2	128	⏰ Tu producto "vagina" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-04 18:03:00.081693	
142	1	105	⏰ Tu producto "knives" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.26564	
146	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	79	⏰ Tu producto "🖱️ Mouse Logitech MX Master 3S" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.270508	
147	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	80	⏰ Tu producto "🎮 Control PS5 DualSense" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.272249	
148	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	81	⏰ Tu producto "🎮 Control Xbox Series X" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.274	
149	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	82	⏰ Tu producto "📷 Cámara Sony Alpha A7 IV" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.275798	
150	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	83	⏰ Tu producto "📷 Cámara Canon EOS R6" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.277266	
151	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	84	⏰ Tu producto "📷 GoPro Hero 12" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.278698	
152	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	75	⏰ Tu producto "📱 iPad Air 5" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.279954	
153	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	76	⏰ Tu producto "🖥️ Monitor LG 27" 4K" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.281147	
154	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	77	⏰ Tu producto "🖥️ Monitor Samsung Odyssey G7" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.28221	
155	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	78	⏰ Tu producto "⌨️ Teclado Logitech MX Keys" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.283466	
156	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	85	⏰ Tu producto "🔊 Altavoz JBL Charge 5" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.284772	
157	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	86	⏰ Tu producto "🔊 Sonos Era 100" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.285967	
158	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	87	⏰ Tu producto "⌚ Apple Watch Ultra 2" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.287161	
159	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	88	⏰ Tu producto "⌚ Samsung Galaxy Watch 6" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.288993	
160	4	106	⏰ Tu producto "666" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.290668	
161	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	89	⏰ Tu producto "⌚ Garmin Fenix 7" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.292284	
162	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	90	⏰ Tu producto "💾 Disco SSD Samsung T7 2TB" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.293663	
163	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	91	⏰ Tu producto "💾 Disco SSD Crucial X9 2TB" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.294838	
164	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	92	⏰ Tu producto "🔌 Cargador Anker 65W" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.29589	
165	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	93	⏰ Tu producto "🔌 Base de carga Anker 3-in-1" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.29734	
166	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	94	⏰ Tu producto "📡 Router WiFi ASUS RT-AX86U" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.298667	
167	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	95	⏰ Tu producto "📡 Router TP-Link Archer AX73" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.299837	
168	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	96	⏰ Tu producto "🎥 Webcam Logitech StreamCam" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.300914	
169	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	97	⏰ Tu producto "🎥 Webcam Razer Kiyo Pro" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.301971	
170	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	98	⏰ Tu producto "🔋 Power Bank Anker 26800mAh" ha caducado. Renueva viendo un anuncio.	caducado	f	2026-09-03 13:40:00.303804	
259	BkYL26JrcgOg2uFRkN1WYyrSNkk2	128	🔄 Tu producto "vagina" ha sido renovado por 10 minutos más.	exito	f	2026-09-03 23:02:52.954389	
265	BkYL26JrcgOg2uFRkN1WYyrSNkk2	128	🔄 Tu producto "vagina" ha sido renovado por 10 minutos más.	exito	f	2026-09-04 10:53:41.814331	
253	BkYL26JrcgOg2uFRkN1WYyrSNkk2	128	🔄 Tu producto "vagina" ha sido renovado por 10 minutos más.	exito	f	2026-09-03 19:11:19.17593	
\.


--
-- Data for Name: alertas_caducidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alertas_caducidad (id, producto_id, usuario_id, aviso_dado, fecha_aviso) FROM stdin;
2	190	6r5NPWjpJ8gYExIAbFudQPYRxtl2	t	2026-09-03 14:50:00.085258
5	191	6r5NPWjpJ8gYExIAbFudQPYRxtl2	t	2026-09-03 17:47:00.034612
6	155	BkYL26JrcgOg2uFRkN1WYyrSNkk2	t	2026-09-03 18:06:00.086798
17	128	BkYL26JrcgOg2uFRkN1WYyrSNkk2	t	2026-09-04 18:03:00.088027
\.


--
-- Data for Name: bloqueos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bloqueos (id, usuario_bloquea, usuario_bloqueado, fecha) FROM stdin;
\.


--
-- Data for Name: busquedas_app; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.busquedas_app (id, usuario_id, termino, fecha) FROM stdin;
1	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pill	2026-08-27 15:32:41.739888
2	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pillo	2026-08-27 15:32:42.647702
3	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pill	2026-08-27 15:32:55.072327
4	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 18:27:24.542878
5	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 18:29:53.382374
6	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 18:32:14.574593
7	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 18:37:12.180258
8	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 18:41:04.221334
9	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 18:44:52.722969
10	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 18:46:03.637139
11	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pill	2026-08-27 18:46:12.20299
12	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pillo	2026-08-27 18:46:12.384842
13	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pill	2026-08-27 18:46:14.012027
14	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 18:46:15.974968
15	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 18:46:30.419624
16	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 19:01:32.693012
17	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 19:05:20.457725
18	BkYL26JrcgOg2uFRkN1WYyrSNkk2	oene	2026-08-27 19:06:01.563044
19	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 19:06:03.563336
20	BkYL26JrcgOg2uFRkN1WYyrSNkk2	oene	2026-08-27 19:14:03.676905
21	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 19:14:05.654411
22	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 19:16:08.12442
23	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 19:16:12.971916
24	BkYL26JrcgOg2uFRkN1WYyrSNkk2	oene	2026-08-27 19:16:32.309727
25	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 19:16:34.115352
26	BkYL26JrcgOg2uFRkN1WYyrSNkk2	oene	2026-08-27 19:17:02.135719
27	BkYL26JrcgOg2uFRkN1WYyrSNkk2	oene	2026-08-27 19:17:03.870661
28	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 19:17:06.236246
29	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 19:28:33.48133
30	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 19:28:49.161844
31	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pene	2026-08-27 19:29:07.199826
32	BkYL26JrcgOg2uFRkN1WYyrSNkk2	pope	2026-09-04 18:27:53.37897
33	BkYL26JrcgOg2uFRkN1WYyrSNkk2	popey	2026-09-04 18:27:53.521065
34	BkYL26JrcgOg2uFRkN1WYyrSNkk2	popeye	2026-09-04 18:27:53.658163
35	BkYL26JrcgOg2uFRkN1WYyrSNkk2	vege	2026-09-04 18:28:46.714779
36	BkYL26JrcgOg2uFRkN1WYyrSNkk2	veget	2026-09-04 18:28:46.803289
37	BkYL26JrcgOg2uFRkN1WYyrSNkk2	vegeta	2026-09-04 18:28:46.981112
38	BkYL26JrcgOg2uFRkN1WYyrSNkk2	mega	2026-09-04 18:30:36.038987
39	BkYL26JrcgOg2uFRkN1WYyrSNkk2	megam	2026-09-04 18:30:36.138893
40	BkYL26JrcgOg2uFRkN1WYyrSNkk2	megama	2026-09-04 18:30:36.257066
41	BkYL26JrcgOg2uFRkN1WYyrSNkk2	megaman	2026-09-04 18:30:36.316459
42	BkYL26JrcgOg2uFRkN1WYyrSNkk2	care	2026-09-04 18:31:29.810018
43	BkYL26JrcgOg2uFRkN1WYyrSNkk2	carep	2026-09-04 18:31:30.183181
44	BkYL26JrcgOg2uFRkN1WYyrSNkk2	carepi	2026-09-04 18:31:30.23366
45	BkYL26JrcgOg2uFRkN1WYyrSNkk2	carepic	2026-09-04 18:31:30.532655
46	BkYL26JrcgOg2uFRkN1WYyrSNkk2	carepich	2026-09-04 18:31:30.648566
47	BkYL26JrcgOg2uFRkN1WYyrSNkk2	carepicha	2026-09-04 18:31:30.755711
\.


--
-- Data for Name: calificaciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.calificaciones (id, usuario_id, calificador_id, producto_id, puntuacion, comentario, fecha) FROM stdin;
18	6r5NPWjpJ8gYExIAbFudQPYRxtl2	BkYL26JrcgOg2uFRkN1WYyrSNkk2	179	5	te amo bb	2026-09-04 17:55:59.980363
\.


--
-- Data for Name: conversaciones_app; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conversaciones_app (id, usuario1_id, usuario2_id, fecha_creacion, producto_nombre, producto_imagen, producto_id, vendedor_id, estado) FROM stdin;
172	6r5NPWjpJ8gYExIAbFudQPYRxtl2	6r5NPWjpJ8gYExIAbFudQPYRxtl2	2026-09-04 17:42:25.195492	españa	/uploads/1788062835413-197372344.jpg	141	6r5NPWjpJ8gYExIAbFudQPYRxtl2	activa
173	BkYL26JrcgOg2uFRkN1WYyrSNkk2	6r5NPWjpJ8gYExIAbFudQPYRxtl2	2026-09-04 17:42:49.067157	yuh	/uploads/1788462380131-686395146.jpg	179	6r5NPWjpJ8gYExIAbFudQPYRxtl2	activa
\.


--
-- Data for Name: denuncias; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.denuncias (id, denunciante_id, denunciado_id, producto_id, motivo, fecha, estado) FROM stdin;
1	6r5NPWjpJ8gYExIAbFudQPYRxtl2	BkYL26JrcgOg2uFRkN1WYyrSNkk2	163	Producto sospechoso	2026-09-02 14:58:51.41138	pendiente
2	6r5NPWjpJ8gYExIAbFudQPYRxtl2	BkYL26JrcgOg2uFRkN1WYyrSNkk2	163	Acoso o maltrato	2026-09-02 15:03:36.767165	pendiente
3	6r5NPWjpJ8gYExIAbFudQPYRxtl2	BkYL26JrcgOg2uFRkN1WYyrSNkk2	154	Información falsa o engañosa	2026-09-02 15:05:31.979412	pendiente
\.


--
-- Data for Name: mensajes_app; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mensajes_app (id, conversacion_id, usuario_id, texto, imagen, fecha) FROM stdin;
848	172	6r5NPWjpJ8gYExIAbFudQPYRxtl2	ff		2026-09-04 17:42:27.575018
849	172	6r5NPWjpJ8gYExIAbFudQPYRxtl2	ff		2026-09-04 17:42:28.226622
850	172	6r5NPWjpJ8gYExIAbFudQPYRxtl2	ff		2026-09-04 17:42:29.04042
851	172	6r5NPWjpJ8gYExIAbFudQPYRxtl2	ff		2026-09-04 17:42:29.812079
852	172	6r5NPWjpJ8gYExIAbFudQPYRxtl2	ff		2026-09-04 17:42:30.61094
853	172	SYSTEM	||EL_COMPRADOR_YA_PUEDE_CALIFICARTE||		2026-09-04 17:42:30.621111
854	173	BkYL26JrcgOg2uFRkN1WYyrSNkk2	rf		2026-09-04 17:42:51.41714
855	173	BkYL26JrcgOg2uFRkN1WYyrSNkk2	ff		2026-09-04 17:42:52.082336
856	173	BkYL26JrcgOg2uFRkN1WYyrSNkk2	ff		2026-09-04 17:42:52.729426
857	173	BkYL26JrcgOg2uFRkN1WYyrSNkk2	ff		2026-09-04 17:42:53.457902
858	173	BkYL26JrcgOg2uFRkN1WYyrSNkk2	ff		2026-09-04 17:42:54.234066
859	173	6r5NPWjpJ8gYExIAbFudQPYRxtl2	ff		2026-09-04 17:43:16.629773
860	173	6r5NPWjpJ8gYExIAbFudQPYRxtl2	ff		2026-09-04 17:43:17.297859
861	173	6r5NPWjpJ8gYExIAbFudQPYRxtl2	ff		2026-09-04 17:43:18.063305
862	173	6r5NPWjpJ8gYExIAbFudQPYRxtl2	ff		2026-09-04 17:43:18.894147
863	173	6r5NPWjpJ8gYExIAbFudQPYRxtl2	ff		2026-09-04 17:43:20.06203
864	173	SYSTEM	||EL_COMPRADOR_YA_PUEDE_CALIFICARTE||		2026-09-04 17:43:20.073628
\.


--
-- Data for Name: productos_app; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.productos_app (id, nombre, categoria, precio, imagen_url, descripcion, fecha_creacion, estado, subcategoria, vendedor_id, direccion, vendedor_nombre, provincia, imagenes_reales, imagen_destacada, estado_moderacion, motivo_rechazo, likes, vistas, estado_ia_destacada, motivo_rechazo_destacada, destacada_publicada, fecha_expiracion, imagen_miniatura) FROM stdin;
163	Mellon	Deportes	546.00	/uploads/1788371024384-724617719.jpg	gag	2026-08-31 23:29:50.912388	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]	/uploads/1788240590521-901266206.webp	aprobado	\N	1	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
162	vv	Deportes	666.00	/uploads/1788240166079-479534314.jpg	yy	2026-08-31 23:22:47.770297	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
161	3ee	Deportes	1500.00	/uploads/1788236343101-357923817.jpg	bsh	2026-08-31 22:19:06.331633	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon		[]		aprobado	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
178	Producto en revisión	Sin categoría	0.00	/uploads/1788462323122-900562253.jpg		2026-09-03 13:05:23.229088	activo		6r5NPWjpJ8gYExIAbFudQPYRxtl2		Brenda		[]	/uploads/1788462323122-900562253.jpg	pendiente	\N	0	0	rechazado	Error al verificar con IA	f	2026-11-02 14:52:03.124242	\N
180	Producto en revisión	Sin categoría	0.00	/uploads/1788463050606-912089593.jpg		2026-09-03 13:17:30.796481	activo		6r5NPWjpJ8gYExIAbFudQPYRxtl2		Brenda		[]	/uploads/1788463050606-912089593.jpg	pendiente	\N	0	0	aprobado	\N	t	2026-11-02 14:52:03.124242	\N
184	Producto en revisión	Sin categoría	0.00	/uploads/1788463435729-518946928.avif		2026-09-03 13:23:55.958507	activo		6r5NPWjpJ8gYExIAbFudQPYRxtl2		Brenda		[]	/uploads/1788463435729-518946928.avif	pendiente	\N	0	0	aprobado	\N	t	2026-11-02 14:52:03.124242	\N
185	Producto en revisión	Sin categoría	0.00	/uploads/1788463565278-330006710.webp		2026-09-03 13:26:05.461226	activo		6r5NPWjpJ8gYExIAbFudQPYRxtl2		Brenda		[]	/uploads/1788463565278-330006710.webp	pendiente	\N	0	0	aprobado	\N	t	2026-11-02 14:52:03.124242	\N
174	Producto en revisión	Sin categoría	0.00	/uploads/1788399677915-19881575.png		2026-09-02 19:41:18.152672	activo		6r5NPWjpJ8gYExIAbFudQPYRxtl2		Brenda		[]	/uploads/1788399677915-19881575.png	pendiente	\N	0	0	aprobado	\N	t	2026-11-02 14:52:03.124242	\N
175	Producto en revisión	Sin categoría	0.00	/uploads/1788400347983-334201115.png		2026-09-02 19:52:28.1829	activo		6r5NPWjpJ8gYExIAbFudQPYRxtl2		Brenda		[]	/uploads/1788400347983-334201115.png	pendiente	\N	0	0	aprobado	\N	t	2026-11-02 14:52:03.124242	\N
166	Producto en revisión	Sin categoría	0.00	/uploads/1788395798623-789771699.jpg		2026-09-02 18:36:39.912518	activo		6r5NPWjpJ8gYExIAbFudQPYRxtl2		Brenda		[]	/uploads/1788395798623-789771699.jpg	pendiente	\N	0	0	aprobado	\N	t	2026-11-02 14:52:03.124242	\N
141	españa	Deportes	128.00	/uploads/1788062835413-197372344.jpg	shj\n	2026-08-29 22:07:17.144551	activo	Tennis	6r5NPWjpJ8gYExIAbFudQPYRxtl2	Lat: 9.9281, Lng: -84.0907	Brenda	San José	["/uploads/1788062836421-380628187.jpg","/uploads/1788062836461-689940320.jpg","/uploads/1788062836506-530549566.jpg"]		aprobado	\N	0	7	pendiente	\N	f	2026-11-02 14:52:03.124242	\N
179	yuh	Deportes	664.00	/uploads/1788462380131-686395146.jpg	vhhs	2026-09-03 13:06:20.845136	activo	Tennis	6r5NPWjpJ8gYExIAbFudQPYRxtl2	Lat: 9.9281, Lng: -84.0907	Brenda	San José	[]	/uploads/1788462380096-525494959.jpg	aprobado	\N	0	0	pendiente	\N	f	2026-11-02 14:52:03.124242	\N
190	piza	Deportes	656.00	/uploads/1788466177319-79534991.jpg	bdbd	2026-09-03 14:09:37.990389	activo	Tennis	6r5NPWjpJ8gYExIAbFudQPYRxtl2	Lat: 9.9281, Lng: -84.0907	Brenda	San José	[]		aprobado	\N	0	0	pendiente	\N	f	2026-11-02 14:52:03.124242	\N
66	📱 iPad Pro 12.9"	Electrónicos	1099.99	ipad_pro.png	Tablet con chip M2	2026-08-19 16:28:53.238545	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
168	Producto en revisión	Sin categoría	0.00	/uploads/1788396943542-106338912.jpg		2026-09-02 18:55:43.633208	activo		6r5NPWjpJ8gYExIAbFudQPYRxtl2		Brenda		[]	/uploads/1788396943542-106338912.jpg	pendiente	\N	0	0	rechazado	La imagen presenta un fondo desordenado y con múltiples objetos distractores, lo cual no es un fondo limpio. Además, hay un brillo excesivo/sobreexposición en la parte superior derecha del etiquetado del producto, dificultando la visibilidad de esa zona.	f	2026-11-02 14:52:03.124242	\N
169	Producto en revisión	Sin categoría	0.00	/uploads/1788397715878-597538081.jpg		2026-09-02 19:08:35.9652	activo		6r5NPWjpJ8gYExIAbFudQPYRxtl2		Brenda		[]	/uploads/1788397715878-597538081.jpg	pendiente	\N	0	0	aprobado	\N	t	2026-11-02 14:52:03.124242	\N
100	tetas	Música	55.00	\N	hh	2026-08-20 13:05:41.002931	caducado	Baterías	1	Lat: 9.911775762149299, Lng: -84.08598830488327	\N	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
101	lolo	Deportes	52.00	\N	gh	2026-08-20 13:11:24.637603	caducado	Gimnasio	1	Lat: 9.9281, Lng: -84.0907	\N	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
186	Producto en revisión	Sin categoría	0.00	/uploads/1788463669288-615099255.jpg		2026-09-03 13:27:49.434385	activo		6r5NPWjpJ8gYExIAbFudQPYRxtl2		Brenda		[]	/uploads/1788463669288-615099255.jpg	pendiente	\N	0	0	rechazado	Producto prohibido: arma de fuego	f	2026-11-02 14:52:03.124242	\N
102	yoyo	Deportes	25.00	\N	rt	2026-08-20 15:23:31.583096	caducado	Baloncesto	1	Lat: 9.9281, Lng: -84.0907	\N	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
103	yuyu	Deportes	36.00	pendiente	5	2026-08-20 15:36:57.241406	caducado	Tennis	1	Lat: 9.9281, Lng: -84.0907	\N	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
181	tuto	Deportes	546.00	/uploads/1788463112481-189117649.jpg	haha	2026-09-03 13:18:32.842511	activo	Tennis	6r5NPWjpJ8gYExIAbFudQPYRxtl2	Lat: 9.9281, Lng: -84.0907	Brenda	San José	[]	/uploads/1788463112459-39119134.jpg	rechazado	El producto es una réplica de arma tipo pistola, lo que está prohibido por las reglas de publicación.	0	0	pendiente	\N	f	2026-11-02 14:52:03.124242	\N
173	Producto en revisión	Sin categoría	0.00	/uploads/1788399311199-310162152.png		2026-09-02 19:35:11.567172	activo		6r5NPWjpJ8gYExIAbFudQPYRxtl2		Brenda		[]	/uploads/1788399311199-310162152.png	pendiente	\N	0	0	aprobado	\N	t	2026-11-02 14:52:03.124242	\N
177	Producto en revisión	Sin categoría	0.00	/uploads/1788400627034-883141007.png		2026-09-02 19:57:07.180255	activo		6r5NPWjpJ8gYExIAbFudQPYRxtl2		Brenda		[]	/uploads/1788400627034-883141007.png	pendiente	\N	0	0	rechazado	Error al verificar con IA	f	2026-11-02 14:52:03.124242	\N
142	pistola	Electrónicos	45.00	/uploads/1788062933329-547518817.jpg	zb	2026-08-29 22:08:53.890686	activo	Audio	6r5NPWjpJ8gYExIAbFudQPYRxtl2	Lat: 9.9281, Lng: -84.0907	Brenda	San José	[]		rechazado	El producto es un arma (pistola), lo cual está explícitamente prohibido por las reglas del marketplace.	0	0	pendiente	\N	f	2026-11-02 14:52:03.124242	\N
104	gg	Deportes	23.00	/uploads/1787262457936-126708731.jpg	gg	2026-08-20 15:47:38.16337	caducado	Gimnasio	1	Lat: 9.9281, Lng: -84.0907	\N	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
67	👟 Zapatos Deportivos Nike	Ropa	149.99	nike_air.png	Zapatos para correr	2026-08-19 16:29:11.484879	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
68	👟 Zapatos Deportivos Nike	Ropa	149.99	nike_air.png	Zapatos para correr	2026-08-19 16:29:22.460717	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
69	📱 iPhone 15 Pro Max	Electrónicos	1199.99	iphone15.png	El mejor iPhone del mercado	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
70	📱 Samsung Galaxy S24 Ultra	Electrónicos	1099.99	samsung_s24.png	Pantalla AMOLED 6.8"	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
71	💻 MacBook Air M3	Electrónicos	1299.99	macbook_air.png	Laptop ultraligera con chip M3	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
72	💻 MacBook Pro M3	Electrónicos	1999.99	macbook_pro.png	Laptop profesional con chip M3 Pro	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
164	pedro	Deportes	5656.00	/uploads/1788240726124-972736778.jpg	bzbs	2026-08-31 23:32:08.889718	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1788240727449-552536301.jpg","/uploads/1788240728605-488284473.jpg"]	/uploads/1788240726107-106422735.avif	aprobado	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
73	🎧 Sony WH-1000XM5	Electrónicos	399.99	sony_wh.png	Audífonos con cancelación de ruido	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
74	📱 iPad Pro 12.9"	Electrónicos	1099.99	ipad_pro.png	Tablet con chip M2	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
80	🎮 Control PS5 DualSense	Electrónicos	69.99	control_ps5.png	Control inalámbrico PlayStation 5	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
81	🎮 Control Xbox Series X	Electrónicos	59.99	control_xbox.png	Control inalámbrico Xbox	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
82	📷 Cámara Sony Alpha A7 IV	Electrónicos	2499.99	camara_sony.png	Cámara mirrorless full frame	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
83	📷 Cámara Canon EOS R6	Electrónicos	2299.99	camara_canon.png	Cámara mirrorless profesional	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
84	📷 GoPro Hero 12	Electrónicos	399.99	gopro_hero.png	Cámara de acción 5K	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
75	📱 iPad Air 5	Electrónicos	599.99	ipad_air.png	Tablet ligera con chip M1	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
76	🖥️ Monitor LG 27" 4K	Electrónicos	499.99	monitor_lg.png	Monitor 4K UHD 27 pulgadas	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
77	🖥️ Monitor Samsung Odyssey G7	Electrónicos	699.99	monitor_odyssey.png	Monitor curvo 240Hz	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
78	⌨️ Teclado Logitech MX Keys	Electrónicos	119.99	teclado_logitech.png	Teclado inalámbrico retroiluminado	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
85	🔊 Altavoz JBL Charge 5	Electrónicos	149.99	altavoz_jbl.png	Altavoz Bluetooth resistente al agua	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
86	🔊 Sonos Era 100	Electrónicos	249.99	sonos_era.png	Altavoz inteligente con Sonos	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
87	⌚ Apple Watch Ultra 2	Electrónicos	799.99	apple_watch_ultra.png	Reloj inteligente GPS + Celular	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
88	⌚ Samsung Galaxy Watch 6	Electrónicos	399.99	galaxy_watch.png	Reloj inteligente con Wear OS	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
182	Producto en revisión	Sin categoría	0.00	/uploads/1788463168316-349346207.jpg		2026-09-03 13:19:28.497513	activo		6r5NPWjpJ8gYExIAbFudQPYRxtl2		Brenda		[]	/uploads/1788463168316-349346207.jpg	pendiente	\N	0	0	aprobado	\N	t	2026-11-02 14:52:03.124242	\N
187	Producto en revisión	Sin categoría	0.00	/uploads/1788463747472-46770783.webp		2026-09-03 13:29:07.564714	activo		6r5NPWjpJ8gYExIAbFudQPYRxtl2		Brenda		[]	/uploads/1788463747472-46770783.webp	pendiente	\N	0	0	aprobado	\N	t	2026-11-02 14:52:03.124242	\N
167	Producto en revisión	Sin categoría	0.00	/uploads/1788396052308-591623341.jpg		2026-09-02 18:40:52.413101	activo		6r5NPWjpJ8gYExIAbFudQPYRxtl2		Brenda		[]	/uploads/1788396052308-591623341.jpg	pendiente	\N	0	0	aprobado	\N	t	2026-11-02 14:52:03.124242	\N
170	Producto en revisión	Sin categoría	0.00	/uploads/1788398452944-416540042.png		2026-09-02 19:20:53.087812	activo		6r5NPWjpJ8gYExIAbFudQPYRxtl2		Brenda		[]	/uploads/1788398452944-416540042.png	pendiente	\N	0	0	aprobado	\N	t	2026-11-02 14:52:03.124242	\N
191	control	Deportes	6464.00	/uploads/1788472261695-925506253.jpg	yshs	2026-09-03 15:51:02.518375	caducado	Tennis	6r5NPWjpJ8gYExIAbFudQPYRxtl2	Lat: 9.9281, Lng: -84.0907	Brenda	San José	[]		aprobado	\N	0	0	pendiente	\N	f	2026-09-03 17:46:03.347533	/uploads/miniaturas/1788472261695-925506253_thumb.jpg
183	tito	Música	646.00	/uploads/1788463199288-915788831.jpg	hshd	2026-09-03 13:19:59.827421	activo	Baterías	6r5NPWjpJ8gYExIAbFudQPYRxtl2	Lat: 9.9281, Lng: -84.0907	Brenda	San José	[]	/uploads/1788463199275-188774747.jpg	aprobado	\N	0	0	pendiente	\N	f	2026-11-02 14:52:03.124242	\N
171	marlon	Deportes	646.00	/uploads/1788398500359-394437647.jpg	vsbs	2026-09-02 19:21:41.158658	activo	Tennis	6r5NPWjpJ8gYExIAbFudQPYRxtl2	Lat: 9.9281, Lng: -84.0907	Brenda	San José	[]	/uploads/1788398500338-763378643.png	aprobado	\N	1	0	pendiente	\N	f	2026-11-02 14:52:03.124242	\N
105	knives	Electrónicos	15000.00	/uploads/1787528407994-615095766.jpg	yjeke	2026-08-23 17:40:08.19296	caducado	Audio	1	Lat: 9.9281, Lng: -84.0907	\N	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
106	666	Deportes	36.00	/uploads/1787528744902-657118378.jpg	ty	2026-08-23 17:45:45.811166	caducado	Tennis	4	Lat: 9.9281, Lng: -84.0907		San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
89	⌚ Garmin Fenix 7	Electrónicos	699.99	garmin_fenix.png	Reloj deportivo con GPS	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
90	💾 Disco SSD Samsung T7 2TB	Electrónicos	249.99	ssd_samsung.png	Disco SSD portátil USB-C	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
91	💾 Disco SSD Crucial X9 2TB	Electrónicos	199.99	ssd_crucial.png	Disco SSD portátil 2TB	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
92	🔌 Cargador Anker 65W	Electrónicos	49.99	cargador_anker.png	Cargador USB-C GaN 65W	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
93	🔌 Base de carga Anker 3-in-1	Electrónicos	89.99	base_anker.png	Base de carga para Apple	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
94	📡 Router WiFi ASUS RT-AX86U	Electrónicos	249.99	router_asus.png	Router WiFi 6 gaming	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
95	📡 Router TP-Link Archer AX73	Electrónicos	199.99	router_tplink.png	Router WiFi 6 AX5400	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
96	🎥 Webcam Logitech StreamCam	Electrónicos	169.99	webcam_logitech.png	Webcam para streaming 1080p 60fps	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
97	🎥 Webcam Razer Kiyo Pro	Electrónicos	199.99	webcam_razer.png	Webcam con sensor Sony Starvis	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
98	🔋 Power Bank Anker 26800mAh	Electrónicos	129.99	powerbank_anker.png	Batería portátil de alta capacidad	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
165	pinga	Deportes	548.00	/uploads/1788241013101-772018076.jpg	bshs	2026-08-31 23:36:58.476732	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon		["/uploads/1788241014137-356171388.jpg","/uploads/1788241015147-268067938.jpg"]	/uploads/1788241013085-722809707.avif	aprobado	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
125	45	Música	23.00	/uploads/1787844848771-162659210.jpg	g	2026-08-27 09:34:09.919755	caducado	Cuerdas	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1787844848771-162659210.jpg"]		aprobado		0	1	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
112	pillo	Deportes	23.00	/uploads/1787762080866-102211925.jpg	tt	2026-08-26 10:34:41.806713	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
120	mascara de soldar	Deportes	125.00		en todas 	2026-08-26 21:24:50.370556	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1787801089865-971512935.jpg"]		aprobado		0	2	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
115	6	Deportes	6.00		g	2026-08-26 20:12:44.912791	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1787796762898-527019098.jpg"]		pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
116	90	Deportes	36.00		t	2026-08-26 20:14:54.858079	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1787796894403-395535864.jpg"]		pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
118	pepe	Música	12000.00		yupi	2026-08-26 21:07:28.701467	caducado	Cuerdas	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1787800046727-981048272.jpg"]		aprobado		0	2	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
119	mascara de soldar 	Deportes	45.00		df	2026-08-26 21:20:43.039733	caducado	Gimnasio	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1787800842207-286382480.jpg"]		aprobado		0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
130	hh	Deportes	56.00	/uploads/1787846071631-631429144.jpg	vh	2026-08-27 09:54:32.571765	caducado	Baloncesto	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado		0	5	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
109	pito	Deportes	22.00	/uploads/1787262457936-126708731.jpg	dd	2026-08-23 19:09:55.738838	activo	Baloncesto	6r5NPWjpJ8gYExIAbFudQPYRxtl2	Lat: 9.9281, Lng: -84.0907	Brenda	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-11-02 14:52:03.124242	\N
128	vagina	Hogar	12.00	/uploads/1787845091128-647821128.jpg	13	2026-08-27 09:38:11.547604	caducado	Iluminación	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1787845091250-920821591.jpg","/uploads/1787845091299-151828457.png"]		aprobado		2	4	pendiente	\N	f	2026-09-04 18:02:16.19621	\N
188	1997	Deportes	66.00	/uploads/1788463780077-121840557.jpg	hh	2026-09-03 13:29:40.318126	activo	Tennis	6r5NPWjpJ8gYExIAbFudQPYRxtl2	Lat: 9.9281, Lng: -84.0907	Brenda	San José	[]	/uploads/1788463780060-722549699.webp	aprobado	\N	1	0	pendiente	\N	f	2026-11-02 14:52:03.124242	\N
172	Producto en revisión	Sin categoría	0.00	/uploads/1788399118113-622642901.webp		2026-09-02 19:31:58.301203	activo		6r5NPWjpJ8gYExIAbFudQPYRxtl2		Brenda		[]	/uploads/1788399118113-622642901.webp	pendiente	\N	0	0	aprobado	\N	t	2026-11-02 14:52:03.124242	\N
189	haha	Deportes	4646.00	/uploads/1788463922545-383331749.jpg	svah	2026-09-03 13:32:02.837841	activo	Tennis	6r5NPWjpJ8gYExIAbFudQPYRxtl2	Lat: 9.9281, Lng: -84.0907	Brenda	San José	[]		rechazado	La imagen muestra un arma de fuego, categoría prohibida.	0	0	pendiente	\N	f	2026-11-02 14:52:03.124242	\N
160	y6	Deportes	55.00	/uploads/1788233161254-521580108.png	gg	2026-08-31 21:26:02.875312	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1788233161475-885608508.jpg"]	/uploads/1788233161254-521580108.png	aprobado	\N	0	18	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
79	🖱️ Mouse Logitech MX Master 3S	Electrónicos	99.99	mouse_logitech.png	Mouse inalámbrico ergonómico	2026-08-19 17:22:07.920603	caducado	\N	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	\N	Usuario 1	San José	\N	\N	pendiente	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
124	logo	Música	99999.00	/uploads/1787844647853-202395043.png	qe	2026-08-27 09:30:48.268112	caducado	Cuerdas	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1787844647853-202395043.png"]		aprobado		0	4	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
123	pepa	Deportes	12.00	/uploads/1787844327421-560845924.jpg	sd	2026-08-27 09:25:28.445067	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1787844327421-560845924.jpg"]		aprobado		0	2	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
121	h	Deportes	33.00		chh	2026-08-26 21:34:00.34549	caducado	Baloncesto	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1787801639794-584104083.jpg"]		aprobado		0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
129	gt	Hogar	86.00	/uploads/1787845407790-86506469.jpg	gh	2026-08-27 09:43:28.481807	caducado	Iluminación	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 10.01442355578465, Lng: -84.2136937074209	Marlon	Alajuela	[]		aprobado		0	4	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
113	yy	Música	66.00	/uploads/1787778010527-759214688.jpg	hh	2026-08-26 15:00:11.851458	caducado	Pianos	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1787778011467-503114570.jpg"]	/uploads/1787778010527-759214688.jpg	aprobado	\N	0	4	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
131	picha	Deportes	36.00	/uploads/1787936926278-955312850.jpg	hj	2026-08-28 11:08:48.375948	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1787936926364-67257711.jpg"]	/uploads/1787936926278-955312850.jpg	aprobado		0	5	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
107	pollo	Deportes	23.00	/uploads/1787262457936-126708731.jpg	56	2026-08-23 17:56:37.568823	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Brenda	San José	\N	\N	pendiente	\N	-1	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
117	mascara de soldar	Deportes	12000.00		en todas	2026-08-26 21:00:24.4412	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1787799623809-109050029.jpg"]		aprobado		0	1	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
132	cohete	Deportes	10000.00	/uploads/1787967177385-502565470.jpg	listo	2026-08-28 19:32:59.197892	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
133	cohete	Deportes	1085.00	/uploads/1787967353707-612574664.jpg	dhdj	2026-08-28 19:35:54.193129	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
134	cohete	Deportes	4564.00	/uploads/1787967512970-194036437.jpg	bsj	2026-08-28 19:38:33.605717	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
136	cohete	Deportes	12.00	/uploads/1787967720636-702929375.jpg	jsbs	2026-08-28 19:42:01.245136	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
147	manilo	Deportes	56.00	/uploads/1788138519538-431038345.jpg	hssj	2026-08-30 19:08:40.537649	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado	\N	0	1	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
138	phdjd	Deportes	64.00	/uploads/1787968085097-659692644.jpg	hdhd	2026-08-28 19:48:05.70086	caducado	Baloncesto	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
139	 zb	Deportes	6797.00	/uploads/1787968461123-623543656.jpg	zbbd	2026-08-28 19:54:21.788489	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		rechazado	El producto es una pistola, la cual se clasifica como un arma y está explícitamente prohibida bajo la regla 'Armas de cualquier tipo (cuchillos, pistolas, rifles, etc.)'.	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
140	perro	Música	12348.00	/uploads/1787969944128-23757909.jpg	shhs	2026-08-28 20:19:04.47296	caducado	Baterías	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		rechazado	El producto es un animal vivo (perro), lo cual está explícitamente prohibido por las reglas de publicación.	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
137	xbz	Deportes	6464.00	/uploads/1787967789509-395934999.jpg	bb	2026-08-28 19:43:09.986687	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado	\N	0	1	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
144	pico	Deportes	12.00	/uploads/1788120736934-651335450.jpg	er	2026-08-30 14:12:18.961215	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
154	msrl	Deportes	6464.00	/uploads/1788229751766-725312525.png	bsjs	2026-08-31 20:29:12.073482	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1788229751828-60933100.jpg"]	/uploads/1788229751766-725312525.png	aprobado	\N	0	17	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
146	riky	Deportes	56.00	/uploads/1788127125704-670075586.jpg	rn	2026-08-30 15:58:47.69781	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
145	rato	Deportes	999.00	/uploads/1788126990440-18282670.jpg	vh	2026-08-30 15:56:32.51141	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
159	777	Deportes	66.00	/uploads/1788232912098-435291425.png	vh	2026-08-31 21:21:53.604303	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1788232912298-983471320.jpg"]	/uploads/1788232912098-435291425.png	aprobado	\N	0	17	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
148	hh	Deportes	66.00	/uploads/1788151346435-547678005.jpg	gh	2026-08-30 22:42:28.452782	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
149	yy	Deportes	66.00	/uploads/1788152474424-371350396.jpg	jj	2026-08-30 23:01:16.214511	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
143	67	Deportes	36.00	/uploads/1788112380772-87397589.jpg	gh	2026-08-30 11:53:02.924489	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado	\N	0	1	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
151	hh	Deportes	266.00	/uploads/1788208756367-850587901.png	yhh	2026-08-31 14:39:17.415077	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado	\N	0	0	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
150	pp	Deportes	94.00	/uploads/1788152738456-494972946.jpg	hHs	2026-08-30 23:05:40.321055	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado	\N	0	4	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
126	4567	Hogar	223.00	/uploads/1787844995867-795951724.jpg	cg	2026-08-27 09:36:36.379308	caducado	Textiles	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado		0	2	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
114	polaco	Deportes	23.00	/uploads/1787779170855-562190763.jpg	56	2026-08-26 15:19:32.158389	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1787779170972-842064201.jpg","/uploads/1787779171002-302673667.jpg","/uploads/1787779171079-991774011.jpg"]	/uploads/1787779170855-562190763.jpg	aprobado	\N	0	7	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
111	pene	Deportes	32.00	/uploads/1787607347021-137935093.jpg	dd	2026-08-24 15:35:47.597587	activo	Gimnasio	6r5NPWjpJ8gYExIAbFudQPYRxtl2	Lat: 9.997554344490673, Lng: -84.11340912041508	Brenda	Heredia	\N	\N	aprobado	\N	1	7	pendiente	\N	f	2026-11-02 14:52:03.124242	\N
152	popi	Deportes	96.00	/uploads/1788228870516-365481254.png	bhh	2026-08-31 20:14:32.702416	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1788228870809-44332190.jpg"]	/uploads/1788228870516-365481254.png	aprobado	\N	0	11	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
158	i888	Deportes	96.00	/uploads/1788232585161-493299083.jpg	hh	2026-08-31 21:16:25.585967	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado	\N	0	8	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
153	gjy	Deportes	596.00	/uploads/1788229565409-623096021.png	ghh	2026-08-31 20:26:06.92406	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1788229565461-529187365.jpg"]	/uploads/1788229565409-623096021.png	aprobado	\N	0	15	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
157	vh	Deportes	55.00	/uploads/1788232490057-138017401.png	bhh	2026-08-31 21:14:50.962882	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1788232490149-986046818.jpg"]	/uploads/1788232490057-138017401.png	aprobado	\N	0	5	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
156	hy	Deportes	86.00	/uploads/1788230710551-864406432.png	gh	2026-08-31 20:45:11.349141	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1788230710660-260770387.jpg"]	/uploads/1788230710551-864406432.png	aprobado	\N	0	16	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
135	cohete	Deportes	12.00	/uploads/1787967629283-315693012.jpg	shsh	2026-08-28 19:40:29.773984	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	[]		aprobado	\N	0	2	pendiente	\N	f	2026-09-03 13:07:10.071731	\N
155	tt	Deportes	69.00	/uploads/1788230280008-107125649.jpg	hh	2026-08-31 20:38:00.756908	caducado	Tennis	BkYL26JrcgOg2uFRkN1WYyrSNkk2	Lat: 9.9281, Lng: -84.0907	Marlon	San José	["/uploads/1788230280326-676060949.jpg"]	/uploads/1788230280008-107125649.jpg	rechazado	El producto muestra un animal vivo (perro), lo cual está explícitamente prohibido por las reglas de publicación.	0	0	pendiente	\N	f	2026-09-03 18:05:31.974531	\N
\.


--
-- Data for Name: productos_favoritos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.productos_favoritos (id, usuario_id, producto_id, fecha) FROM stdin;
89	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	67	2026-08-24 14:22:15.940369
167	6r5NPWjpJ8gYExIAbFudQPYRxtl2	163	2026-09-02 14:09:28.929084
172	BkYL26JrcgOg2uFRkN1WYyrSNkk2	171	2026-09-03 17:52:07.118912
173	BkYL26JrcgOg2uFRkN1WYyrSNkk2	128	2026-09-03 17:57:09.147709
174	BkYL26JrcgOg2uFRkN1WYyrSNkk2	111	2026-09-04 11:08:38.417515
175	BkYL26JrcgOg2uFRkN1WYyrSNkk2	188	2026-09-04 13:44:21.283849
33	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	67	2026-08-21 20:58:34.48725
34	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	68	2026-08-21 20:58:34.48725
36	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	67	2026-08-21 20:59:49.071268
37	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	68	2026-08-21 20:59:49.071268
38	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	69	2026-08-21 20:59:49.071268
39	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	70	2026-08-21 20:59:49.071268
40	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	71	2026-08-21 20:59:49.071268
41	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	67	2026-08-21 21:03:17.657007
43	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	71	2026-08-21 23:38:33.330339
44	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	69	2026-08-21 23:38:34.216157
45	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	67	2026-08-21 23:38:35.544217
48	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	66	2026-08-22 12:51:18.773434
51	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	104	2026-08-22 14:00:12.621656
52	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	103	2026-08-22 17:06:11.656589
54	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	99	2026-08-22 17:06:36.835425
55	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	67	2026-08-23 10:16:07.303256
56	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	101	2026-08-23 10:16:21.29717
57	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	67	2026-08-23 16:11:05.814407
58	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	95	2026-08-23 16:11:13.875368
59	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	104	2026-08-23 16:11:39.992802
60	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	66	2026-08-23 21:34:50.601007
61	h4L4RBbHfIZvP8ANHxLo5uQbKmj2	66	2026-08-23 21:34:54.22201
76	9eq4Cz8BKOd6MVUVRdzDeGpPuV02	109	2026-08-24 13:38:15.361357
\.


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios (uid, email, nombre, foto_perfil, telefono, fecha_registro, acepta_recoleccion) FROM stdin;
9eq4Cz8BKOd6MVUVRdzDeGpPuV02	inclan4321@gmail.com	Usuario 1	\N	\N	2026-08-23 14:38:29.971414	f
9tzn1hoR8yZBIZQnpzcwIa3dYhF3	iu@gmail.com	pepe	\N	123456	2026-08-23 18:48:32.080292	f
UID_DEL_NUEVO_USUARIO	correo_del_nuevo_usuario@email.com	Nombre del Usuario	\N	\N	2026-08-23 18:49:36.628175	f
IGt1e01yCdQuhp6EvSLtMUMDItI3	knives@gmail.com	puto	\N	2323	2026-08-23 19:10:35.726787	f
6r5NPWjpJ8gYExIAbFudQPYRxtl2	inclan4321@gmail.com	Brenda	/uploads/1787602663400-703427908.jpg	\N	2026-08-23 12:24:49.895746	f
BkYL26JrcgOg2uFRkN1WYyrSNkk2	inclan54321@gmail.com	Marlon	/uploads/1788377889962-926181072.jpg	\N	2026-08-23 12:23:07.073286	f
\.


--
-- Data for Name: vistas_producto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vistas_producto (id, producto_id, usuario_id, ip, fecha) FROM stdin;
1	131	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 16:14:08.971749
2	120	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 16:14:30.926625
3	111	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 16:27:39.446212
4	110	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 16:27:41.736691
5	128	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 16:46:26.362799
6	128	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 16:49:05.420489
7	128	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 17:24:57.237445
8	128	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 17:28:58.430902
9	128	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 17:29:16.206083
10	128	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 17:33:37.094639
11	129	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 17:33:43.291637
12	129	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 17:50:05.700327
13	128	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 17:50:43.725692
14	129	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 17:50:46.379422
15	111	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 18:03:19.783977
16	141	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 18:03:30.673949
17	111	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 18:06:11.606136
18	111	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 18:06:26.428455
19	141	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 18:07:19.092712
20	131	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 19:27:55.06815
21	114	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 19:28:00.793681
22	114	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 19:28:08.474498
23	114	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 19:28:13.635138
24	131	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 19:28:26.212513
25	130	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 19:28:28.855154
26	130	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 19:28:30.589268
27	131	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 19:28:31.735078
28	113	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 19:28:33.671275
29	114	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 19:28:45.207171
30	131	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 19:28:48.887221
31	114	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 19:28:50.333772
32	114	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 19:28:55.164417
33	124	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 19:37:11.962153
34	124	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 19:37:15.201506
35	124	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 19:37:39.108891
36	126	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 19:45:34.979321
37	154	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 20:30:14.053457
38	157	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:15:36.219565
39	158	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:17:03.780173
40	159	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:22:49.020166
41	160	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:26:38.09223
42	160	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:27:17.533162
43	160	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:27:22.585258
44	159	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:27:24.435887
45	159	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:27:29.415722
46	160	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:27:30.994509
47	157	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:27:32.327419
48	158	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:27:33.774381
49	156	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:27:35.608181
50	154	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:27:37.747344
51	152	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:27:40.16397
52	153	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:27:43.936517
53	150	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:27:56.105802
54	152	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:27:57.231758
55	156	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:27:59.800593
56	159	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:28:02.72502
57	158	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:30:40.952503
58	156	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:30:43.232695
59	154	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:30:44.865751
60	160	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:30:46.40977
61	159	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:30:50.955749
62	160	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:37:03.601014
63	160	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:37:14.376765
64	154	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:37:22.170254
65	159	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:37:23.849107
66	160	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:38:55.055575
67	154	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:39:05.692486
68	160	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:43:48.976914
69	156	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:43:55.202993
70	160	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:45:17.977527
71	156	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:45:22.712536
72	156	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:45:24.506822
73	156	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:45:26.514359
74	159	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:45:31.941732
75	159	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:45:35.339056
76	154	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:45:36.910924
77	158	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:45:38.864668
78	158	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:45:44.983519
79	153	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:45:48.018059
80	153	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:45:52.847511
81	154	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:48:04.779231
82	159	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:48:07.022651
83	160	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:48:10.364747
84	160	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:48:15.3192
85	157	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:48:16.822308
86	157	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:48:18.900676
87	158	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:48:20.419168
88	154	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:48:30.611252
89	154	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:48:32.554469
90	154	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:48:34.673961
91	156	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:48:36.107639
92	156	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:48:37.683814
93	159	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:48:38.890107
94	153	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:48:41.918111
95	150	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:48:47.119689
96	150	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:48:54.241936
97	152	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:48:56.60808
98	152	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:48:59.607483
99	152	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:49:01.644273
100	117	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:49:06.378077
101	111	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:49:08.257427
102	141	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:49:15.640107
103	141	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:49:21.87122
104	111	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:49:25.170254
105	130	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:49:29.531226
106	131	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:49:31.175419
107	123	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:49:33.758168
108	143	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:49:38.385305
109	137	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:49:39.914394
110	154	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:49:44.24407
111	159	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:49:46.283081
112	154	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:50:11.1227
113	153	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:50:13.12988
114	153	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:50:57.8778
115	152	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:50:59.450276
116	150	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:51:02.228991
117	156	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:51:05.700774
118	156	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:51:14.814246
119	156	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:51:17.522156
120	156	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:51:20.639466
121	159	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:51:23.435573
122	159	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:51:25.560613
123	159	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:51:27.448018
124	130	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:52:49.628054
125	111	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:52:52.548638
126	152	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:52:56.114234
127	152	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:52:58.181259
128	141	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:00.515641
129	141	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:01.773843
130	154	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:06.48302
131	153	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:08.291095
132	153	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:11.787456
133	160	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:13.94008
134	156	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:17.818167
135	157	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:19.565437
136	158	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:21.844856
137	154	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:23.070258
138	159	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:24.289368
139	159	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:27.973432
140	128	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:35.326412
141	128	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:43.582793
142	126	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:47.119471
143	129	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:48.519953
144	125	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:52.931502
145	113	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:54.147844
146	113	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:56.476368
147	118	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:53:58.967531
148	113	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:54:00.444483
149	124	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:54:01.530626
150	118	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:54:02.733889
151	152	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:54:07.190104
152	147	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:54:12.412584
153	159	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:54:15.694172
154	156	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:54:19.268373
155	154	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:54:21.080451
156	153	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:54:23.346977
157	153	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:54:33.68545
158	160	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:54:35.729918
159	158	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:54:42.41298
160	160	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:54:43.621078
161	153	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:54:44.83614
162	156	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:54:46.032325
163	154	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:54:48.473605
164	123	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:54:53.817836
165	152	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:54:55.865249
166	153	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:55:59.157609
167	160	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:56:47.216763
168	160	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:57:08.813762
169	120	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:57:16.50354
170	120	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:57:19.960718
171	135	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:57:22.336139
172	141	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:57:24.408909
173	114	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 21:57:29.752958
174	154	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 22:38:29.260573
175	152	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 22:38:33.239944
176	153	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 22:38:38.491198
177	153	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 22:41:06.582132
178	153	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 22:45:45.506146
179	135	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 22:48:24.36283
180	160	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 22:48:25.55073
181	130	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 22:48:33.577872
182	111	BkYL26JrcgOg2uFRkN1WYyrSNkk2	192.168.100.168	2026-08-31 22:50:05.231938
\.


--
-- Data for Name: vistas_resumen_diario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vistas_resumen_diario (id, producto_id, fecha, total_vistas) FROM stdin;
28	154	2026-09-01	17
1	128	2026-08-31	2
2	129	2026-08-31	3
42	152	2026-09-01	11
44	150	2026-09-01	4
43	153	2026-09-01	15
162	135	2026-09-01	2
32	160	2026-09-01	18
16	130	2026-09-01	5
6	111	2026-09-01	7
29	157	2026-09-01	5
131	128	2026-09-01	2
27	126	2026-09-01	2
134	129	2026-09-01	1
135	125	2026-09-01	1
19	113	2026-09-01	4
24	124	2026-09-01	4
138	118	2026-09-01	2
143	147	2026-09-01	1
31	159	2026-09-01	17
30	158	2026-09-01	8
40	156	2026-09-01	16
98	123	2026-09-01	2
160	120	2026-09-01	2
91	117	2026-09-01	1
7	141	2026-09-01	7
12	114	2026-09-01	7
11	131	2026-09-01	5
99	143	2026-09-01	1
100	137	2026-09-01	1
\.


--
-- Name: agenda_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.agenda_id_seq', 25, true);


--
-- Name: alertas_caducidad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.alertas_caducidad_id_seq', 17, true);


--
-- Name: alertas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.alertas_id_seq', 268, true);


--
-- Name: bloqueos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bloqueos_id_seq', 10, true);


--
-- Name: busquedas_app_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.busquedas_app_id_seq', 47, true);


--
-- Name: calificaciones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.calificaciones_id_seq', 18, true);


--
-- Name: conversaciones_app_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.conversaciones_app_id_seq', 173, true);


--
-- Name: denuncias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.denuncias_id_seq', 3, true);


--
-- Name: mensajes_app_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mensajes_app_id_seq', 864, true);


--
-- Name: productos_app_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.productos_app_id_seq', 191, true);


--
-- Name: productos_favoritos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.productos_favoritos_id_seq', 175, true);


--
-- Name: vistas_producto_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vistas_producto_id_seq', 214, true);


--
-- Name: vistas_resumen_diario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vistas_resumen_diario_id_seq', 205, true);


--
-- Name: agenda agenda_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agenda
    ADD CONSTRAINT agenda_pkey PRIMARY KEY (id);


--
-- Name: alertas_caducidad alertas_caducidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alertas_caducidad
    ADD CONSTRAINT alertas_caducidad_pkey PRIMARY KEY (id);


--
-- Name: alertas_caducidad alertas_caducidad_producto_id_usuario_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alertas_caducidad
    ADD CONSTRAINT alertas_caducidad_producto_id_usuario_id_key UNIQUE (producto_id, usuario_id);


--
-- Name: alertas alertas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alertas
    ADD CONSTRAINT alertas_pkey PRIMARY KEY (id);


--
-- Name: bloqueos bloqueos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bloqueos
    ADD CONSTRAINT bloqueos_pkey PRIMARY KEY (id);


--
-- Name: busquedas_app busquedas_app_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.busquedas_app
    ADD CONSTRAINT busquedas_app_pkey PRIMARY KEY (id);


--
-- Name: calificaciones calificaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calificaciones
    ADD CONSTRAINT calificaciones_pkey PRIMARY KEY (id);


--
-- Name: conversaciones_app conversaciones_app_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversaciones_app
    ADD CONSTRAINT conversaciones_app_pkey PRIMARY KEY (id);


--
-- Name: denuncias denuncias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.denuncias
    ADD CONSTRAINT denuncias_pkey PRIMARY KEY (id);


--
-- Name: mensajes_app mensajes_app_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mensajes_app
    ADD CONSTRAINT mensajes_app_pkey PRIMARY KEY (id);


--
-- Name: productos_app productos_app_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos_app
    ADD CONSTRAINT productos_app_pkey PRIMARY KEY (id);


--
-- Name: productos_favoritos productos_favoritos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos_favoritos
    ADD CONSTRAINT productos_favoritos_pkey PRIMARY KEY (id);


--
-- Name: calificaciones unique_calificador_producto; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calificaciones
    ADD CONSTRAINT unique_calificador_producto UNIQUE (calificador_id, producto_id);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (uid);


--
-- Name: vistas_producto vistas_producto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vistas_producto
    ADD CONSTRAINT vistas_producto_pkey PRIMARY KEY (id);


--
-- Name: vistas_resumen_diario vistas_resumen_diario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vistas_resumen_diario
    ADD CONSTRAINT vistas_resumen_diario_pkey PRIMARY KEY (id);


--
-- Name: vistas_resumen_diario vistas_resumen_diario_producto_id_fecha_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vistas_resumen_diario
    ADD CONSTRAINT vistas_resumen_diario_producto_id_fecha_key UNIQUE (producto_id, fecha);


--
-- Name: idx_agenda_usuario; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_agenda_usuario ON public.agenda USING btree (usuario_id);


--
-- Name: idx_agenda_usuario_vendedor; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_agenda_usuario_vendedor ON public.agenda USING btree (usuario_id, vendedor_id);


--
-- Name: idx_calificaciones_calificador_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_calificaciones_calificador_id ON public.calificaciones USING btree (calificador_id);


--
-- Name: idx_calificaciones_producto_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_calificaciones_producto_id ON public.calificaciones USING btree (producto_id);


--
-- Name: idx_calificaciones_usuario_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_calificaciones_usuario_id ON public.calificaciones USING btree (usuario_id);


--
-- Name: idx_resumen_producto_fecha; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_resumen_producto_fecha ON public.vistas_resumen_diario USING btree (producto_id, fecha);


--
-- Name: idx_vistas_fecha; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vistas_fecha ON public.vistas_producto USING btree (fecha);


--
-- Name: idx_vistas_producto; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vistas_producto ON public.vistas_producto USING btree (producto_id);


--
-- Name: mensajes_app mensajes_app_conversacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mensajes_app
    ADD CONSTRAINT mensajes_app_conversacion_id_fkey FOREIGN KEY (conversacion_id) REFERENCES public.conversaciones_app(id);


--
-- PostgreSQL database dump complete
--

\unrestrict tCX03aInrsOVWjpuOBqzIdYcxJMLyl2zYflZnyo8uZQr7YWQhysdBejLDnpOHgk

