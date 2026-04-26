require "rails_helper"

describe EndpointPolicy do
  include_context "policy defaults"

  let(:owned_adapter) { Adapter.new(user: developer) }
  let(:other_adapter) { Adapter.new(user: other_developer) }
  let(:owned_endpoint) { Endpoint.new(adapter: owned_adapter) }
  let(:other_endpoint) { Endpoint.new(adapter: other_adapter) }

  %i[show update destroy execute].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { EndpointPolicy.new(admin, owned_endpoint) }
        it { is_expected.to permit_action(action) }
      end

      context "when owning developer" do
        subject { EndpointPolicy.new(developer, owned_endpoint) }
        it { is_expected.to permit_action(action) }
      end

      context "when non-owning developer" do
        subject { EndpointPolicy.new(developer, other_endpoint) }
        it { is_expected.to forbid_action(action) }
      end

      context "when viewer" do
        subject { EndpointPolicy.new(viewer, owned_endpoint) }
        it { is_expected.to forbid_action(action) }
      end
    end
  end

  %i[create new].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { EndpointPolicy.new(admin, Endpoint.new) }
        it { is_expected.to permit_action(action) }
      end

      context "when developer" do
        subject { EndpointPolicy.new(developer, Endpoint.new) }
        it { is_expected.to permit_action(action) }
      end

      context "when viewer" do
        subject { EndpointPolicy.new(viewer, Endpoint.new) }
        it { is_expected.to forbid_action(action) }
      end
    end
  end

  describe "Scope" do
    let!(:owned_adapter) { Adapter.create!(user: developer, name: "Owned", base_url: "https://owned.com") }
    let!(:other_adapter) { Adapter.create!(user: other_developer, name: "Other", base_url: "https://other.com") }
    let!(:ep_owned) { Endpoint.create!(adapter: owned_adapter, http_method: :get, path: "/a", name: "A") }
    let!(:ep_other) { Endpoint.create!(adapter: other_adapter, http_method: :get, path: "/b", name: "B") }

    it "returns all endpoints for admin" do
      scope = EndpointPolicy::Scope.new(admin, Endpoint).resolve
      expect(scope).to include(ep_owned, ep_other)
    end

    it "returns only owned endpoints for developer" do
      scope = EndpointPolicy::Scope.new(developer, Endpoint).resolve
      expect(scope).to include(ep_owned)
      expect(scope).not_to include(ep_other)
    end
  end
end
