-- 1. Crear una consulta que muestre la información de los usuarios con toda su información de forma legible
-- (es decir en vez de códigos mostrar su valor, omitir el campo codigo_municipio), mostrar el nombre
-- completo y las fechas en formato DD*NOMBRE_MES*AÑO. Para los lugares mostrar el primer y segundo
-- nivel (ejemplo: municipio y departamento). Utilizar producto cartesiano con el operador (+).
SELECT 
    U.NOMBRE || ' ' || U.APELLIDO AS NOMBRE_COMPLETO,
    TO_CHAR(U.FECHA_NACIMIENTO, 'DD*MONTH*YYYY') AS FECHA_NACIMIENTO,
    TO_CHAR(U.FECHA_REGISTRO, 'DD*MONTH*YYYY') AS FECHA_REGISTRO,
    TU.TIPO_USUARIO,
    EU.ESTADO_USUARIO,
    L1.NOMBRE_LUGAR AS MUNICIPIO,
    L2.NOMBRE_LUGAR AS DEPARTAMENTO
FROM 
    TBL_USUARIOS U
    JOIN TBL_TIPOS_USUARIOS TU ON U.CODIGO_TIPO_USUARIO = TU.CODIGO_TIPO_USUARIO
    JOIN TBL_ESTADOS_USUARIOS EU ON U.CODIGO_ESTADO_USUARIO = EU.CODIGO_ESTADO_USUARIO
    LEFT JOIN TBL_LUGARES L1 ON U.CODIGO_LUGAR = L1.CODIGO_LUGAR
    LEFT JOIN TBL_LUGARES L2 ON L1.CODIGO_LUGAR_PADRE = L2.CODIGO_LUGAR;

-- 2.Mostrar el video que más y menos veces ha sido compartido. Mostrar los datos del video, cantidad de
-- shares y cantidad de usuarios diferentes (distinct) que lo han compartido.
-- Video más compartido
SELECT 
    V.NOMBRE_VIDEO,
    V.CANTIDAD_SHARES,
    COUNT(DISTINCT U.CODIGO_USUARIO) AS CANTIDAD_USUARIOS
FROM 
    TBL_VIDEOS V
    JOIN TBL_USUARIOS U ON V.CODIGO_USUARIO = U.CODIGO_USUARIO
GROUP BY 
    V.NOMBRE_VIDEO, V.CANTIDAD_SHARES
ORDER BY 
    V.CANTIDAD_SHARES DESC
FETCH FIRST 1 ROW ONLY;

-- Video menos compartido
SELECT 
    V.NOMBRE_VIDEO,
    V.CANTIDAD_SHARES,
    COUNT(DISTINCT U.CODIGO_USUARIO) AS CANTIDAD_USUARIOS
FROM
    TBL_VIDEOS V
    JOIN TBL_USUARIOS U ON V.CODIGO_USUARIO = U.CODIGO_USUARIO
GROUP BY
    V.NOMBRE_VIDEO, V.CANTIDAD_SHARES
ORDER BY
    V.CANTIDAD_SHARES ASC
FETCH FIRST 1 ROW ONLY;

-- 3. Mostrar todos los usuarios que no tienen ninguna lista de reproducción.
SELECT U.CODIGO_USUARIO, U.NOMBRE || ' ' || U.APELLIDO AS NOMBRE_COMPLETO
FROM TBL_USUARIOS U
LEFT JOIN TBL_LISTAS_REPRODUCCION L ON U.CODIGO_USUARIO = L.CODIGO_USUARIO
WHERE L.CODIGO_LISTA_REPRODUCCION IS NULL;

-- 4.Mostrar todos los videos que tienen un canal, los que no tienen un canal y los canales que no tienen
-- videos.
-- Videos que tienen un canal
SELECT V.*
FROM TBL_VIDEOS V
JOIN TBL_CANALES C ON V.CODIGO_CANAL = C.CODIGO_CANAL;

