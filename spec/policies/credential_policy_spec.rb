require "rails_helper"

describe CredentialPolicy do
  include_context "policy defaults"

  let(:owned_adapter) { Adapter.new(user: developer) }
  let(:other_adapter) { Adapter.new(user: other_developer) }
  let(:owned_credential) { Credential.new(adapter: owned_adapter) }
  let(:other_credential) { Credential.new(adapter: other_adapter) }

  %i[show update destroy].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { CredentialPolicy.new(admin, owned_credential) }
        it { is_expected.to permit_action(action) }
      end

      context "when owning developer" do
        subject { CredentialPolicy.new(developer, owned_credential) }
        it { is_expected.to permit_action(action) }
      end

      context "when non-owning developer" do
        subject { CredentialPolicy.new(developer, other_credential) }
        it { is_expected.to forbid_action(action) }
      end

      context "when viewer" do
        subject { CredentialPolicy.new(viewer, owned_credential) }
        it { is_expected.to forbid_action(action) }
      end
    end
  end

  %i[create new].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { CredentialPolicy.new(admin, Credential.new) }
        it { is_expected.to permit_action(action) }
      end

      context "when developer" do
        subject { CredentialPolicy.new(developer, Credential.new) }
        it { is_expected.to permit_action(action) }
      end

      context "when viewer" do
        subject { CredentialPolicy.new(viewer, Credential.new) }
        it { is_expected.to forbid_action(action) }
      end
    end
  end
end
