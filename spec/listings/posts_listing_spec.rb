RSpec.describe PostsListing, type: :listing do
  describe "List entities" do
    before(:each) do
      create(:post)
      create(:post)
      create(:post)
    end

    let(:listing) { query_listing :posts }

    it "should list all" do
      expect(listing.items.count).to eq(3)
    end
  end
end
