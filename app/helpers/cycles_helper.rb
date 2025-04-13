module CyclesHelper
  def cycle_status_badge_class(status)
    case status
    when "Efetivado"
      "bg-success"
    when "Estornado"
      "bg-danger"
    else
      "bg-secondary"
    end
  end
end
