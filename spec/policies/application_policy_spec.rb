require "rails_helper"

describe ApplicationPolicy do
  let(:admin) { User.new(role: :admin) }
  let(:developer) { User.new(role: :developer) }
  let(:viewer) { User.new(role: :viewer) }

  %i[index show].each do |action|
    describe "##{action}?" do
      subject { ApplicationPolicy.new(admin, nil) }
      it { is_expected.to permit_action(action) }
    end
  end

  %i[create new update edit].each do |action|
    describe "##{action}?" do
      context "when admin" do
        subject { ApplicationPolicy.new(admin, nil) }
        it { is_expected.to permit_action(action) }
      end

      context "when developer" do
        subject { ApplicationPolicy.new(developer, nil) }
        it { is_expected.to permit_action(action) }
      end

      context "when viewer" do
        subject { ApplicationPolicy.new(viewer, nil) }
        it { is_expected.to forbid_action(action) }
      end
    end
  end

  describe "#destroy?" do
    context "when admin" do
      subject { ApplicationPolicy.new(admin, nil) }
      it { is_expected.to permit_action(:destroy) }
    end

    context "when developer" do
      subject { ApplicationPolicy.new(developer, nil) }
      it { is_expected.to forbid_action(:destroy) }
    end

    context "when viewer" do
      subject { ApplicationPolicy.new(viewer, nil) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end
end
