include Listings::Sources

RSpec.describe ObjectDataSource do

  shared_examples "object datasource" do
    let(:tracks) {
      build_list(:object_track, 5)
    }

    describe "DataSource factory" do
      it "should create" do
        expect(ds).to be_a(ObjectDataSource)
      end
    end

  end

  context "using array of objects" do
    let(:ds) { DataSource.for(tracks) }
    let(:tracks) { [] }

    it_behaves_like "object datasource"
  end

end
