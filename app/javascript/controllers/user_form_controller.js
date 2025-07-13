import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["storeField"]

  connect() {
    this.toggleStore()
  }

  toggleStore() {
    const roleSelect = this.element.querySelector('select[name="user[role]"]')
    const isOperator = roleSelect.value === 'operator'
    
    if (this.hasStoreFieldTarget) {
      this.storeFieldTarget.classList.toggle('d-none', !isOperator)
      
      const storeSelect = this.storeFieldTarget.querySelector('select')
      storeSelect.required = isOperator
    }
  }

  async updateStores(event) {
    const companyId = event.target.value
    const storeSelect = this.element.querySelector('select[name="user[store_id]"]')
    
    if (!storeSelect) return
    
    if (companyId) {
      const response = await fetch(`/admin/companies/${companyId}/stores`)
      const stores = await response.json()
      
      storeSelect.innerHTML = '<option value="">Selecione uma loja</option>'
      stores.forEach(store => {
        storeSelect.innerHTML += `<option value="${store.id}">${store.name}</option>`
      })
    } else {
      storeSelect.innerHTML = '<option value="">Selecione uma loja</option>'
    }
  }
} 