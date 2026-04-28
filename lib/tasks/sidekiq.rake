namespace :sidekiq do
  desc "Check Sidekiq connectivity"
  task check: :environment do
    puts "Checking Sidekiq/Redis connection..."
    Sidekiq.redis { |conn| conn.ping }
    puts "✓ Sidekiq/Redis connection OK"
  rescue => e
    puts "✗ Sidekiq/Redis connection FAILED: #{e.message}"
    exit 1
  end
end
