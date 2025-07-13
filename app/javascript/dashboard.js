// Flag to prevent multiple initializations
window.dashboardInitialized = window.dashboardInitialized || false;

// Function to wait for CoreUI to be available
function waitForCoreUI(callback, maxAttempts = 50) {
  let attempts = 0;
  
  function checkCoreUI() {
    attempts++;
    
    if (typeof coreui !== 'undefined' && coreui.Tooltip) {
      callback();
    } else if (attempts < maxAttempts) {
      setTimeout(checkCoreUI, 100);
    } else {
      console.warn('CoreUI not loaded after maximum attempts, initializing without CoreUI components');
      callback();
    }
  }
  
  checkCoreUI();
}

// Global handler functions to avoid duplicates
function handleNavGroupToggle(e) {
  e.preventDefault();
  e.stopPropagation();
  
  var element = e.currentTarget;
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
}

function handleSidebarToggle(e) {
  e.preventDefault();
  
  var sidebar = document.querySelector('#sidebar');
  var backdrop = document.querySelector('.sidebar-backdrop');
  
  if (!sidebar) return;
  
  // Initialize the sidebar with CoreUI 5.x API if available
  var sidebarInstance = null;
  if (typeof coreui !== 'undefined' && coreui.Sidebar) {
    sidebarInstance = coreui.Sidebar.getOrCreateInstance(sidebar);
  }
  
  // Toggle sidebar
  if (sidebarInstance) {
    sidebarInstance.toggle();
  } else {
    // Fallback toggle without CoreUI
    sidebar.classList.toggle('show');
  }
  
  // Handle backdrop visibility
  if (window.innerWidth <= 991.98 && backdrop) {
    if (sidebar.classList.contains('show')) {
      backdrop.classList.remove('show');
    } else {
      backdrop.classList.add('show');
    }
  }
}

function handleBackdropClick() {
  var sidebar = document.querySelector('#sidebar');
  var backdrop = document.querySelector('.sidebar-backdrop');
  
  if (!sidebar || !backdrop) return;
  
  if (sidebar.classList.contains('show')) {
    var sidebarInstance = null;
    if (typeof coreui !== 'undefined' && coreui.Sidebar) {
      sidebarInstance = coreui.Sidebar.getOrCreateInstance(sidebar);
    }
    
    if (sidebarInstance) {
      sidebarInstance.hide();
    } else {
      sidebar.classList.remove('show');
    }
    backdrop.classList.remove('show');
  }
}

function handleWindowResize() {
  var backdrop = document.querySelector('.sidebar-backdrop');
  if (backdrop && window.innerWidth > 991.98) {
    backdrop.classList.remove('show');
  }
}

function handleTableRowClick(e) {
  if (e.target.tagName !== 'BUTTON' && e.target.tagName !== 'A' && !e.target.closest('button') && !e.target.closest('a')) {
    var firstLink = e.currentTarget.querySelector('a');
    if (firstLink) {
      firstLink.click();
    }
  }
}

function handleFormValidation(event) {
  var form = event.currentTarget;
  if (!form.checkValidity()) {
    event.preventDefault();
    event.stopPropagation();
  }
  form.classList.add('was-validated');
}

function handleSearchInput(e) {
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
}

function handlePaginationClick(e) {
  e.preventDefault();
  var link = e.currentTarget;
  // Add loading state to pagination
  link.classList.add('disabled');
  setTimeout(function () {
    link.classList.remove('disabled');
  }, 1000);
}

function initDashboard() {
  // Check if CoreUI is available
  if (typeof coreui !== 'undefined') {
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

    // Handle sidebar toggle on mobile - Updated to use data attribute
    var sidebarToggler = document.querySelector('[data-sidebar-toggle]');
    if (sidebarToggler) {
      // Remove existing listeners to prevent duplicates
      sidebarToggler.removeEventListener('click', handleSidebarToggle);
      sidebarToggler.addEventListener('click', handleSidebarToggle);
    }

    // Handle backdrop click to close sidebar
    if (backdrop) {
      backdrop.removeEventListener('click', handleBackdropClick);
      backdrop.addEventListener('click', handleBackdropClick);
    }

    // Handle window resize to manage backdrop
    window.removeEventListener('resize', handleWindowResize);
    window.addEventListener('resize', handleWindowResize);

    // Listen for sidebar events if CoreUI is available
    if (typeof coreui !== 'undefined') {
      sidebar.addEventListener('show.coreui.sidebar', function () {
        if (window.innerWidth <= 991.98) {
          backdrop.classList.add('show');
        }
      });

      sidebar.addEventListener('hide.coreui.sidebar', function () {
        backdrop.classList.remove('show');
      });
    }
  }

  // Handle nav groups in sidebar
  var navGroupToggles = document.querySelectorAll('.nav-group-toggle');
  
  navGroupToggles.forEach(function (element) {
    // Remove existing listeners to prevent duplicates
    element.removeEventListener('click', handleNavGroupToggle);
    element.addEventListener('click', handleNavGroupToggle);
    
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
    row.removeEventListener('click', handleTableRowClick);
    row.addEventListener('click', handleTableRowClick);
  });

  // Handle form validation feedback
  document.querySelectorAll('.needs-validation').forEach(function (form) {
    form.removeEventListener('submit', handleFormValidation);
    form.addEventListener('submit', handleFormValidation);
  });

  // Auto-dismiss alerts after 5 seconds (only if CoreUI is available)
  if (typeof coreui !== 'undefined') {
    document.querySelectorAll('.alert:not(.alert-permanent)').forEach(function (alert) {
      setTimeout(function () {
        var alertInstance = coreui.Alert.getInstance(alert);
        if (alertInstance) {
          alertInstance.close();
        }
      }, 5000);
    });
  }

  // Handle search functionality
  var searchInput = document.querySelector('.search-input');
  if (searchInput) {
    searchInput.removeEventListener('input', handleSearchInput);
    searchInput.addEventListener('input', handleSearchInput);
  }

  // Handle pagination
  document.querySelectorAll('.pagination .page-link').forEach(function (link) {
    link.removeEventListener('click', handlePaginationClick);
    link.addEventListener('click', handlePaginationClick);
  });
}

// Initialize admin functionality when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
  window.dashboardInitialized = false;
  waitForCoreUI(initDashboard);
});

// Re-initialize when navigating with Turbo
document.addEventListener('turbo:load', function() {
  window.dashboardInitialized = false;
  waitForCoreUI(initDashboard);
});

// Clean up when leaving the page
document.addEventListener('turbo:before-cache', function() {
  window.dashboardInitialized = false;
});