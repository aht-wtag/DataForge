require "rails_helper"

describe TransformationRulePolicy do
  include_context "policy defaults"

  let(:owned_adapter) { Adapter.new(user: developer) }
  let(:other_adapter) { Adapter.new(user: other_developer) }
  let(:owned_endpoint) { Endpoint.new(adapter: owned_adapter) }
  let(:other_endpoint) { Endpoint.new(adapter: other_adapter) }
  let(:owned_rule) { TransformationRule.new(endpoint: owned_endpoint) }
  let(:other_rule) { TransformationRule.new(endpoint: other_endpoint) }

  %i[show update destroy reorder].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { TransformationRulePolicy.new(admin, owned_rule) }
        it { is_expected.to permit_action(action) }
      end

      context "when owning developer" do
        subject { TransformationRulePolicy.new(developer, owned_rule) }
        it { is_expected.to permit_action(action) }
      end

      context "when non-owning developer" do
        subject { TransformationRulePolicy.new(developer, other_rule) }
        it { is_expected.to forbid_action(action) }
      end

      context "when viewer" do
        subject { TransformationRulePolicy.new(viewer, owned_rule) }
        it { is_expected.to forbid_action(action) }
      end
    end
  end

  %i[create new].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { TransformationRulePolicy.new(admin, TransformationRule.new) }
        it { is_expected.to permit_action(action) }
      end

      context "when developer" do
        subject { TransformationRulePolicy.new(developer, TransformationRule.new) }
        it { is_expected.to permit_action(action) }
      end

      context "when viewer" do
        subject { TransformationRulePolicy.new(viewer, TransformationRule.new) }
        it { is_expected.to forbid_action(action) }
      end
    end
  end
end
