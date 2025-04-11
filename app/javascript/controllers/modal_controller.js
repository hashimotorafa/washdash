// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  close() {
    debugger
    const modal = document.getElementById("modal")
    if (modal) modal.innerHTML = ""
  }
}