class ObjectAlbum
  attr_accessor :name
  attr_accessor :tracks

  def to_h
    { name: name }
  end
end
