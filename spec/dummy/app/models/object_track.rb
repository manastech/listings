class ObjectTrack
  attr_accessor :album
  attr_accessor :order, :title

  def to_h
    { title: title, album: album.try(&:to_h) }
  end
end
