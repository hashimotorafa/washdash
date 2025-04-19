import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js/auto"

export default class extends Controller {
  connect() {
    const charts = document.querySelectorAll('[data-coreui-chart]')
    
    charts.forEach(chart => {
      const type = chart.dataset.coreuiChart
      const label = chart.dataset.coreuiDatasetLabel
      const labels = JSON.parse(chart.dataset.coreuiLabels)
      const data = JSON.parse(chart.dataset.coreuiDatasetData)
      
      new Chart(chart, {
        type: type,
        data: {
          labels: labels,
          datasets: [{
            label: label,
            data: data,
            backgroundColor: type === 'bar' ? [
              'rgba(255, 99, 132, 0.5)',
              'rgba(54, 162, 235, 0.5)',
              'rgba(255, 206, 86, 0.5)',
              'rgba(75, 192, 192, 0.5)',
              'rgba(153, 102, 255, 0.5)'
            ] : 'rgba(54, 162, 235, 0.5)',
            borderColor: type === 'bar' ? [
              'rgba(255, 99, 132, 1)',
              'rgba(54, 162, 235, 1)',
              'rgba(255, 206, 86, 1)',
              'rgba(75, 192, 192, 1)',
              'rgba(153, 102, 255, 1)'
            ] : 'rgba(54, 162, 235, 1)',
            borderWidth: 1
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          scales: {
            y: {
              beginAtZero: true
            }
          }
        }
      })
    })
  }
} 