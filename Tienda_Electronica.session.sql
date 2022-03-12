
---- Se debe crear el modelo en la base de datos, en una base de datos llamada
----tienda_de_electronica e insertar los siguientes registros:

CREATE DATABASE tienda_de_electronica;

---- 1. 3 clientes.

CREATE TABLE cliente (
id SERIAL UNIQUE PRIMARY KEY,
nombre VARCHAR (50),
rut VARCHAR (12),
direccion VARCHAR(50)
);


---- AGREGANDO REGISTRO TRES CLIENTES

INSERT INTO cliente (nombre,rut,direccion)
VALUES 
('Jocelyn','22.465.748-7','direccion 1'),
('Diego','20.785.123-4','direccion 3'),
('Ignacia','26.852.741-3','direccion 2');
 

---- 2. 2 categorías.

CREATE TABLE categoria (
id SERIAL UNIQUE PRIMARY KEY,
nombre VARCHAR (50),
direccion VARCHAR (50)
);

INSERT INTO categoria (nombre, descripcion)
VALUES 
('Computadoras','descripcion categoria 1'),
('Audio y Video','descripcion categoria 2');



---- 3. 5 productos.

CREATE TABLE producto(
id SERIAL UNIQUE PRIMARY KEY,
nombre VARCHAR(50),
descripcion VARCHAR (50),
valor FLOAT,
stock INT CHECK (stock >= 0) ,
id_categoria INT,
FOREIGN KEY (id_categoria) REFERENCES categoria (id)
);

INSERT INTO producto (nombre, descripcion, valor, stock, id_categoria)
VALUES
('Mouse', 'descripcion categoria 1',15,10,1),
('Teclado','descripcion categoria 2',30,10,1),
('Monitor','descripcion categoria 3',80,10,1),
('Audifonos','descripcion categoria 4',50,10,2),
('Cable HDMI','descripcion categoria 5',10,10,2);


---- 4. 3 facturas.


CREATE TABLE factura(
id SERIAL UNIQUE PRIMARY KEY,
fecha DATE,
subtotal FLOAT,
id_cliente INT,
FOREIGN KEY (id_cliente) REFERENCES cliente (id)
);

-- TABLA INTERMEDIA

CREATE TABLE producto_factura(
id_producto INT,
id_factura INT,
cantidad INT,
FOREIGN KEY (id_producto) REFERENCES producto (id),
FOREIGN KEY (id_factura) REFERENCES factura (id)
);




---- ● 1 para el cliente 1, con 3 productos diferentes
-- -----//haciendo la factura para cliente id=1 con 3 productos
---- // En caso de tener problema con la id factura, especificar la id
BEGIN;

INSERT INTO factura (id_cliente, fecha) VALUES (1, '2020-07-28');

-- ---- Agegando los 3 productos
INSERT INTO producto_factura (id_producto, id_factura, cantidad) VALUES (1,1,1);
INSERT INTO producto_factura (id_producto, id_factura, cantidad) VALUES (2,1,3);
INSERT INTO producto_factura (id_producto, id_factura, cantidad) VALUES (3,1,2);

UPDATE factura SET subtotal = 265 WHERE id= 1;
UPDATE producto SET stock = stock - 1 WHERE id = 1;
UPDATE producto SET stock = stock - 3 WHERE id = 2;
UPDATE producto SET stock = stock - 2 WHERE id = 3;

COMMIT;


---- ● 1 para el cliente 2, con 2 productos diferentes

BEGIN;
INSERT INTO factura (id_cliente,fecha) VALUES (2,'2020-11-04');
INSERT INTO producto_factura (id_producto, id_factura, cantidad) VALUES (4,2,1);
INSERT INTO producto_factura (id_producto, id_factura, cantidad) VALUES (5,2,1);

UPDATE factura SET subtotal = 60 WHERE id=2;
UPDATE producto SET stock = stock - 1 WHERE id=4;
UPDATE producto SET stock = stock - 1 WHERE id=5;
COMMIT;




---- ● 1 para el cliente 3, con 1 solo producto

BEGIN;

INSERT INTO factura (id,id_cliente,fecha) VALUES (3,3,'2020-11-04');
INSERT INTO producto_factura (id_producto,id_factura,cantidad) VALUES(5,3,8);

UPDATE factura SET subtotal = 80 WHERE id=3;
UPDATE producto SET stock = stock - 8 WHERE id=5;

COMMIT;



---- Realizar las siguientes consultas:


---- 5. ¿Cuál es el nombre del cliente que realizó la compra más cara?
----//CONSULTA VIDEO
SELECT nombre FROM cliente
WHERE id IN (
  SELECT id_cliente FROM factura 
  ORDER by subtotal DESC
  LIMIT 1
);

----  nombre
---- ---------
----  Jocelyn
---- (1 row)

----//MI CONSULTA
SELECT cliente.nombre, MAX(subtotal) as compra_mas_cara
FROM cliente, factura
WHERE cliente.id=factura.id
GROUP BY cliente.nombre
ORDER BY compra_mas_cara DESC
LIMIT 1
 ;

----  nombre  | compra_mas_cara
---- ---------+-----------------
----  Jocelyn |             265
---- (1 row)


---- 6. ¿Cuáles son los nombres de los clientes que pagaron más de 60$? Considere un IVA
---- del 19%
----//CONSULTA VIDEO

SELECT nombre FROM cliente
WHERE id  IN ( 
SELECT id_cliente FROM factura
WHERE subtotal > 60*1.19
);

----  nombre
---- ---------
----  Jocelyn
----  Ignacia
---- (2 rows)


----//MI CONSULTA
SELECT cliente.nombre, factura.subtotal FROM cliente, factura
WHERE cliente.id=factura.id AND subtotal > (60*1.19);

----  nombre  | subtotal
---- ---------+----------
----  Jocelyn |      265
----  Ignacia |       80
---- (2 rows)




---- 7. ¿Cuántos clientes han comprado más de 5 productos? Considere la cantidad por
---- producto comprado

SELECT COUNT(nombre) FROM cliente
WHERE id IN (
              SELECT id_cliente FROM factura
                  WHERE id IN (
                      SELECT id_factura FROM 
                        (SELECT SUM(cantidad) AS cantidad_producto, id_factura FROM producto_factura
                        GROUP BY id_factura  ) AS cant_prod_table
                        WHERE cantidad_producto > 5
   )
);

----  count
---------
  ----   2
----(1 row)
