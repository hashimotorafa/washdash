function initAdmin() {
  // Initialize all tooltips
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-coreui-toggle="tooltip"]'))
  tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new coreui.Tooltip(tooltipTriggerEl)
  });

  // Initialize all popovers
  var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-coreui-toggle="popover"]'))
  popoverTriggerList.map(function (popoverTriggerEl) {
    return new coreui.Popover(popoverTriggerEl)
  });

  // Sidebar functionality
  var sidebar = document.querySelector('#sidebar');
  if (sidebar) {
    // Initialize the sidebar
    var sidebarInstance = coreui.Sidebar.getInstance(sidebar) || new coreui.Sidebar(sidebar);

    // Handle sidebar toggle on mobile
    var sidebarToggler = document.querySelector('.header-toggler');
    if (sidebarToggler) {
      sidebarToggler.addEventListener('click', function (e) {
        e.preventDefault();
        sidebarInstance.toggle();
      });
    }
  }

  // Handle dropdown menus
  var dropdownElementList = [].slice.call(document.querySelectorAll('.dropdown-toggle'))
  dropdownElementList.map(function (dropdownToggleEl) {
    return new coreui.Dropdown(dropdownToggleEl);
  });

  // Handle nav groups in sidebar
  document.querySelectorAll('.nav-group-toggle').forEach(function (element) {
    element.addEventListener('click', function (e) {
      e.preventDefault();
      let parent = this.closest('.nav-group');
      parent.classList.toggle('show');

      // Animate the nav group items
      let items = parent.querySelector('.nav-group-items');
      if (items) {
        if (parent.classList.contains('show')) {
          items.style.maxHeight = items.scrollHeight + 'px';
        } else {
          items.style.maxHeight = '0';
        }
      }
    });
  });

  // Add active class to current nav item
  const currentPath = window.location.pathname;
  document.querySelectorAll('.nav-link').forEach(link => {
    if (link.getAttribute('href') === currentPath) {
      link.classList.add('active');
      // If in nav-group, expand the group
      const navGroup = link.closest('.nav-group');
      if (navGroup) {
        navGroup.classList.add('show');
      }
    }
  });
}

document.addEventListener("turbo:load", () => {
  setTimeout(() => { initAdmin() }, 10);
});

// Add custom styles for nav-group animations
const style = document.createElement('style');
style.textContent = `
  .nav-group-items {
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.3s ease-out;
  }
  
  .nav-group.show .nav-group-items {
    max-height: 1000px; /* Ajuste conforme necessário */
  }
  
  .nav-group-toggle {
    position: relative;
  }
  
  .nav-group-toggle::after {
    content: '';
    width: 8px;
    height: 8px;
    border-right: 2px solid;
    border-bottom: 2px solid;
    position: absolute;
    right: 16px;
    top: 50%;
    transform: translateY(-50%) rotate(45deg);
    transition: transform 0.3s ease;
  }
  
  .nav-group.show .nav-group-toggle::after {
    transform: translateY(-50%) rotate(-135deg);
  }
`;
document.head.appendChild(style); 