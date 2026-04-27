module CronHelper
  def humanize_cron(cron_expression)
    Fugit.parse_cron(cron_expression).to_s
  rescue StandardError
    cron_expression
  end
end
