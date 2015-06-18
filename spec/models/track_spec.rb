RSpec.describe Track, type: :model do
  describe "Factory" do
    it "can create" do
      create(:track)
      expect(Track.count).to eq(1)
    end
  end
end
