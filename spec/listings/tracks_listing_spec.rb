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
  end
end
