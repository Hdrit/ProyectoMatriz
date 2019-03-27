
class VentanaLaberinto
 
  include GladeGUI
  require 'oci8'  
  def before_show()
    @conn = OCI8.new('system/pass')  
    @pared = "src/rsc/pared.png"
    @recorrido = "src/rsc/recorrido.png"
    @camino = "src/rsc/camino.png"
    @salida = ""    
  end  

  def button1__clicked(*args)
    
  end

  def button3__clicked(*args)
    cargar_archivo("C:/Users/Admin/Documents/lab.txt")
    pintar_matriz(matriz)
  end

  def button2__clicked(*args)
    xi =  @builder["spinbutton1"].value.to_i
    yi =  @builder["spinbutton4"].value.to_i
    hallar_camino(xi,yi)
    @builder["label11"].label = ejecucion.to_s + " segundos" 
    pintar_matriz(matriz)
  end

  def inflate_table   
    tabla = @builder['table1']
    tamano = @builder['spinbutton5'].value.to_i
    tabla.each do |child|
      tabla.remove(child)
    end
    tabla.resize( tamano, tamano)    
    tamano.times do |i|
      tamano.times do |j|
        label = Gtk::Image.new(file: @camino)
        label.set_visible true
        tabla.attach_defaults(label, i, i+1, j, j+1)
      end
    end
  end

  def pintar_matriz(matriz_i)
    tabla = @builder['table1']
    tabla.each do |child|
      tabla.remove(child)
    end
    tabla.resize( matriz_i.size, matriz_i.size)
    @builder['spinbutton5'].value= matriz_i.size
    matriz_i.each_with_index do |a, i|
      a.each_with_index do |v, j|
        label = Gtk::Image.new(file: to_ima(v))
        label.set_visible true
        tabla.attach_defaults(label, j, j+1, i, i+1)
      end
    end
  end

  def to_ima( value)
    case value
    when 1
      @camino
    when 2
      @recorrido
    when 0
      @pared
    when 5
      @salida
    end
  end

#
# Thou Shall not pass this border
   
  
  #
  # Obtiene la matriz guardada en el paquete laberinto  
  def matriz
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
  # OJO: Llamar esta funcion modifica la matriz que se le envi├ö├Â┬ú├ö├Â├® al paquete
  def hallar_camino( xi, yi )
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
    cursor = @conn.parse("declare mat matrix := matrix(#{a.join(',')}); begin laberinto.set_matriz(mat); end;") 
    cursor.exec
  end
end

class Matrix < OCI8::Object::Base
  
  def to_ary_ary
    a = []
    self.to_ary.each do |i|
      a << i.to_ary
    end
    a
  end
end

class Coordenate < OCI8::Object::Base
end
