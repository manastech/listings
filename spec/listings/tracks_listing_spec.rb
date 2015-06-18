RSpec.describe TracksListing, type: :listing do
  describe "List entities" do
    let!(:track) { create(:album, tracks_count: 1) }

    let(:listing) { query_listing :tracks }

    it "should list all" do
      expect(listing.items.count).to eq(1)
    end

    it "can be rendered" do
      render_listing :tracks
    end

    it "should get name from model" do
      expect(listing.column_with_key('album_name').human_name).to eq('Album Name')
    end

    it "should get name from title option for column" do
      expect(listing.column_with_key('album_id').human_name).to eq('The Album Id')
    end

    it "should get name from title option for filter" do
      expect(listing.filter_with_key('album_id').human_name).to eq('The Album Id')
    end
  end
end
