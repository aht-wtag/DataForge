class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_SENDER", "noreply@dataforge.local")
  layout "mailer"
end