-- Videos que no tienen un canal
SELECT V.*
FROM TBL_VIDEOS V
WHERE V.CODIGO_CANAL IS NULL;

-- Canales que no tienen videos
SELECT C.*
FROM TBL_CANALES C
LEFT JOIN TBL_VIDEOS V ON C.CODIGO_CANAL = V.CODIGO_CANAL
WHERE V.CODIGO_VIDEO IS NULL;

-- 5.Mostrar el histórico mensual de pagos a usuarios con el siguiente detalle:
-- a. Año-Mes
-- b. Monto total
-- c. Total Impuestos
-- d. Total Descuentos
-- e. Total neto
-- f. Cantidad de usuarios distintos
-- g. Cantidad de videos distintos
SELECT 
    TO_CHAR(P.FECHA_TRANSACCION, 'YYYY-MM') AS "Año-Mes",
    SUM(P.MONTO) AS "Monto total",
    SUM(P.IMPUESTOS) AS "Total Impuestos",
    SUM(P.DESCUENTOS) AS "Total Descuentos",
    SUM(P.MONTO) - SUM(P.IMPUESTOS) - SUM(P.DESCUENTOS) AS "Total neto",
    COUNT(DISTINCT P.CODIGO_USUARIO) AS "Cantidad de usuarios distintos",
    COUNT(DISTINCT V.CODIGO_VIDEO) AS "Cantidad de videos distintos"
FROM 
    TBL_TRANSACCIONES_PAGOS P
    JOIN TBL_VIDEOS V ON P.CODIGO_USUARIO = V.CODIGO_USUARIO
GROUP BY 
    TO_CHAR(P.FECHA_TRANSACCION, 'YYYY-MM')
ORDER BY 
    TO_CHAR(P.FECHA_TRANSACCION, 'YYYY-MM');

-- 6. Mostrar los videos con la siguiente información:
-- a. Nombre Video
-- b. Resolución
-- c. Nombre completo del usuario
-- d. Nombre de usuario
-- e. Estado del video
-- f. Idioma
-- g. Canal al que pertenece
-- h. Duración en minutos
-- i. Fecha de subida en formato DD#MM#YYYY Horas:Minutos:Segundos
-- j. URL
-- k. Cantidad de Likes (no usar el campo CANTIDAD_LIKES obtenerlo de la tabla de likes)
-- l. Cantidad de Dislikes (no usar el campo CANTIDAD_DISLIKES obtenerlo de la tabla de likes)
-- m. Cantidad de visualizaciones (no usar el campo CANTIDAD_VISUALIZACIONES utilizar la tabla de
-- historial)
-- n. Cantidad de Shares (no usar el campo CANTIDAD_SHARES utilizar la tabla de shares)
-- o. Cantidad de listas en las que ha sido incluido.
SELECT 
    V.NOMBRE_VIDEO,
    V.RESOLUCION,
    U.NOMBRE || ' ' || U.APELLIDO AS NOMBRE_COMPLETO,
    U.USUARIO AS NOMBRE_USUARIO,
    EV.NOMBRE_ESTADO_VIDEO AS ESTADO_VIDEO,
    I.NOMBRE_IDIOMA AS IDIOMA,
    C.NOMBRE_CANAL,
    V.DURACION_SEGUNDOS / 60 AS DURACION_MINUTOS,
    TO_CHAR(V.FECHA_SUBIDA, 'DD#MM#YYYY HH24:MI:SS') AS FECHA_SUBIDA,
    V.URL,
    (SELECT COUNT(*) FROM TBL_LIKES L WHERE L.CODIGO_VIDEO = V.CODIGO_VIDEO AND L.CODIGO_TIPO_LIKE = 1) AS CANTIDAD_LIKES,
    (SELECT COUNT(*) FROM TBL_LIKES L WHERE L.CODIGO_VIDEO = V.CODIGO_VIDEO AND L.CODIGO_TIPO_LIKE = 2) AS CANTIDAD_DISLIKES,
    (SELECT COUNT(*) FROM TBL_HISTORIAL_VIDEOS H WHERE H.CODIGO_VIDEO = V.CODIGO_VIDEO) AS CANTIDAD_VISUALIZACIONES,
    (SELECT COUNT(*) FROM TBL_SHARES S WHERE S.CODIGO_VIDEO = V.CODIGO_VIDEO) AS CANTIDAD_SHARES,
    (SELECT COUNT(*) FROM TBL_VIDEOS_X_LISTA VL WHERE VL.CODIGO_VIDEO = V.CODIGO_VIDEO) AS CANTIDAD_LISTAS
