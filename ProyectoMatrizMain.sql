set serveroutput on;
BEGIN
  laberinto.matriz := testlab.matriz_estatica;
  testlab.imprimir_matriz(laberinto.hallar_camino(1,1));
END;