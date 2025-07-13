function initDashboard() {
  // Initialize all tooltips - CoreUI 5.x syntax
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-coreui-toggle="tooltip"]'))
  tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new coreui.Tooltip(tooltipTriggerEl)
  });

  // Initialize all popovers - CoreUI 5.x syntax
  var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-coreui-toggle="popover"]'))
  popoverTriggerList.map(function (popoverTriggerEl) {
    return new coreui.Popover(popoverTriggerEl)
  });

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
    var sidebarInstance = coreui.Sidebar.getOrCreateInstance(sidebar);

    // Handle sidebar toggle on mobile - Updated to use data attribute
    var sidebarToggler = document.querySelector('[data-sidebar-toggle]');
    if (sidebarToggler) {
      sidebarToggler.addEventListener('click', function (e) {
        e.preventDefault();
        
        // Toggle sidebar
        sidebarInstance.toggle();
        
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
    if (backdrop) {
      backdrop.addEventListener('click', function () {
        if (sidebar.classList.contains('show')) {
          sidebarInstance.hide();
          backdrop.classList.remove('show');
        }
      });
    }

    // Handle window resize to manage backdrop
    window.addEventListener('resize', function () {
      if (window.innerWidth > 991.98) {
        backdrop.classList.remove('show');
      }
    });

    // Listen for sidebar events
    sidebar.addEventListener('show.coreui.sidebar', function () {
      if (window.innerWidth <= 991.98) {
        backdrop.classList.add('show');
      }
    });

    sidebar.addEventListener('hide.coreui.sidebar', function () {
      backdrop.classList.remove('show');
    });
  }

  // Handle dropdown menus - Updated for CoreUI 5.x
  var dropdownElementList = [].slice.call(document.querySelectorAll('.dropdown-toggle'))
  dropdownElementList.map(function (dropdownToggleEl) {
    return new coreui.Dropdown(dropdownToggleEl);
  });

  // Initialize all modals - CoreUI 5.x
  var modalElementList = [].slice.call(document.querySelectorAll('.modal'))
  modalElementList.map(function (modalEl) {
    return new coreui.Modal(modalEl);
  });

  // Initialize all alerts - CoreUI 5.x
  var alertElementList = [].slice.call(document.querySelectorAll('.alert'))
  alertElementList.map(function (alertEl) {
    return new coreui.Alert(alertEl);
  });

  // Handle nav groups in sidebar
  var navGroupToggles = document.querySelectorAll('.nav-group-toggle');
  
  navGroupToggles.forEach(function (element) {
    element.addEventListener('click', function (e) {
      e.preventDefault();
      e.stopPropagation();
      
      var navGroup = element.closest('.nav-group');
      if (navGroup) {
        // Toggle the show class
        navGroup.classList.toggle('show');
        
        // Update aria attributes for accessibility
        var isExpanded = navGroup.classList.contains('show');
        element.setAttribute('aria-expanded', isExpanded);
        
        // Find the nav-group-items and update aria-hidden
        var navGroupItems = navGroup.querySelector('.nav-group-items');
        if (navGroupItems) {
          navGroupItems.setAttribute('aria-hidden', !isExpanded);
        }
      }
    });
    
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
  });

  // Handle table row clicks for better UX
  document.querySelectorAll('table tbody tr').forEach(function (row) {
    row.addEventListener('click', function (e) {
      if (e.target.tagName !== 'BUTTON' && e.target.tagName !== 'A' && !e.target.closest('button') && !e.target.closest('a')) {
        var firstLink = row.querySelector('a');
        if (firstLink) {
          firstLink.click();
        }
      }
    });
  });

  // Handle form validation feedback
  document.querySelectorAll('.needs-validation').forEach(function (form) {
    form.addEventListener('submit', function (event) {
      if (!form.checkValidity()) {
        event.preventDefault();
        event.stopPropagation();
      }
      form.classList.add('was-validated');
    });
  });

  // Auto-dismiss alerts after 5 seconds
  document.querySelectorAll('.alert:not(.alert-permanent)').forEach(function (alert) {
    setTimeout(function () {
      var alertInstance = coreui.Alert.getInstance(alert);
      if (alertInstance) {
        alertInstance.close();
      }
    }, 5000);
  });

  // Handle search functionality
  var searchInput = document.querySelector('.search-input');
  if (searchInput) {
    searchInput.addEventListener('input', function (e) {
      var searchTerm = e.target.value.toLowerCase();
      var tableRows = document.querySelectorAll('table tbody tr');
      
      tableRows.forEach(function (row) {
        var text = row.textContent.toLowerCase();
        if (text.includes(searchTerm)) {
          row.classList.remove('d-none');
        } else {
          row.classList.add('d-none');
        }
      });
    });
  }

  // Handle pagination
  document.querySelectorAll('.pagination .page-link').forEach(function (link) {
    link.addEventListener('click', function (e) {
      e.preventDefault();
      // Add loading state to pagination
      link.classList.add('disabled');
      setTimeout(function () {
        link.classList.remove('disabled');
      }, 1000);
    });
  });
}

// Initialize admin functionality when DOM is loaded
document.addEventListener('DOMContentLoaded', initDashboard);

// Re-initialize when navigating with Turbo
document.addEventListener('turbo:load', initDashboard);

// Export for ES6 module compatibility
export { initDashboard };