require 'spec_helper'

RSpec.describe "Checklists data integrity" do
  let(:validator) { Checklists::CriteriaLogic::Validator }

  it "has questions that reference valid criteria" do
    Checklists::Question.load_all.each do |question|
      expect(validator.validate(question.criteria)).to be_truthy
    end
  end

  it "has actions that reference valid criteria" do
    Checklists::Action.load_all.each do |action|
      expect(validator.validate(action.criteria)).to be_truthy
    end
  end

  it "has change notes that reference valid actions" do
    ids = Checklists::Action.load_all.map(&:id)

    Checklists::ChangeNote.load_all.each do |change_note|
      expect(ids).to include(change_note.action_id)
    end
  end

  it "has question options that reference valid criteria" do
    Checklists::Question.load_all.flat_map(&:possible_values).each do |value|
      expect(validator.validate([value])).to be_truthy
    end
  end

  it "has questions with unique keys" do
    ids = Checklists::Question.load_all(&:key)
    expect(ids.uniq.count).to eq ids.count
  end

  it "has actions with unique IDs" do
    ids = Checklists::Action.load_all(&:id)
    expect(ids.uniq.count).to eq ids.count
  end

  it "has criteria with unique keys" do
    keys = Checklists::Criterion.load_all.map(&:key)
    expect(keys.uniq.count).to eq(keys.count)
  end

  it "has change notes with unique IDs" do
    keys = Checklists::ChangeNote.load_all.map(&:id)
    expect(keys.uniq.count).to eq(keys.count)
  end

  it "has criteria that are covered by a question" do
    possible_criteria = Checklists::Question.load_all
      .flat_map(&:possible_values)

    Checklists::Criterion.load_all.each do |criterion|
      expect(possible_criteria).to include(criterion.key)
    end
  end
end
