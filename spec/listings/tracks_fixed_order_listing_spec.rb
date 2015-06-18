RSpec.describe TracksFixedOrderListing, type: :listing do
  describe "List entities" do
    let!(:track) { create(:album, tracks_count: 1) }

    let(:listing) { query_listing :tracks_fixed_order }

    it "should list all" do
      expect(listing.items.count).to eq(1)
    end

    it "can be rendered" do
      render_listing :tracks
    end

    it "can't be sorted" do
      expect(listing).to_not be_sortable
    end
  end
end
