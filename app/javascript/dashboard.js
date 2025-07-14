// Inicialização padrão CoreUI para dropdowns
function initCoreUIDropdowns() {
  document.querySelectorAll('[data-coreui-toggle="dropdown"], .dropdown-toggle').forEach(function(el) {
    // Dispose de instância antiga
    var instance = coreui.Dropdown.getInstance(el);
    if (instance) instance.dispose();
    // Cria nova instância
    new coreui.Dropdown(el);
  });
}

// Inicialização manual dos nav groups da sidenav
function initSidenavNavGroups() {
  document.querySelectorAll('.nav-group-toggle').forEach(function(el) {
    // Remove listeners antigos, se houver
    if (el._navGroupListener) el.removeEventListener('click', el._navGroupListener);

    el._navGroupListener = function(e) {
      e.preventDefault();
      var group = el.closest('.nav-group');
      if (group) {
        group.classList.toggle('show');
      }
    };
    el.addEventListener('click', el._navGroupListener);
  });
}

document.addEventListener('DOMContentLoaded', function() {
  initCoreUIDropdowns();
  initSidenavNavGroups();
});

document.addEventListener('turbo:render', function() {
  initCoreUIDropdowns();
  initSidenavNavGroups();
});

