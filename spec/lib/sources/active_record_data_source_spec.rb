include Listings::Sources

RSpec.describe ActiveRecordDataSource do

  context "simple active record model" do
    TOTAL_COUNT = 40

    let!(:posts) { create_list(:post, TOTAL_COUNT) }
    let(:title) { ds.build_field :title }

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

      describe "field" do
        it "should project attribute value" do
          expect(title.value_for(ds.items.first)).to eq(posts.first.title)
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

  context "active record model with belongs_to" do
    let!(:albums) { create_list(:album, 5) }
    let(:ds) { DataSource.for(Track) }
    let!(:album_name) { ds.build_field [:album, :name] }
    let!(:album_id) { ds.build_field [:album, :id] }

    describe "field" do
      it "should project attribute value" do
        expect(album_name.value_for(ds.items.first)).to eq(Track.first.album.name)
      end

      it "should perform a single query" do
        expect(ActiveRecord::Base.count_queries do
          album_name.value_for(ds.items.first)
          album_name.value_for(ds.items.first)
        end).to eq(1)
      end
    end
  end
end
