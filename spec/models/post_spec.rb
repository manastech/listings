RSpec.describe Post, type: :model do
  describe "Create" do
    it "can be created" do
      create(:post)
      expect(Post.count).to eq(1)
    end
  end
end
