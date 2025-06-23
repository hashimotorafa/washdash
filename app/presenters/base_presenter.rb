class BasePresenter

  def current_month?(date)
    date.strftime("%m%Y") == Date.today.strftime("%m%Y")
  end

  def calculate_percentage(current_value, previous_value)
    return 0 if previous_value.zero?

    (((current_value.to_f - previous_value.to_f) / previous_value.to_f) * 100).round(2)
  end

  def months_since_store_opening
    hash = {}
    (@store.started_at..Date.today).each { |date| hash[date.strftime("%m/%Y")] = 0 }
    hash
  end

  def months_limit
    @months_limit ||= begin
      today = Date.today
      start_date = @store.started_at
      months_since_store_opening = (today.year * 12 + today.month) - (start_date.year * 12 + start_date.month)

      months_since_store_opening > 12 ? 12 : months_since_store_opening
    end
  end

  def twelve_months
    @twelve_months ||= begin
      reference_date = @accounting_period.beginning_of_month
      accounting_period_months = [ reference_date ]

      while accounting_period_months.length < months_limit
        if accounting_period_months.last.to_date < Date.today.beginning_of_month
          accounting_period_months << (accounting_period_months.last + 1.month)
        end

        if accounting_period_months.first.to_date > @store.started_at.beginning_of_month
          accounting_period_months.unshift(accounting_period_months.first - 1.month)
        end
      end

      hash = {}
      accounting_period_months.map { |month| hash[month.strftime("%m/%Y")] = 0 }
      hash
    end
    @twelve_months.dup
  end

  def time_range
    [ @accounting_period.beginning_of_month, @accounting_period.end_of_month.end_of_day ]
  end

  def twelve_months_time_range
    @twelve_months_time_range ||= [ twelve_months.keys.first.to_date.beginning_of_month, twelve_months.keys.last.to_date.end_of_month ]
  end

  def previous_accounting_period
    @previous_accounting_period ||= begin
      if @accounting_period.month == 1
        Date.new(@accounting_period.year - 1, 12, 1)
      else
        Date.new(@accounting_period.year, @accounting_period.month - 1, 1)
      end
    end
  end
end
