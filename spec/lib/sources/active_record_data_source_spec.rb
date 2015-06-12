include Listings::Sources

RSpec.describe ActiveRecordDataSource do

  before(:each) { create_list(:post, 40) }

  shared_examples "activerecord datasource with all item" do
    describe "DataSource factory" do
      it "should create from with class name" do
        expect(ds).to be_a ActiveRecordDataSource
      end
    end

    describe "items" do

      it "should return all items" do
        expect(ds.items.count).to be(40)
      end
    end
  end

  context "using class" do
    let(:ds) { DataSource.for(Post) }
    it_behaves_like "activerecord datasource with all item"
  end

  context "using relation" do
    let(:ds) { DataSource.for(Post.all) }
    it_behaves_like "activerecord datasource with all item"
  end

end
