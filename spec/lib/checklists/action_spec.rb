require 'spec_helper'

describe Checklists::Action do
  describe '#applicable_criteria?' do
    subject do
      described_class.new(
        'applicable_criteria' => applicable_criteria
      ).applies_to?(selected_criteria)
    end

    context "no applicable criteria" do
      let(:applicable_criteria) { [] }
      let(:selected_criteria) { %w[A] }

      it { is_expected.to eq(false) }
    end

    context "the selected criteria meets the applicable criteria" do
      let(:applicable_criteria) { %w[A B C] }
      let(:selected_criteria) { %w[A] }

      it { is_expected.to eq(true) }
    end

    context "no selected criteria" do
      let(:applicable_criteria) { %w[A B C] }
      let(:selected_criteria) { [] }

      it { is_expected.to eq(false) }
    end
  end

  describe ".load_all" do
    subject { described_class.load_all }

    it "returns a list of actions with required keys" do
      subject.each do |action|
        expect(action.title).to be_present
        expect(action.description).to be_present
        expect(action.path).to be_present
        expect(action.applicable_criteria).to be_a Array
      end
    end

    it "returns actions that reference valid criteria" do
      criteria = Checklists::Criterion.load_all.map(&:key)

      subject.each do |action|
        expect(criteria).to include(*action.applicable_criteria.to_a)
      end
    end
  end
end