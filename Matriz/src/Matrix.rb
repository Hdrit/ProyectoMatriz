require 'oci8' 
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