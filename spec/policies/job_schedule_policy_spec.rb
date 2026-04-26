require "rails_helper"

describe JobSchedulePolicy do
  include_context "policy defaults"

  let(:owned_adapter) { Adapter.new(user: developer) }
  let(:other_adapter) { Adapter.new(user: other_developer) }
  let(:owned_schedule) { JobSchedule.new(adapter: owned_adapter, endpoint: Endpoint.new) }
  let(:other_schedule) { JobSchedule.new(adapter: other_adapter, endpoint: Endpoint.new) }

  %i[show update destroy enable disable run_now].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { JobSchedulePolicy.new(admin, owned_schedule) }
        it { is_expected.to permit_action(action) }
      end

      context "when owning developer" do
        subject { JobSchedulePolicy.new(developer, owned_schedule) }
        it { is_expected.to permit_action(action) }
      end

      context "when non-owning developer" do
        subject { JobSchedulePolicy.new(developer, other_schedule) }
        it { is_expected.to forbid_action(action) }
      end

      context "when viewer" do
        subject { JobSchedulePolicy.new(viewer, owned_schedule) }
        it { is_expected.to forbid_action(action) }
      end
    end
  end

  %i[create new].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { JobSchedulePolicy.new(admin, JobSchedule.new) }
        it { is_expected.to permit_action(action) }
      end

      context "when developer" do
        subject { JobSchedulePolicy.new(developer, JobSchedule.new) }
        it { is_expected.to permit_action(action) }
      end

      context "when viewer" do
        subject { JobSchedulePolicy.new(viewer, JobSchedule.new) }
        it { is_expected.to forbid_action(action) }
      end
    end
  end
end
