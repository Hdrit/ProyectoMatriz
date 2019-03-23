/**
Test package
*/
CREATE OR REPLACE PACKAGE TESTLAB AS
  PROCEDURE IMPRIMIR_MATRIZ(
    MATRIZ matrix
  );


END TESTLAB;
/

--Declaración paquete pruebas
CREATE OR REPLACE PACKAGE BODY TESTLAB AS
  PROCEDURE IMPRIMIR_MATRIZ(
    MATRIZ matrix
  ) AS
  index_m number;
  index_c number;
  linea varchar(50);
  BEGIN
  index_m := matriz.first;
  while(index_m is not null) loop
    index_c := matriz(index_m).first;
    while(index_c is not null) loop
      linea := linea||' '||matriz(index_m)(index_c); 
      index_c := matriz(index_m).next(index_c);
    end loop;
    dbms_output.put_line(linea);
    linea := ' ';
    index_m := matriz.next(index_m);
  end loop;
  END IMPRIMIR_MATRIZ;
END TESTLAB;
/
