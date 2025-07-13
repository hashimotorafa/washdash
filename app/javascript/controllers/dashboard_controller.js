import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('Dashboard controller connected!');
    // Wait for CoreUI to be available
    this.waitForCoreUI();
  }

  waitForCoreUI() {
    if (typeof window.coreui !== 'undefined') {
      console.log('CoreUI is available, initializing dashboard');
      this.initDashboard();
    } else {
      console.log('CoreUI not yet available, waiting...');
      setTimeout(() => this.waitForCoreUI(), 100);
    }
  }

  initDashboard() {
    console.log('initDashboard called from Stimulus controller');
    
    // Initialize all tooltips - CoreUI 5.x syntax
    if (window.coreui && window.coreui.Tooltip) {
      var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-coreui-toggle="tooltip"]'))
      tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new window.coreui.Tooltip(tooltipTriggerEl)
      });
    }

    // Initialize all popovers - CoreUI 5.x syntax
    if (window.coreui && window.coreui.Popover) {
      var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-coreui-toggle="popover"]'))
      popoverTriggerList.map(function (popoverTriggerEl) {
        return new window.coreui.Popover(popoverTriggerEl)
      });
    }

    // Sidebar functionality - Updated for CoreUI 5.x with backdrop handling
    var sidebar = document.querySelector('#sidebar');
    if (sidebar) {
      // Create backdrop element if it doesn't exist
      var backdrop = document.querySelector('.sidebar-backdrop');
      if (!backdrop) {
        backdrop = document.createElement('div');
        backdrop.className = 'sidebar-backdrop';
        document.body.appendChild(backdrop);
      }

      // Initialize the sidebar with CoreUI 5.x API
      var sidebarInstance = null;
      if (window.coreui && window.coreui.Sidebar) {
        sidebarInstance = window.coreui.Sidebar.getOrCreateInstance(sidebar);
      }

      // Handle sidebar toggle on mobile - Updated to use data attribute
      var sidebarToggler = document.querySelector('[data-sidebar-toggle]');
      if (sidebarToggler) {
        sidebarToggler.addEventListener('click', function (e) {
          e.preventDefault();
          
          // Toggle sidebar
          if (sidebarInstance) {
            sidebarInstance.toggle();
          } else {
            // Fallback without CoreUI
            sidebar.classList.toggle('show');
          }
          
          // Handle backdrop visibility
          if (window.innerWidth <= 991.98) {
            if (sidebar.classList.contains('show')) {
              backdrop.classList.remove('show');
            } else {
              backdrop.classList.add('show');
            }
          }
        });
      }

      // Handle backdrop click to close sidebar
      backdrop.addEventListener('click', function () {
        if (sidebar.classList.contains('show')) {
          if (sidebarInstance) {
            sidebarInstance.hide();
          } else {
            sidebar.classList.remove('show');
          }
          backdrop.classList.remove('show');
        }
      });

      // Handle window resize
      window.addEventListener('resize', function () {
        if (window.innerWidth > 991.98) {
          backdrop.classList.remove('show');
        }
      });
    }

    // Nav-group-toggle functionality
    this.setupNavGroupToggle();
  }

  setupNavGroupToggle() {
    var navGroupToggles = document.querySelectorAll('.nav-group-toggle');
    
    navGroupToggles.forEach(function (element) {
      // Remove existing listeners to avoid duplicates
      element.removeEventListener('click', this.handleNavGroupClick);
      element.addEventListener('click', this.handleNavGroupClick);
      
      // Set initial aria attributes
      var navGroup = element.closest('.nav-group');
      if (navGroup) {
        var isExpanded = navGroup.classList.contains('show');
        element.setAttribute('aria-expanded', isExpanded);
        element.setAttribute('role', 'button');
        
        var navGroupItems = navGroup.querySelector('.nav-group-items');
        if (navGroupItems) {
          navGroupItems.setAttribute('aria-hidden', !isExpanded);
        }
      }
    }.bind(this));
  }

  handleNavGroupClick(e) {
    e.preventDefault();
    e.stopPropagation();
    
    var navGroup = e.target.closest('.nav-group');
    if (navGroup) {
      navGroup.classList.toggle('show');
      
      var isExpanded = navGroup.classList.contains('show');
      e.target.setAttribute('aria-expanded', isExpanded);
      
      var navGroupItems = navGroup.querySelector('.nav-group-items');
      if (navGroupItems) {
        navGroupItems.setAttribute('aria-hidden', !isExpanded);
      }
    }
  }
} 