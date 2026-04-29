module Adapters
  class BaseAdapter
    attr_reader :adapter_record, :state, :progress, :adapter_run

    def initialize(adapter_record, config: {})
      @adapter_record = adapter_record
      @config = config
      @state = 'new'
      @progress = 0
      @adapter_run = nil
      @active = true
    end

    def run
      return unless active?

      @adapter_run = AdapterRun.create_for!(adapter_record, name: run_name)
      set_state('start')

      begin
        result = do_run
        set_result(result)
        set_state('success')
        adapter_run.mark_ended!
        result
      rescue => e
        set_state('failed')
        adapter_run.mark_failed!(error: e)
        Rails.logger.error("[BaseAdapter] Run failed for adapter #{adapter_record.id}: #{e.message}")
        raise
      end
    end

    def do_run
      raise NotImplementedError, "#{self.class} must implement do_run"
    end

    def active?
      @active && adapter_record.status != 'disabled' && !adapter_record.archived?
    end

    private

    def set_state(new_state)
      @state = new_state
      Rails.logger.info("[#{self.class.name}] State: #{new_state} for adapter #{adapter_record.id}")
      adapter_run&.set_state!(new_state)
    end

    def set_progress(step, total_steps)
      @progress = (100.0 * step / total_steps).round
      adapter_run&.set_progress!(step)
    end

    def set_result(result)
      adapter_run&.set_result!(result)
    end

    def run_name
      "#{self.class.name.demodulize} - #{Time.current.strftime('%Y-%m-%d %H:%M')}"
    end

    def config
      @config
    end
  end
end
