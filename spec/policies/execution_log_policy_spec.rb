require "rails_helper"

describe ExecutionLogPolicy do
  include_context "policy defaults"

  let(:owned_adapter) { Adapter.new(user: developer) }
  let(:other_adapter) { Adapter.new(user: other_developer) }
  let(:owned_log) { ExecutionLog.new(adapter: owned_adapter) }
  let(:other_log) { ExecutionLog.new(adapter: other_adapter) }

  %i[show retry].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { ExecutionLogPolicy.new(admin, owned_log) }
        it { is_expected.to permit_action(action) }
      end

      context "when owning developer" do
        subject { ExecutionLogPolicy.new(developer, owned_log) }
        it { is_expected.to permit_action(action) }
      end

      context "when non-owning developer" do
        subject { ExecutionLogPolicy.new(developer, other_log) }
        it { is_expected.to forbid_action(action) }
      end

      context "when viewer" do
        subject { ExecutionLogPolicy.new(viewer, owned_log) }
        it { is_expected.to forbid_action(action) }
      end
    end
  end

  %i[create update].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { ExecutionLogPolicy.new(admin, owned_log) }
        it { is_expected.to forbid_action(action) }
      end

      context "when developer" do
        subject { ExecutionLogPolicy.new(developer, owned_log) }
        it { is_expected.to forbid_action(action) }
      end
    end
  end

  describe "#destroy?" do
    context "when admin" do
      subject { ExecutionLogPolicy.new(admin, owned_log) }
      it { is_expected.to permit_action(:destroy) }
    end

    context "when developer" do
      subject { ExecutionLogPolicy.new(developer, owned_log) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end
end
