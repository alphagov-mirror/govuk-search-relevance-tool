describe Checklists::Criterion do
  describe ".load_all" do
    subject { described_class.load_all }

    it "returns a list of criteria with valid keys" do
      subject.each do |criteria|
        expect(criteria.key).to be_present
        expect(criteria.text).to be_present
      end
    end

    it "returns criteria that reference valid criteria" do
      keys = Checklists::Criterion.load_all.map(&:key)

      subject.each do |criterion|
        expect(keys).to include(*criterion.depends_on.to_a)
      end
    end
  end
end