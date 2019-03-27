#
# Clase que conecta el laberinto de la base de datos
# con el laberinto que maneja ruby
class Laberinto
  require 'oci8'  
  
  #
  # Constructor. Inicializa la coneccion con la base de datos
  def initialize
       @conn = OCI8.new('system/pass')
  end   
  
  #
  # Obtiene la matriz guardada en el paquete laberinto  
  def matriz
    require 'Matrix'
    cursor = @conn.parse('begin :in := laberinto.matriz; end;')
    cursor.bind_param(':in', nil, Matrix)
    cursor.exec
    cursor[':in'].to_ary_ary
  end
  
  #
  # Obtiene el tiempo (en segundos) de la ultima ejecucion de hallar_camino
  def ejecucion
    cursor = @conn.parse('begin :in := laberinto.ejecucion; end;')
    cursor.bind_param(':in', nil, OraNumber)
    cursor.exec
    cursor[':in']    
  end
  
  #
  # Halla el camino de los puntos dados a la salida marcada con 5
  # OJO: Llamar esta funcion modifica la matriz que se le enviÔö£Ôöé al paquete
  def hallar_camino( xi, yi )
    require 'Matrix'
    cursor = @conn.parse('begin :in := laberinto.hallar_camino(:xi, :yi); end;') 
    cursor.bind_param(':in', nil, Matrix)
    cursor.bind_param(':xi', xi)
    cursor.bind_param(':yi', yi)
    cursor.exec
    cursor[':in'].to_ary_ary   
  end
  
  #
  # Esta funcion utiliza la matriz estatica del paquete de pruebas
  def matriz_estatica
    cursor = @conn.parse('begin laberinto.set_matriz(testlab.matriz_estatica); end;')
    cursor.exec
  end
  
  #
  #
  def cargar_archivo(path)
    a = []
    File.open(path, "r") do |f|
      f.each_line do |line|
        a << "coordenate(#{line.chomp})"
      end
    end
    puts a.join(',')
    cursor = @conn.parse("declare mat matrix := matrix(#{a.join(',')}); begin laberinto.set_matriz(mat); end;") 
    cursor.exec
  end
end
