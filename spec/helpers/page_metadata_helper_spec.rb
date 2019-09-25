require "spec_helper"
require "support/taxonomy_helper"

describe PageMetadataHelper, type: :helper do
  include TaxonomySpecHelper
  include TopicFinderHelper

  let(:organisations) {
    [{ title: "org1", web_url: "http://www.gov.uk/org1" },
     { title: "org2", web_url: "http://www.gov.uk/org2" }]
  }
  let(:content_item) {
    FactoryBot.build(:content_item, links: { organisations: organisations })
  }
  let(:filter_params) { {} }
  subject(:subject) {
    page_metadata(content_item, filter_params)
  }
  before :each do
    topic_taxonomy_has_taxons([FactoryBot.build(:level_one_taxon_hash, content_id: "existing_content_id")])
  end
  describe "#page_metadata" do
    it "contains links to organisations" do
      expect(subject[:from]).to match_array(['<a href="http://www.gov.uk/org1">org1</a>',
                                             '<a href="http://www.gov.uk/org2">org2</a>'])
    end
    describe "there are no organisations" do
      let(:organisations) { [] }
      it 'does not contain the "from" key' do
        expect(subject).to_not have_key(:from)
      end
    end
    describe "it is a topic page" do
      let(:filter_params) { { "topic" => "existing_content_id" } }
      it 'does not contain the "inverse" key' do
        expect(subject[:inverse]).to be true
      end
    end
    describe "it is not a topic page" do
      it 'does not contain the "inverse" key' do
        expect(subject).to_not have_key(:inverse)
      end
    end
  end
end
