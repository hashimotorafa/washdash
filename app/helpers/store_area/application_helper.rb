module StoreArea
  module ApplicationHelper
    def has_chart_data?(chart_data)
      return false if chart_data.nil?

      if chart_data.is_a?(Array)
        # Para gráficos com múltiplas séries
        chart_data.any? { |series| series[:data].values.any? { |value| value.to_f > 0 } }
      elsif chart_data.is_a?(Hash)
        # Para gráficos com série única
        chart_data.values.any? { |value| value.to_f > 0 }
      else
        false
      end
    end

    def render_chart_or_empty_message(chart_data, title = "gráfico")
      if has_chart_data?(chart_data)
        yield
      else
        render_empty_chart_message(title)
      end
    end

    private

    def render_empty_chart_message(title)
      content_tag :div, class: "d-flex flex-column align-items-center justify-content-center py-5 text-muted empty-chart-message" do
        content_tag(:i, "", class: "cil-chart-line mb-3", style: "font-size: 3rem; opacity: 0.3;") +
        content_tag(:h6, "Nenhum dado disponível", class: "mb-2") +
        content_tag(:p, "Não há dados suficientes para exibir este #{title}.", class: "mb-0 text-center small")
      end
    end
  end
end
