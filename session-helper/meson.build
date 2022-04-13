executable(
  'flatpak-session-helper',
  install_dir : get_option('libexecdir'),
  sources : ['flatpak-session-helper.c'],
  dependencies : base_deps + [libglnx_dep],
  include_directories : [
    common_include_directories,
  ],
  link_with : [libflatpak_common_base],
)

configure_file(
  input : 'flatpak-session-helper.service.in',
  output : 'flatpak-session-helper.service',
  configuration : service_conf_data,
  install_dir : get_option('systemduserunitdir'),
)

configure_file(
  input : 'org.freedesktop.Flatpak.service.in',
  output : 'org.freedesktop.Flatpak.service',
  configuration : service_conf_data,
  install_dir : get_option('dbus_service_dir'),
)
