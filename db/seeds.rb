%w[
  admin
  developer
  viewer
].each do |role|
  User.find_or_create_by!(email: "#{role}@dataforge.local") do |u|
    u.password = "Password123"
    u.password_confirmation = "Password123"
    u.first_name = role.capitalize
    u.last_name = "User"
    u.role = role
    u.confirmed_at = Time.current
  end
end

puts "Seeded 3 users:"
puts "  admin@dataforge.local     (admin)"
puts "  developer@dataforge.local (developer)"
puts "  viewer@dataforge.local    (viewer)"
puts "All passwords: Password123"
