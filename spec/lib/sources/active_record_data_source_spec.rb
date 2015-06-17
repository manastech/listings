include Listings::Sources

RSpec.describe ActiveRecordDataSource do

  def show_query(ds)
    # with_active_record_logging do
      ds.items.to_a
    # end
  end

  def with_active_record_logging
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    puts
    yield
    ActiveRecord::Base.logger = nil
  end

  context "simple active record model" do
    TOTAL_COUNT = 40

    let!(:posts) { create_list(:post, TOTAL_COUNT) }
    let(:title) { ds.build_field :title }
    let(:author) { ds.build_field :author }

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

      describe "scope" do
        before(:each) do
          ds.scope do |items|
            items.even
          end
        end

        it "should return scoped items" do
          expect(ds.items.count).to be(TOTAL_COUNT / 2)
        end
      end

      describe "search" do
        before(:each) do
          create_list(:post, 10, title: 'title-magic-string')
          create_list(:post, 10, author: 'author-magic-string')

          ds.search([title, author], 'magic')
        end

        it "should return matching items" do
          expect(ds.items.count).to be(20)
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
    let!(:albums) { create_list(:album, 6) }
    let!(:ds) { DataSource.for(Track) }
    let!(:track_title) { ds.build_field :title }

    shared_examples "listing with projected values" do
      it "should project attribute value" do
        expect(album_name.value_for(ds.items.first)).to eq(Track.first.album.name)
      end

      it "should perform a eager_load" do
        show_query ds
      end

      it "should perform a single query" do
        expect(ActiveRecord::Base.count_queries do
          album_name.value_for(ds.items.first)
          album_id.value_for(ds.items.first)
        end).to eq(1)
      end

      describe "scope" do
        before(:each) do
          ds.scope do |items|
            items.even
          end
        end

        it "should return scoped items" do
          expect(ds.items.count).to be(Track.count / 2)
        end
      end

      describe "search" do
        before(:each) do
          create(:album, tracks_count: 5, name: 'album-name-magic-string-1')
          create(:album, tracks_count: 5, name: 'album-name-magic-string-2')
          create_list(:album, 2).each do |album_with_tracks_to_match|
            create_list(:track, 5, title: 'title-magic-string', album: album_with_tracks_to_match)
          end

          ds.search([track_title, album_name], 'magic')
        end

        it "should return matching items" do
          show_query ds
          expect(ds.items.count).to be(20)
        end
      end
    end

    context "using array as path" do
      let!(:album_name) { ds.build_field [:album, :name] }
      let!(:album_id) { ds.build_field [:album, :id] }

      it_behaves_like "listing with projected values"
    end

    context "hash as path" do
      let!(:album_name) { ds.build_field album: :name }
      let!(:album_id) { ds.build_field album: :id }

      it_behaves_like "listing with projected values"
    end
  end
end
