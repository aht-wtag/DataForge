require "rails_helper"

describe StoredDatumPolicy do
  include_context "policy defaults"

  let(:owned_adapter) { Adapter.new(user: developer) }
  let(:owned_datum) { StoredDatum.new(adapter: owned_adapter, endpoint: Endpoint.new, data: { "key" => "val" }) }

  %i[index show].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { StoredDatumPolicy.new(admin, owned_datum) }
        it { is_expected.to permit_action(action) }
      end

      context "when owning developer" do
        subject { StoredDatumPolicy.new(developer, owned_datum) }
        it { is_expected.to permit_action(action) }
      end
    end
  end

  %i[create update].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { StoredDatumPolicy.new(admin, owned_datum) }
        it { is_expected.to forbid_action(action) }
      end

      context "when developer" do
        subject { StoredDatumPolicy.new(developer, owned_datum) }
        it { is_expected.to forbid_action(action) }
      end

      context "when viewer" do
        subject { StoredDatumPolicy.new(viewer, owned_datum) }
        it { is_expected.to forbid_action(action) }
      end
    end
  end

  describe "#destroy?" do
    context "when admin" do
      subject { StoredDatumPolicy.new(admin, owned_datum) }
      it { is_expected.to permit_action(:destroy) }
    end

    context "when developer" do
      subject { StoredDatumPolicy.new(developer, owned_datum) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end
end
