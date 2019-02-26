/**
Especificacion del paquete que maneja el laberinto
*/
CREATE OR REPLACE PACKAGE laberinto AS
--Definicion del tipo matriz
  TYPE coordenate IS
    TABLE OF NUMBER(1) INDEX BY BINARY_INTEGER;
  TYPE matrix IS
    TABLE OF coordenate INDEX BY BINARY_INTEGER;
--Constantes de coordenadas
  y_index NUMBER := 1;
  x_index NUMBER := 2;
--Halla el camino de a la salida. No camino if null. 
  FUNCTION hallar_camino (
    coordenada_inicio   IN coordenate,
    matriz              IN matrix
  ) RETURN matrix;

/* --private
Revisa la matriz
1) Solo haya una salida.
) La matriz debe ser NxN.
3) La entrada debe estar en 1.
4) La salida esté en alguno de los bordes.

*/

END laberinto;
/

/**
Test package
*/


/**
Adapter package.
OCI es incapaz de enviar colecciones tipo TABLE, por lo que la informacion para ruby
debe convertirse en un CLOB de formato JSON. 
*/

--Zona de cuerpos

/**
Cuerpo del paquete laberinto.
*/

CREATE OR REPLACE PACKAGE BODY laberinto AS
  --Funcion privada norte, sur, este y oeste

  FUNCTION norte (
    coordenada IN coordenate
  ) RETURN coordenate AS
    nueva_coordenada   coordenate;
  BEGIN
    nueva_coordenada(y_index) := coordenada(y_index) - 1;
    nueva_coordenada(x_index) := coordenada(x_index);
    RETURN nueva_coordenada;
  END norte;

  FUNCTION sur (
    coordenada IN coordenate
  ) RETURN coordenate AS
    nueva_coordenada   coordenate;
  BEGIN
    nueva_coordenada(y_index) := coordenada(y_index) + 1;
    nueva_coordenada(x_index) := coordenada(x_index);
    RETURN nueva_coordenada;
  END sur;

  FUNCTION este (
    coordenada IN coordenate
  ) RETURN coordenate AS
    nueva_coordenada   coordenate;
  BEGIN
    nueva_coordenada(y_index) := coordenada(y_index);
    nueva_coordenada(x_index) := coordenada(x_index + 1);
    RETURN nueva_coordenada;
  END este;

  FUNCTION oeste (
    coordenada IN coordenate
  ) RETURN coordenate AS
    nueva_coordenada   coordenate;
  BEGIN
    nueva_coordenada(y_index) := coordenada(y_index);
    nueva_coordenada(x_index) := coordenada(x_index) - 1;
    RETURN nueva_coordenada;
  END oeste;

  FUNCTION camino_recursivo (
    coordenada   IN coordenate,
    matriz       IN matrix
  ) RETURN matrix AS
    camino   matrix;
  BEGIN
  --1.	if (x,y fuera del laberinto) return false 
    IF ( coordenada(y_index) <= 0 OR coordenada(x_index) <= 0 OR coordenada(y_index) > matriz.count OR coordenada(x_index) > matriz
    (coordenada(y_index) ).count ) THEN
      RETURN camino;
    END IF;
  --2.	if (x,y es estado final) return true

    IF ( matriz(coordenada(y_index) ) (coordenada(x_index) ) = 5 ) THEN
      camino(1) := coordenada;
      RETURN camino;
    END IF;
  --3.	if (x,y no es abierto) return false 

    IF ( matriz(coordenada(y_index) ) (coordenada(x_index) ) = 0 ) THEN
      RETURN camino;
    END IF;

    camino := camino_recursivo(norte(coordenada),matriz);
    IF ( camino.count != 0 ) THEN
      camino(camino.last + 1) := coordenada;
      RETURN camino;
    END IF;

    camino := camino_recursivo(este(coordenada),matriz);
    IF ( camino.count != 0 ) THEN
      camino(camino.last + 1) := coordenada;
      RETURN camino;
    END IF;

    camino := camino_recursivo(sur(coordenada),matriz);
    IF ( camino.count != 0 ) THEN
      camino(camino.last + 1) := coordenada;
      RETURN camino;
    END IF;

    camino := camino_recursivo(oeste(coordenada),matriz);
    IF ( camino.count != 0 ) THEN
      camino(camino.last + 1) := coordenada;
      RETURN camino;
    ELSE
      camino.DELETE;
      RETURN camino;
    END IF;

  END camino_recursivo;

  --declaracion de la funcion Hallar_camino

  FUNCTION hallar_camino (
    coordenada_inicio   IN coordenate,
    matriz              IN matrix
  ) RETURN matrix AS
  BEGIN
  --Retorna el camino en reversa
    RETURN camino_recursivo(coordenada_inicio,matriz);
  END hallar_camino;

END laberinto;
/

SHOW ERRORS;