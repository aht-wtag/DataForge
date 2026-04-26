require "rails_helper"

describe SchemaVersionPolicy do
  include_context "policy defaults"

  let(:schema_version) { SchemaVersion.new }

  %i[index show].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { SchemaVersionPolicy.new(admin, schema_version) }
        it { is_expected.to permit_action(action) }
      end

      context "when developer" do
        subject { SchemaVersionPolicy.new(developer, schema_version) }
        it { is_expected.to forbid_action(action) }
      end

      context "when viewer" do
        subject { SchemaVersionPolicy.new(viewer, schema_version) }
        it { is_expected.to forbid_action(action) }
      end
    end
  end

  %i[create update destroy].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { SchemaVersionPolicy.new(admin, schema_version) }
        it { is_expected.to forbid_action(action) }
      end

      context "when developer" do
        subject { SchemaVersionPolicy.new(developer, schema_version) }
        it { is_expected.to forbid_action(action) }
      end

      context "when viewer" do
        subject { SchemaVersionPolicy.new(viewer, schema_version) }
        it { is_expected.to forbid_action(action) }
      end
    end
  end

  describe "Scope" do
    it "returns all for admin" do
      scope = SchemaVersionPolicy::Scope.new(admin, SchemaVersion).resolve
      expect(scope).to eq(SchemaVersion.all)
    end

    it "returns none for developer" do
      scope = SchemaVersionPolicy::Scope.new(developer, SchemaVersion).resolve
      expect(scope.to_a).to eq([])
    end

    it "returns none for viewer" do
      scope = SchemaVersionPolicy::Scope.new(viewer, SchemaVersion).resolve
      expect(scope.to_a).to eq([])
    end
  end
end