FROM 
    TBL_VIDEOS V
    JOIN TBL_USUARIOS U ON V.CODIGO_USUARIO = U.CODIGO_USUARIO
    JOIN TBL_ESTADOS_VIDEOS EV ON V.CODIGO_ESTADO_VIDEO = EV.CODIGO_ESTADO_VIDEO
    JOIN TBL_IDIOMAS I ON V.CODIGO_IDIOMA = I.CODIGO_IDIOMA
    JOIN TBL_CANALES C ON V.CODIGO_CANAL = C.CODIGO_CANAL;

-- 7. Crear una vista materializada de la consulta del inciso anterior, deje planteada la instrucción para
-- actualizar una vista materializada.
CREATE MATERIALIZED VIEW vista_videos AS
SELECT 
    V.NOMBRE_VIDEO,
    V.RESOLUCION,
    U.NOMBRE || ' ' || U.APELLIDO AS NOMBRE_COMPLETO,
    U.USUARIO AS NOMBRE_USUARIO,
    EV.NOMBRE_ESTADO_VIDEO AS ESTADO_VIDEO,
    I.NOMBRE_IDIOMA AS IDIOMA,
    C.NOMBRE_CANAL,
    V.DURACION_SEGUNDOS / 60 AS DURACION_MINUTOS,
    TO_CHAR(V.FECHA_SUBIDA, 'DD#MM#YYYY HH24:MI:SS') AS FECHA_SUBIDA,
    V.URL,
    (SELECT COUNT(*) FROM TBL_LIKES L WHERE L.CODIGO_VIDEO = V.CODIGO_VIDEO AND L.CODIGO_TIPO_LIKE = 1) AS CANTIDAD_LIKES,
    (SELECT COUNT(*) FROM TBL_LIKES L WHERE L.CODIGO_VIDEO = V.CODIGO_VIDEO AND L.CODIGO_TIPO_LIKE = 2) AS CANTIDAD_DISLIKES,
    (SELECT COUNT(*) FROM TBL_HISTORIAL_VIDEOS H WHERE H.CODIGO_VIDEO = V.CODIGO_VIDEO) AS CANTIDAD_VISUALIZACIONES,
    (SELECT COUNT(*) FROM TBL_SHARES S WHERE S.CODIGO_VIDEO = V.CODIGO_VIDEO) AS CANTIDAD_SHARES,
    (SELECT COUNT(*) FROM TBL_VIDEOS_X_LISTA VL WHERE VL.CODIGO_VIDEO = V.CODIGO_VIDEO) AS CANTIDAD_LISTAS
FROM 
    TBL_VIDEOS V
    JOIN TBL_USUARIOS U ON V.CODIGO_USUARIO = U.CODIGO_USUARIO
    JOIN TBL_ESTADOS_VIDEOS EV ON V.CODIGO_ESTADO_VIDEO = EV.CODIGO_ESTADO_VIDEO
    JOIN TBL_IDIOMAS I ON V.CODIGO_IDIOMA = I.CODIGO_IDIOMA
    JOIN TBL_CANALES C ON V.CODIGO_CANAL = C.CODIGO_CANAL;

-- Actualizar vista materializada
    REFRESH MATERIALIZED VIEW vista_videos;