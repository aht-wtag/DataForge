RSpec.shared_context "policy defaults" do
  let(:admin) { User.new(role: :admin, email: "admin@example.com", first_name: "Admin", last_name: "User") }
  let(:developer) { User.new(role: :developer, email: "dev@example.com", first_name: "Dev", last_name: "User") }
  let(:other_developer) { User.new(role: :developer, email: "other@example.com", first_name: "Other", last_name: "Dev") }
  let(:viewer) { User.new(role: :viewer, email: "viewer@example.com", first_name: "View", last_name: "User") }
end

RSpec.shared_examples "an admin-only destroy policy" do
  it "allows admin to destroy" do
    expect(policy_class.new(admin, record)).to permit_action(:destroy)
  end

  it "denies developer from destroying" do
    expect(policy_class.new(developer, record)).to forbid_action(:destroy)
  end

  it "denies viewer from destroying" do
    expect(policy_class.new(viewer, record)).to forbid_action(:destroy)
  end
end

RSpec.shared_examples "a read-only policy for viewer" do
  it "allows viewer to index" do
    expect(policy_class.new(viewer, record)).to permit_action(:index)
  end

  it "denies viewer from creating" do
    expect(policy_class.new(viewer, record)).to forbid_action(:create)
  end

  it "denies viewer from updating" do
    expect(policy_class.new(viewer, record)).to forbid_action(:update)
  end

  it "denies viewer from destroying" do
    expect(policy_class.new(viewer, record)).to forbid_action(:destroy)
  end
end
