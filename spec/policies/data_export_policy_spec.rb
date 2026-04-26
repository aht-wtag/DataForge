require "rails_helper"

describe DataExportPolicy do
  include_context "policy defaults"

  let(:owned_export) { DataExport.new(user: developer) }
  let(:other_export) { DataExport.new(user: other_developer) }

  %i[show download].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { DataExportPolicy.new(admin, owned_export) }
        it { is_expected.to permit_action(action) }
      end

      context "when owning developer" do
        subject { DataExportPolicy.new(developer, owned_export) }
        it { is_expected.to permit_action(action) }
      end

      context "when non-owning developer" do
        subject { DataExportPolicy.new(developer, other_export) }
        it { is_expected.to forbid_action(action) }
      end

      context "when viewer" do
        subject { DataExportPolicy.new(viewer, owned_export) }
        it { is_expected.to forbid_action(action) }
      end
    end
  end

  %i[create new].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { DataExportPolicy.new(admin, DataExport.new) }
        it { is_expected.to permit_action(action) }
      end

      context "when developer" do
        subject { DataExportPolicy.new(developer, DataExport.new) }
        it { is_expected.to permit_action(action) }
      end

      context "when viewer" do
        subject { DataExportPolicy.new(viewer, DataExport.new) }
        it { is_expected.to forbid_action(action) }
      end
    end
  end

  describe "#update?" do
    subject { DataExportPolicy.new(admin, owned_export) }
    it { is_expected.to forbid_action(:update) }
  end

  describe "#destroy?" do
    context "when admin" do
      subject { DataExportPolicy.new(admin, owned_export) }
      it { is_expected.to permit_action(:destroy) }
    end

    context "when developer" do
      subject { DataExportPolicy.new(developer, owned_export) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  describe "Scope" do
    let!(:adapter) { Adapter.create!(user: developer, name: "Exp", base_url: "https://exp.com") }
    let!(:export_a) { DataExport.create!(user: developer, adapter: adapter, export_format: :csv) }
    let!(:export_b) { DataExport.create!(user: other_developer, adapter: adapter, export_format: :json) }

    it "returns all exports for admin" do
      scope = DataExportPolicy::Scope.new(admin, DataExport).resolve
      expect(scope).to include(export_a, export_b)
    end

    it "returns only own exports for developer" do
      scope = DataExportPolicy::Scope.new(developer, DataExport).resolve
      expect(scope).to include(export_a)
      expect(scope).not_to include(export_b)
    end
  end
end
