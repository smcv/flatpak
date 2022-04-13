permission_gdbus = gnome.gdbus_codegen(
  'flatpak-permission-dbus',
  sources: [
    '../data/org.freedesktop.impl.portal.PermissionStore.xml',
  ],
  interface_prefix : 'org.freedesktop.impl.portal',
  namespace : 'XdpDbus',
)

portal_gdbus = gnome.gdbus_codegen(
  'flatpak-portal-dbus',
  sources: [
    '../data/org.freedesktop.portal.Flatpak.xml',
  ],
  interface_prefix : 'org.freedesktop.portal',
  namespace : 'Portal',
)

executable(
  'flatpak-portal',
  install_dir : get_option('libexecdir'),
  include_directories : [
    common_include_directories,
    include_directories('.'),
  ],
  sources : [
    'flatpak-portal.c',
    'flatpak-portal-app-info.c',
    'portal-impl.c',
    '../common/flatpak-portal-error.c',
  ] + permission_gdbus + portal_gdbus,
  dependencies : base_deps + [
    json_glib_dep,
    libglnx_dep,
    libostree_dep,
    libsoup_dep,
  ],
  link_with : [
    libflatpak_common,
    libflatpak_common_base,
  ],
)

configure_file(
  input : 'flatpak-portal.service.in',
  output : 'flatpak-portal.service',
  configuration : service_conf_data,
  install_dir : get_option('systemduserunitdir'),
)

configure_file(
  input : 'org.freedesktop.portal.Flatpak.service.in',
  output : 'org.freedesktop.portal.Flatpak.service',
  configuration : service_conf_data,
  install_dir : get_option('dbus_service_dir'),
)
