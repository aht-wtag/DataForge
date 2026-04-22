Devise.setup do |config|
  config.mailer_sender = ENV.fetch("MAILER_SENDER", "noreply@dataforge.local")

  require "devise/orm/active_record"

  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  config.skip_session_storage = [:http_auth]

  config.stretches = Rails.env.test? ? 1 : 12

  config.reconfirmable = true

  config.confirm_within = 3.days

  config.remember_for = 4.weeks

  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  config.reset_password_within = 6.hours

  config.sign_in_after_reset_password = true

  config.password_length = 8..128

  config.unlock_strategy = :both

  config.maximum_attempts = 20

  config.unlock_in = 1.hour

  config.sign_out_via = :delete

  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end
