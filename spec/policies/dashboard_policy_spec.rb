require "rails_helper"

describe DashboardPolicy do
  include_context "policy defaults"

  describe "#index?" do
    it { expect(DashboardPolicy.new(admin, nil).index?).to be true }
    it { expect(DashboardPolicy.new(developer, nil).index?).to be true }
    it { expect(DashboardPolicy.new(viewer, nil).index?).to be true }
  end

  %i[show? create? update? destroy?].each do |action|
    describe "##{action}" do
      it { expect(DashboardPolicy.new(admin, nil).public_send(action)).to be false }
      it { expect(DashboardPolicy.new(developer, nil).public_send(action)).to be false }
      it { expect(DashboardPolicy.new(viewer, nil).public_send(action)).to be false }
    end
  end
end
