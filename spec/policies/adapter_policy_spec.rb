require "rails_helper"

describe AdapterPolicy do
  include_context "policy defaults"

  let(:owned_adapter) { Adapter.new(user: developer) }
  let(:other_adapter) { Adapter.new(user: other_developer) }

  %i[show update destroy archive].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { AdapterPolicy.new(admin, owned_adapter) }
        it { is_expected.to permit_action(action) }
      end

      context "when owning developer" do
        subject { AdapterPolicy.new(developer, owned_adapter) }
        it { is_expected.to permit_action(action) }
      end

      context "when non-owning developer" do
        subject { AdapterPolicy.new(developer, other_adapter) }
        it { is_expected.to forbid_action(action) }
      end

      context "when viewer" do
        subject { AdapterPolicy.new(viewer, owned_adapter) }
        it { is_expected.to forbid_action(action) }
      end
    end
  end

  %i[create new].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { AdapterPolicy.new(admin, Adapter.new) }
        it { is_expected.to permit_action(action) }
      end

      context "when developer" do
        subject { AdapterPolicy.new(developer, Adapter.new) }
        it { is_expected.to permit_action(action) }
      end

      context "when viewer" do
        subject { AdapterPolicy.new(viewer, Adapter.new) }
        it { is_expected.to forbid_action(action) }
      end
    end
  end

  describe "Scope" do
    let!(:adapter_a) { Adapter.create!(user: developer, name: "A", base_url: "https://a.com") }
    let!(:adapter_b) { Adapter.create!(user: other_developer, name: "B", base_url: "https://b.com") }

    it "returns all adapters for admin" do
      scope = AdapterPolicy::Scope.new(admin, Adapter).resolve
      expect(scope).to include(adapter_a, adapter_b)
    end

    it "returns only owned adapters for developer" do
      scope = AdapterPolicy::Scope.new(developer, Adapter).resolve
      expect(scope).to include(adapter_a)
      expect(scope).not_to include(adapter_b)
    end

    it "returns only owned adapters for viewer" do
      scope = AdapterPolicy::Scope.new(viewer, Adapter).resolve
      expect(scope.to_a).to eq([])
    end
  end
end
