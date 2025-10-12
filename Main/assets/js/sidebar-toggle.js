document.addEventListener('DOMContentLoaded', function() {
  const toggleButton = document.getElementById('toggleSidebar');
  const sidebar = document.querySelector('.sidebar');

  if (!toggleButton || !sidebar) return;

  // Restore last state
  if (localStorage.getItem('sidebarCollapsed') === 'true') {
    sidebar.classList.add('collapsed');
  }

  toggleButton.addEventListener('click', function() {
    sidebar.classList.toggle('collapsed');
    const isCollapsed = sidebar.classList.contains('collapsed');
    localStorage.setItem('sidebarCollapsed', isCollapsed);
  });
});