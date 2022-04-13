executable(
  'flatpak-oci-authenticator',
  sources : ['flatpak-oci-authenticator.c'],
  dependencies : base_deps + [
    json_glib_dep,
    libglnx_dep,
    libostree_dep,
    libsoup_dep,
  ],
  include_directories : [
    common_include_directories,
    include_directories('.'),
  ],
  link_with : [
    libflatpak_common,
    libflatpak_common_base,
  ],
)

configure_file(
  input : 'flatpak-oci-authenticator.service.in',
  output : 'flatpak-oci-authenticator.service',
  configuration : service_conf_data,
  install_dir : get_option('systemduserunitdir'),
)

configure_file(
  input : 'org.flatpak.Authenticator.Oci.service.in',
  output : 'org.flatpak.Authenticator.Oci.service',
  configuration : service_conf_data,
  install_dir : get_option('dbus_service_dir'),
)
