include Listings::Sources

RSpec.describe ObjectDataSource do

  shared_examples "object datasource" do
    let(:tracks) {
      build_list(:object_album, 10).map(&:tracks).flatten
    }

    def add_tracks(ts)
      if ts.is_a?(Array)
        ts.each { |t| add_tracks t }
      elsif ts.is_a?(ObjectAlbum)
        add_tracks ts.tracks
      elsif ts.is_a?(ObjectTrack)
        tracks << ts
      else
        raise "Invalid Object #{ts}"
      end
    end

    let(:track_title) { ds.build_field :title }

    describe "DataSource factory" do
      it "should have tracks with album" do
        expect(tracks).to_not be_empty
        expect(tracks.first.album).to_not be_nil
      end

      it "should create" do
        expect(ds).to be_a(ObjectDataSource)
      end

      describe "field" do
        let(:tracks) { [] }
        before(:each) {
          add_tracks build(:object_track, album: nil)
        }

        it "should deal with intermediate nils" do
          expect(album_name.value_for(ds.items.first)).to be_nil
        end

        it "should have key" do
          expect(album_name.key).to eq('album_name')
        end
      end

      describe "items" do
        it "should list all" do
          expect(ds.items.count).to be(tracks.count)
        end

        it "should enumerate all items" do
          expect(begin
            c = 0
            ds.items.each do
              c = c + 1
            end
            c
          end).to be(tracks.count)
        end
      end

      describe "paginate" do
        let(:page_size) { 5 }

        before(:each) { ds.paginate(2, page_size) }

        it "should get only paged items" do
          expect(ds.items.count).to be(page_size)
        end

        it "should keep total_count" do
          expect(ds.items.total_count).to be(tracks.count)
        end
      end

      describe "field" do
        it "should project attribute value" do
          expect(track_title.value_for(ds.items.first)).to eq(tracks.first.title)
        end

        it "should navigate and  project attribute value" do
          expect(album_name.value_for(ds.items.first)).to eq(tracks.first.album.name)
        end
      end

      describe "scope" do
        before(:each) do
          ds.scope do |items|
            [].tap do |res|
              tracks.each_with_index do |item, index|
                next if index % 2 == 1
                res << item
              end
            end
          end
        end

        it "should return scoped items" do
          expect(ds.items.count).to be(tracks.count / 2)
        end
      end

      describe "search" do
        before(:each) do
          add_tracks build(:object_album, tracks_count: 5, name: 'album-name-magic-string-1')
          add_tracks build(:object_album, tracks_count: 5, name: 'album-name-magic-string-2')
          build_list(:object_album, 2).each do |album_with_tracks_to_match|
            add_tracks build_list(:object_track, 5, title: 'title-magic-string', album: album_with_tracks_to_match)
          end

          ds.search([track_title, album_name], 'magic')
        end

        it "should return matching items" do
          expect(ds.items.count).to be(20)
        end
      end

      describe "filter" do
        before(:each) do
          add_tracks build(:object_album, tracks_count: 5, name: 'album-name-magic-string-1')
          add_tracks build(:object_album, tracks_count: 5, name: 'album-name-magic-string-2')

          ds.filter(album_name, 'album-name-magic-string-1')
        end

        it "should return matching items" do
          expect(ds.items.count).to be(5)
        end
      end

      describe "sort" do
        def all_track_albumns_name
          tracks.map { |t| t.album.name }
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
          tracks.map { |t| t.album.name }
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
        let(:tracks) { [] } # skip default test albums

        before(:each) do
          add_tracks build(:object_album, tracks_count: 5, name: 'album-name-1')
          add_tracks build(:object_album, tracks_count: 5, name: 'album-name-3')
          add_tracks build(:object_album, tracks_count: 5, name: 'album-name-2')
          add_tracks build(:object_album, tracks_count: 5, name: nil)
        end

        context "without search" do
          it "should matching values" do
            expect(ds.values_for_filter(album_name)).to eq(['album-name-1', 'album-name-2', 'album-name-3'])
          end
        end

        context "with scope" do
          before(:each) do
            ds.scope do |items|
              [].tap do |res|
                tracks.each_with_index do |item, index|
                  next if index % 2 == 1
                  res << item
                end
              end
            end
          end

          it "should matching values" do
            expect(ds.values_for_filter(album_name)).to eq(['album-name-1', 'album-name-2', 'album-name-3'])
          end
        end
      end
    end

  end

  context "using array of objects" do
    let(:ds) { DataSource.for(tracks) }
    let(:album_name) { nil }

    context "and hash like fields" do
      let(:album_name) { ds.build_field album: :name }
      it_behaves_like "object datasource"
    end

    context "and array like fields" do
      let(:album_name) { ds.build_field [:album, :name] }
      it_behaves_like "object datasource"
    end
  end

  context "using array of hash" do
    let(:ds) { DataSource.for(tracks.map(&:to_h)) }
    let(:album_name) { nil }

    context "and hash like fields" do
      let(:album_name) { ds.build_field album: :name }
      it_behaves_like "object datasource"
    end

    context "and array like fields" do
      let(:album_name) { ds.build_field [:album, :name] }
      it_behaves_like "object datasource"
    end
  end
end
