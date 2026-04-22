namespace :db do
  namespace :migrate do
    desc "Run migrations and track success in schema_versions table"
    task tracked: :environment do
      ActiveRecord::Migration.verbose = true

      ensure_schema_migrations_table

      context = ActiveRecord::MigrationContext.new(
        ActiveRecord::Migrator.migrations_paths,
        ActiveRecord::SchemaMigration
      )

      all_migrations = context.migrations
      ran_versions = ActiveRecord::Base.connection.select_values(
        "SELECT version FROM schema_migrations"
      )
      pending = all_migrations.reject { |m| ran_versions.include?(m.version.to_s) }

      if pending.empty?
        puts "==> No pending migrations."
        next
      end

      puts "==> Running #{pending.size} pending migration(s) with tracking..."

      pending.each do |migration|
        version = migration.version
        name = migration.name

        begin
          migration.migrate(:up)
          ActiveRecord::Base.connection.execute(
            ActiveRecord::Base.send(:sanitize_sql_array, ["INSERT INTO schema_migrations (version) VALUES (?)", version.to_s])
          )

          track_result(version.to_s, name, 1, nil)
          puts "  ✓ #{name} (#{version}) — success"

        rescue => e
          track_result(version.to_s, name, 0, e.message)
          puts "  ✗ #{name} (#{version}) — FAILED: #{e.message}"
          raise
        end
      end

      puts "==> Tracked migrations complete."
    end
  end

  namespace :rollback do
    desc "Rollback and track in schema_versions"
    task tracked: :environment do
      step = (ENV["STEP"] || "1").to_i
      puts "==> Rolling back #{step} migration(s) with tracking..."

      context = ActiveRecord::MigrationContext.new(
        ActiveRecord::Migrator.migrations_paths,
        ActiveRecord::SchemaMigration
      )

      all_migrations = context.migrations
      ran_versions = ActiveRecord::Base.connection.select_values(
        "SELECT version FROM schema_migrations"
      ).map(&:to_i)
      to_rollback = all_migrations.select { |m| ran_versions.include?(m.version) }.reverse.first(step)

      to_rollback.each do |migration|
        migration.migrate(:down)
        ActiveRecord::Base.connection.execute(
          ActiveRecord::Base.send(:sanitize_sql_array, ["DELETE FROM schema_migrations WHERE version = ?", migration.version.to_s])
        )
        puts "  ✓ Rolled back #{migration.name} (#{migration.version})"
      end

      puts "==> Rollback complete."
    end
  end

  private

  def ensure_schema_migrations_table
    ActiveRecord::Base.connection.execute(
      "CREATE TABLE IF NOT EXISTS schema_migrations (version character varying NOT NULL PRIMARY KEY)"
    )
  end

  def track_result(version, name, success, error_message)
    return unless ActiveRecord::Base.connection.table_exists?(:schema_versions)

    SchemaVersion.create!(
      version: version,
      name: name,
      success: success,
      error_message: error_message,
      ran_at: Time.current
    )
  rescue => e
    puts "  ⚠ Could not track migration result: #{e.message}"
  end
end
