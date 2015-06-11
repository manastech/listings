RSpec.describe Post, type: :model do
  describe "Factory" do
    it "can create" do
      create(:post)
      expect(Post.count).to eq(1)
    end
  end
end
