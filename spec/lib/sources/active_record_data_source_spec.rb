include Listings::Sources

RSpec.describe ActiveRecordDataSource do

  TOTAL_COUNT = 40

  before(:each) { create_list(:post, TOTAL_COUNT) }

  shared_examples "activerecord datasource with all item" do
    describe "DataSource factory" do
      it "should create from with class name" do
        expect(ds).to be_a ActiveRecordDataSource
      end
    end

    describe "items" do
      it "should return all items" do
        expect(ds.items.count).to be(TOTAL_COUNT)
      end
    end

    describe "paginate" do
      PAGE_SIZE = 5

      before(:each) { ds.paginate(2, PAGE_SIZE) }

      it "should get only paged items" do
        expect(ds.items.count).to be(PAGE_SIZE)
      end

      it "should keep total_count" do
        expect(ds.items.total_count).to be(TOTAL_COUNT)
      end
    end
  end

  context "using class" do
    let(:ds) { DataSource.for(Post) }
    it_behaves_like "activerecord datasource with all item"
  end

  context "using relation" do
    let(:ds) { DataSource.for(Post.where('1 = 1')) }
    it_behaves_like "activerecord datasource with all item"
  end
end
