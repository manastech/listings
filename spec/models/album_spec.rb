RSpec.describe Album, type: :model do
  describe "Factory" do
    it "can create" do
      create(:album)
      expect(Album.count).to eq(1)
      expect(Album.first.tracks.count).to be > 1
    end
  end
end
