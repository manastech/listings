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
    let(:total_count) { 40 }

    let!(:posts) { create_list(:post, total_count) }
    let(:title) { ds.build_field :title }
    let(:author) { ds.build_field :author }

    shared_examples "project all authors" do
      it "should matching values" do
        expect(ds.values_for_filter(author)).to eq(['author1', 'author2', 'author3'])
      end
    end

    shared_examples "activerecord datasource with all item" do
      describe "DataSource factory" do
        it "should create from with class name" do
          expect(ds).to be_a ActiveRecordDataSource
        end
      end

      describe "items" do
        it "should return all items" do
          expect(ds.items.count).to be(total_count)
        end

        it "should enumerate all items" do
          expect(begin
            c = 0
            ds.items.each do
              c = c + 1
            end
            c
          end).to be(total_count)
        end
      end

      describe "paginate" do
        let(:page_size) { 5 }

        before(:each) { ds.paginate(2, page_size) }

        it "should get only paged items" do
          expect(ds.items.count).to be(page_size)
        end

        it "should keep total_count" do
          expect(ds.items.total_count).to be(total_count)
        end
      end

      describe "field" do
        it "should project attribute value" do
          expect(title.value_for(ds.items.first)).to eq(posts.first.title)
        end

        it "should have key" do
          expect(title.key).to eq('title')
        end
      end

      describe "scope" do
        before(:each) do
          ds.scope do |items|
            items.even
          end
        end

        it "should return scoped items" do
          expect(ds.items.count).to be(total_count / 2)
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

      describe "sort" do
        before(:each) do
          expect(posts.map(&:title)).to_not eq(posts.map(&:title).sort)
          ds.sort(title)
        end

        it "should return matching items" do
          expect(ds.items.map { |e| title.value_for(e) }).to eq(posts.map(&:title).sort)
        end
      end

      describe "sort desc" do
        before(:each) do
          expect(posts.map(&:title)).to_not eq(posts.map(&:title).sort.reverse)
          ds.sort(title, DataSource::DESC)
        end

        it "should return matching items" do
          expect(ds.items.map { |e| title.value_for(e) }).to eq(posts.map(&:title).sort.reverse)
        end
      end

      describe "filter" do
        before(:each) do
          create_list(:post, 10, author: 'author1')
          create_list(:post, 10, author: 'author2')

          ds.filter(author, 'author1')
        end

        it "should return matching items" do
          expect(ds.items.count).to be(10)
        end
      end

      describe "values_for_filter" do
        let(:total_count) { 0 } # skip default test posts

        before(:each) do
          create_list(:post, 10, author: 'author3')
          create_list(:post, 10, author: 'author1')
          create_list(:post, 10, author: 'author2')
          create_list(:post, 10, author: nil)
        end

        context "without search" do
          it_behaves_like "project all authors"
        end

        context "with scope" do
          before(:each) do
            ds.scope do |items|
              items.where(author: ['author1', 'author2'])
            end
          end

          it "should matching values" do
            expect(ds.values_for_filter(author)).to eq(['author1', 'author2'])
          end
        end

        context "with search" do
          before(:each) do
            ds.search([author], 'author2')
          end

          it_behaves_like "project all authors"
        end

        context "with filter" do
          before(:each) do
            ds.filter(author, 'author2')
          end

          it_behaves_like "project all authors"
        end

        context "with paging" do
          before(:each) do
            ds.paginate(1, 1)
          end

          it_behaves_like "project all authors"
        end

        context "with sort" do
          before(:each) do
            ds.sort(title)
          end

          it_behaves_like "project all authors"
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
    let(:total_count) { 6 } # skip default test posts
    let!(:albums) { create_list(:album, total_count) }
    let!(:ds) { DataSource.for(Track) }
    let!(:track_title) { ds.build_field :title }

    shared_examples "listing with projected values" do
      describe "projected field" do
        it "should project attribute value" do
          expect(album_name.value_for(ds.items.first)).to eq(Track.first.album.name)
        end

        it "should have key" do
          expect(album_name.key).to eq('album_name')
        end
      end

      it "should deal with intermediate nils" do
        track_without_album = create(:track, album: nil)
        expect(album_name.value_for(track_without_album)).to be_nil
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

      describe "filter" do
        before(:each) do
          create(:album, tracks_count: 5, name: 'album-name-magic-string-1')
          create(:album, tracks_count: 5, name: 'album-name-magic-string-2')

          ds.filter(album_name, 'album-name-magic-string-1')
        end

        it "should return matching items" do
          expect(ds.items.count).to be(5)
        end
      end

      describe "sort" do
        def all_track_albumns_name
          Track.all.map { |t| t.album.name }
        end

        before(:each) do
          expect(all_track_albumns_name).to_not eq(all_track_albumns_name.sort)
          ds.sort(album_name)
        end

        it "should return matching items" do
          expect(ds.items.map { |e| album_name.value_for(e) }).to eq(all_track_albumns_name.sort)
        end
      end

      describe "sort desc" do
        def all_track_albumns_name
          Track.all.map { |t| t.album.name }
        end

        before(:each) do
          expect(all_track_albumns_name).to_not eq(all_track_albumns_name.sort.reverse)
          ds.sort(album_name, DataSource::DESC)
        end

        it "should return matching items" do
          expect(ds.items.map { |e| album_name.value_for(e) }).to eq(all_track_albumns_name.sort.reverse)
        end
      end

      describe "values_for_filter" do
        let(:total_count) { 0 } # skip default test albums

        before(:each) do
          create(:album, tracks_count: 5, name: 'album-name-1')
          create(:album, tracks_count: 5, name: 'album-name-3')
          create(:album, tracks_count: 5, name: 'album-name-2')
          create(:album, tracks_count: 5, name: nil)
        end

        context "without search" do
          it "should matching values" do
            expect(ds.values_for_filter(album_name)).to eq(['album-name-1', 'album-name-2', 'album-name-3'])
          end
        end

        context "with scope" do
          before(:each) do
            ds.scope do |items|
              items.where("tracks.id % 2 = 0")
            end
          end

          it "should matching values" do
            expect(ds.values_for_filter(album_name)).to eq(['album-name-1', 'album-name-2', 'album-name-3'])
          end
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
