/**
Test package
*/
CREATE OR REPLACE PACKAGE testlab AS
  PROCEDURE imprimir_matriz (
    matriz matrix
  );

  FUNCTION matriz_estatica RETURN matrix;

END testlab;
/

--Declaraci�n paquete pruebas

CREATE OR REPLACE PACKAGE BODY testlab AS

  PROCEDURE imprimir_matriz (
    matriz matrix
  ) AS
    index_m   NUMBER;
    index_c   NUMBER;
    linea     VARCHAR(50);
  BEGIN
    index_m := matriz.first;
    WHILE ( index_m IS NOT NULL ) LOOP
      index_c := matriz(index_m).first;
      WHILE ( index_c IS NOT NULL ) LOOP
        linea := linea||matriz(index_m)(index_c)|| ' ';
        index_c := matriz(index_m).next(index_c);
      END LOOP;

      dbms_output.put_line(linea);
      linea := '';
      index_m := matriz.next(index_m);
    END LOOP;

  END imprimir_matriz;


  FUNCTION matriz_estatica RETURN matrix AS
    m matrix := matrix(coordenate(1,1,1,1,1), 
                coordenate(1,1,1,1,1),
                coordenate(1,1,1,1,1),
                coordenate(1,1,1,1,1),
                coordenate(1,1,1,1,5));
  BEGIN    
    return m;
  END matriz_estatica;

END testlab;
/