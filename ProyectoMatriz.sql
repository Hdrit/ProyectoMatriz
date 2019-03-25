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
  
--Tiempo de ejecucion
  ejecucion NUMBER;
--Variable global matrix
  matriz matrix;
  
--Halla el camino de a la salida. No camino if empty. 
  FUNCTION hallar_camino (
    x   IN NUMBER,
    y   IN NUMBER
  ) RETURN matrix;

/*
FUNCTION generar_matriz(
n in number,
xf in number,
yf in number
) return matrix;
*/

  PROCEDURE set_matriz (
    nueva_matriz matrix
  );

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
--Variable de conteo de tiempo

  timestart   TIMESTAMP;
  
  --Funcion privada empezar. Inicializa el conteo del tiempo

  PROCEDURE empezar AS
  BEGIN
    timestart := systimestamp;
  END empezar;
  
  --Funcion privada terminar. Muestra el tiempo transcurrido entre la ultima llamada a empezar.

  PROCEDURE terminar AS
    timeend      TIMESTAMP;
    timesecond   NUMBER;
  BEGIN
    timeend := systimestamp;
    timesecond := ( ( extract ( HOUR FROM timeend ) * 3600 ) + ( extract ( MINUTE FROM timeend ) * 60 ) + extract ( SECOND FROM timeend
    ) ) - ( ( extract ( HOUR FROM timestart ) * 3600 ) + ( extract ( MINUTE FROM timestart ) * 60 ) + extract ( SECOND FROM timestart
    ) );

    ejecucion := timesecond;
  END terminar;
  
  FUNCTION ubicar_salida 
  RETURN COORDENATE as
    salida coordenate;
    index_m number;
    index_c number;
  BEGIN
    index_m := matriz.first;
    while(index_m is not null) loop
      index_c := matriz(index_m).first;
      while(index_c is not null) loop
        IF(matriz(index_m)(index_c) = 5) then
          if(salida is not null) then
            raise_application_error(-20003,'Multiples salidas encontradas');
          end if;
          salida := coordenate(index_m, index_c );
        end if;
        index_c := matriz(index_m).next(index_c);
      end loop;
      index_m := matriz.next(index_m);
    end loop;
    RETURN SALIDA;
  END UBICAR_SALIDA;
  
  /* --private
Revisa la matriz
1) Solo haya una salida.
) La matriz debe ser NxN.
4) La salida esté en alguno de los bordes.
*/

  PROCEDURE revisar_matriz AS
  salida coordenate;
  BEGIN
    IF ( matriz IS NULL OR matriz.count = 0 OR matriz.count != matriz(1).count ) THEN
      raise_application_error(-20004,'Matriz con dimensiones inválidas');
    END IF;
    salida := ubicar_salida;
    IF (salida IS NULL) THEN
      raise_application_error(-20005,'Matriz carece de salida');
    ELSIF (salida(x_index) != 1 
      AND salida(y_index) != 1
      AND salida(x_index) != matriz.count
      AND salida(y_index) != matriz.count) THEN
      raise_application_error(-20006, 'La salida debe estar en uno de los bordes');
    END IF;    
  END revisar_matriz;

  
--Invierte un camino
  FUNCTION ordenar (
    matriz_al_revez matrix
  ) RETURN MATRIX AS
    index_m1 number;
    matriz_ordenada matrix := matrix();
  BEGIN
    index_m1 := matriz_al_revez.last;
    WHILE ( index_m1 IS NOT NULL ) LOOP
      matriz_ordenada.extend;
      matriz_ordenada(matriz_ordenada.last) := matriz_al_revez(index_m1);
      index_m1 := matriz_al_revez.prior(index_m1);
    END LOOP;
    return matriz_ordenada;
  END ORDENAR;


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

--Definición de la funcion recursiva. NOTA: ESTA FUNCION DESTRUYE LA MATRIZ PINTANDOLA DE 2.

  FUNCTION camino_recursivo (
    coordenada IN coordenate
  ) RETURN matrix AS
    camino   matrix := matrix ();
  BEGIN
  --1.	if (x,y fuera del laberinto) return false 
    IF ( coordenada(y_index) <= 0 OR coordenada(x_index) <= 0 OR coordenada(y_index) > matriz.count OR coordenada(x_index) > matriz
    .count ) THEN
      RETURN camino;
    END IF;
  --2.	if (x,y es estado final) return true

    IF ( matriz(coordenada(y_index) ) (coordenada(x_index) ) = 5 ) THEN
      camino.extend;
      camino(1) := coordenada;
      RETURN camino;
    END IF;
  --3.	if (x,y no es abierto) return false 

    IF ( matriz(coordenada(y_index) ) (coordenada(x_index) ) = 0 OR matriz(coordenada(y_index) ) (coordenada(x_index) ) = 2 ) THEN
      RETURN camino;
    END IF;

    matriz(coordenada(y_index) ) (coordenada(x_index) ) := 2;
    camino := camino_recursivo(norte(coordenada) );
    IF ( camino.count > 0 ) THEN
      camino.extend;
      camino(camino.last) := coordenada;
      RETURN camino;
    END IF;

    camino := camino_recursivo(este(coordenada) );
    IF ( camino.count > 0 ) THEN
      camino.extend;
      camino(camino.last) := coordenada;
      RETURN camino;
    END IF;

    camino := camino_recursivo(sur(coordenada) );
    IF ( camino.count > 0 ) THEN
      camino.extend;
      camino(camino.last) := coordenada;
      RETURN camino;
    END IF;

    camino := camino_recursivo(oeste(coordenada) );
    IF ( camino.count > 0 ) THEN
      camino.extend;
      camino(camino.last) := coordenada;
      RETURN camino;
    ELSE
      camino.DELETE;
      matriz(coordenada(y_index) ) (coordenada(x_index) ) := 1;
      RETURN camino;
    END IF;

  END camino_recursivo;

/**
Definiciones públicas
*/

  --declaracion de la funcion Hallar_camino
  --La entrada debe estar en 1.

  FUNCTION hallar_camino (
    x   IN NUMBER,
    y   IN NUMBER
  ) RETURN matrix AS
    coordenada_inicio   coordenate := coordenate(0,0);
    camino_al_revez matrix;
    camino_ordenado     matrix;
  BEGIN
    IF ( matriz(y) (x) != 1 ) THEN
      raise_application_error(-20001,'Coordenadas iniciales inválidas');
    END IF;

    empezar;
    coordenada_inicio(x_index) := x;
    coordenada_inicio(y_index) := y;  
    camino_al_revez := camino_recursivo(coordenada_inicio);
    IF (camino_al_revez is null or camino_al_revez.count = 0) then
      raise_application_error(-20002,'No fue posible solucionar laberinto');
    end if;
    camino_ordenado := ordenar(camino_al_revez);
    terminar;
    RETURN camino_ordenado;
  END hallar_camino;
  
  --declaracion de la funcion set_matriz

  PROCEDURE set_matriz (
    nueva_matriz matrix
  ) AS
  BEGIN
    matriz := nueva_matriz;
    revisar_matriz;
  END set_matriz;

END laberinto;
/

SHOW ERRORS;