--Definicion del tipo matriz
/*create or replace type coordenate AS TABLE OF NUMBER;
/
create or replace type matrix is table of coordenate;
/*/
/**
Especificacion del paquete que maneja el laberinto
*/
CREATE OR REPLACE PACKAGE laberinto AS

--Constantes de coordenadas
  y_index NUMBER := 1;
  x_index NUMBER := 2;
  
--Variable global matrix
  matriz matrix;
  
--Halla el camino de a la salida. No camino if empty. 
  FUNCTION hallar_camino (
    x in number,
    y in number
  ) RETURN matrix;

/*
FUNCTION generar_matriz(
n in number,
xf in number,
yf in number
) return matrix;
*/

/*
PROCEDURE set_matriz(
nueva_matriz matrix
);
*/
/* --private
Revisa la matriz
1) Solo haya una salida.
) La matriz debe ser NxN.
3) La entrada debe estar en 1.
4) La salida esté en alguno de los bordes.

PROCEUDRE revisar_matriz();
*/

END laberinto;
/

--Zona de cuerpos

/**
Cuerpo del paquete laberinto.
*/

CREATE OR REPLACE PACKAGE BODY laberinto AS
/**
Definiciones privadas
*/

--Definicion de las funciones norte, sur, este y oeste

  FUNCTION norte (
    coordenada IN coordenate
  ) RETURN coordenate AS
    nueva_coordenada   coordenate := coordenate(0,0);
  BEGIN
    nueva_coordenada(y_index) := coordenada(y_index) - 1;
    nueva_coordenada(x_index) := coordenada(x_index);
    RETURN nueva_coordenada;
  END norte;

  FUNCTION sur (
    coordenada IN coordenate
  ) RETURN coordenate AS
    nueva_coordenada   coordenate := coordenate(0,0);
  BEGIN
    nueva_coordenada(y_index) := coordenada(y_index) + 1;
    nueva_coordenada(x_index) := coordenada(x_index);
    RETURN nueva_coordenada;
  END sur;

  FUNCTION este (
    coordenada IN coordenate
  ) RETURN coordenate AS
    nueva_coordenada   coordenate := coordenate(0,0);
  BEGIN
    nueva_coordenada(y_index) := coordenada(y_index);
    nueva_coordenada(x_index) := coordenada(x_index) + 1;
    RETURN nueva_coordenada;
  END este;

  FUNCTION oeste (
    coordenada IN coordenate
  ) RETURN coordenate AS
    nueva_coordenada   coordenate := coordenate(0,0);
  BEGIN
    nueva_coordenada(y_index) := coordenada(y_index);
    nueva_coordenada(x_index) := coordenada(x_index) - 1;
    RETURN nueva_coordenada;
  END oeste;

--Definición de la funcion recursiva
  FUNCTION camino_recursivo (
    coordenada   IN coordenate
  ) RETURN matrix AS
    camino   matrix := matrix();
  BEGIN
  --1.	if (x,y fuera del laberinto) return false 
    IF ( coordenada(y_index) <= 0 
    OR coordenada(x_index) <= 0 
    OR coordenada(y_index) > matriz.count 
    OR coordenada(x_index) > matriz.count )
    THEN
      RETURN camino;
    END IF;
  --2.	if (x,y es estado final) return true

    IF ( matriz(coordenada(y_index) ) (coordenada(x_index) ) = 5 ) THEN
      camino.extend;
      camino(1) := coordenada;
      RETURN camino;
    END IF;
  --3.	if (x,y no es abierto) return false 

    IF ( matriz(coordenada(y_index) ) (coordenada(x_index) ) = 0 ) THEN
      RETURN camino;
    END IF;
    camino := camino_recursivo(norte(coordenada));
    IF ( camino.count != 0 ) THEN
      dbms_output.put_line('norte...');
      camino.extend;
      camino(camino.last) := coordenada;
      RETURN camino;
    END IF;    
    camino := camino_recursivo(este(coordenada));
    IF ( camino.count != 0 ) THEN
      dbms_output.put_line('este...');
      camino.extend;
      camino(camino.last) := coordenada;
      RETURN camino;
    END IF;    
    camino := camino_recursivo(sur(coordenada));
    IF ( camino.count != 0 ) THEN
      dbms_output.put_line('sur...');
      camino.extend;
      camino(camino.last) := coordenada;
      RETURN camino;
    END IF;    
    camino := camino_recursivo(oeste(coordenada));
    IF ( camino.count != 0 ) THEN
      dbms_output.put_line('oeste...');
      camino.extend;
      camino(camino.last) := coordenada;
      RETURN camino;
    ELSE
      camino.DELETE;
      RETURN camino;
    END IF;

  END camino_recursivo;

/**
Definiciones públicas
*/

  --declaracion de la funcion Hallar_camino
  FUNCTION hallar_camino (
    x in number,
    y in number
  ) RETURN matrix AS
    coordenada_inicio coordenate := coordenate(0,0);
  BEGIN
    coordenada_inicio(x_index) := x;
    coordenada_inicio(y_index) := y;
  --Retorna el camino en reversa. FIXMEFIXME    
    RETURN camino_recursivo(coordenada_inicio);
  END hallar_camino;

END laberinto;
/
SHOW ERRORS;