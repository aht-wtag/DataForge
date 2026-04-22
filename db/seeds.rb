User.find_or_create_by!(email: "admin@dataforge.local") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.first_name = "Admin"
  u.last_name = "User"
  u.role = :admin
  u.confirmed_at = Time.current
end
