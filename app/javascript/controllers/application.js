import { Application } from "@hotwired/stimulus"
import ModalController from "./modal_controller"
const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application
application.register("modal", ModalController)
export { application }
