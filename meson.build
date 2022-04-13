# Copyright 2022 Collabora Ltd.
# SPDX-License-Identifier: LGPL-2.1-or-later

project(
  'Flatpak',
  'c',
  version : '1.13.2',
  default_options: [
    'warning_level=2',
  ],
  meson_version : '>=0.49.0',
)

# TODO: This is redundant with project->version
flatpak_major_version = 1
flatpak_minor_version = 13
flatpak_micro_version = 2
flatpak_extra_version = ''

flatpak_version = '@0@.@1@.@2@@3@'.format(
  flatpak_major_version,
  flatpak_minor_version,
  flatpak_micro_version,
  flatpak_extra_version,
)
flatpak_interface_age = 0
flatpak_binary_age = (
  10000 * flatpak_major_version
  + 100 * flatpak_minor_version
  + flatpak_micro_version
)

required_glib = '2.44'
required_bwrap = '0.5.0'
required_dbus_proxy = '0.1.0'
required_libostree = '2020.8'

gnome = import('gnome')
i18n = import('i18n')
pkgconfig = import('pkgconfig')

if meson.version().version_compare('>=0.56')
  project_build_root = meson.project_build_root()
  project_source_root = meson.project_source_root()
else
  project_build_root = meson.current_build_dir()
  project_source_root = meson.current_source_dir()
endif

if meson.version().version_compare('>=0.58')
  global_source_root = meson.global_source_root()
else
  global_source_root = meson.source_root()
endif

if meson.version().version_compare('>=0.53')
  fs = import('fs')
endif

cc = meson.get_compiler('c')
add_project_arguments('-include', 'config.h', language : 'c')
common_include_directories = include_directories(
  '.',
  'common',
)

# Keep this in sync with ostree, except remove -Wall (part of Meson
# warning_level 2) and -Werror=declaration-after-statement
add_project_arguments(
  cc.get_supported_arguments([
    '-Werror=shadow',
    '-Werror=empty-body',
    '-Werror=strict-prototypes',
    '-Werror=missing-prototypes',
    '-Werror=implicit-function-declaration',
    '-Werror=pointer-arith',
    '-Werror=init-self',
    '-Werror=missing-declarations',
    '-Werror=return-type',
    '-Werror=overflow',
    '-Werror=int-conversion',
    '-Werror=parenthesis',
    '-Werror=incompatible-pointer-types',
    '-Werror=misleading-indentation',
    '-Werror=missing-include-dirs',

    # Meson warning_level=2 would do this, but we are not fully
    # signedness-safe yet
    '-Wno-sign-compare',
    '-Wno-error=sign-compare',

    # Meson warning_level=2 would do this
    '-Wno-cast-function-type',
    '-Wno-error=cast-function-type',

    # Deliberately not warning about these, ability to zero-initialize
    # a struct is a feature
    '-Wno-missing-field-initializers',
    '-Wno-error=missing-field-initializers',

    # Deliberately not warning about these
    '-Wno-unused-parameter',
    '-Wno-error=unused-parameter',
  ]),
  language : 'c',
)
# Flatpak is Linux-specific, so for now we assume that -fvisibility=hidden
# is always supported
add_project_arguments('-fvisibility=hidden', language : 'c')

if (
  cc.has_argument('-Werror=format=2')
  and cc.has_argument('-Werror=format-security')
  and cc.has_argument('-Werror=format-nonliteral')
)
  add_project_arguments([
    '-Werror=format=2',
    '-Werror=format-security',
    '-Werror=format-nonliteral',
  ], language : 'c')
endif

bison = find_program('bison')

libcap_dep = dependency('libcap')

dbus_config_dir = get_option('dbus_config_dir')
if dbus_config_dir == ''
  dbus_config_dir == get_option('sysconfdir') / 'dbus-1' / 'system.d'
endif

dbus_service_dir = get_option('dbus_service_dir')
if dbus_service_dir == ''
  dbus_service_dir == get_option('datadir') / 'dbus-1' / 'system.d'
endif

profile_dir = get_option('profile_dir')
if profile_dir == ''
  profile_dir == get_option('sysconfdir') / 'profile.d'
endif

system_install_dir = get_option('system_install_dir')
if system_install_dir == ''
  system_install_dir = get_option('localstatedir') / 'lib' / 'flatpak'
endif

# TODO: bwrap --version >= 0.5.0
# TODO: xdg-dbus-proxy --version >= 0.1.0
# TODO: AC_CHECK_FUNCS(fdwalk)

if not cc.check_header('sys/xattr.h')
  error('You must have sys/xattr.h from glibc')
endif

libglnx = subproject(
  'libglnx',
  default_options : [
    'warning_level=1',
  ],
)

libglnx_dep = libglnx.get_variable('libglnx_dep')
libarchive_dep = dependency('libarchive', version : '>=2.8.0')
glib_dep = dependency('glib-2.0', version : '>=' + required_glib)
gio_dep = dependency('gio-2.0', version : '>=' + required_glib)
gio_unix_dep = dependency('gio-unix-2.0', version : '>=' + required_glib)
libsoup_dep = dependency('libsoup-2.4')
libxml_dep = dependency('libxml-2.0', version : '>=2.4')
libzstd_dep = dependency('libzstd', version : '>=0.8.1', required : get_option('libzstd'))
dconf_dep = dependency('dconf', version : '>=0.26', required : get_option('dconf'))
libsystemd_dep = dependency('libsystemd', required : get_option('systemd'))
malcontent_dep = dependency('malcontent-0', required : get_option('malcontent'))
polkit_agent_dep = dependency('polkit-agent-1', version : '>=0.98', required : get_option('system_helper'))
build_system_helper = polkit_agent_dep.found()
fuse_dep = dependency('fuse', version : '>=2.9.2')
xau_dep = dependency('xau', required : get_option('xauth'))
libostree_dep = dependency('ostree-1', version : '>=' + required_libostree)
json_glib_dep = dependency('json-glib-1.0')
appstream_dep = dependency('appstream', version : '>=0.12.0')
gdk_pixbuf_dep = dependency('gdk-pixbuf-2.0')
libseccomp_dep = dependency('libseccomp', required : get_option('seccomp'))
base_deps = [glib_dep, gio_dep, gio_unix_dep]

if meson.version().version_compare('>=0.60.0')
  gpgme_dep = dependency('gpgme-pthread', 'gpgme', version : '>=1.1.8')
else
  gpgme_dep = dependency('gpgme-pthread', version : '>=1.1.8', required : false)
  if not gpgme_dep.found()
    gpgme_dep = dependency('gpgme', version : '>=1.1.8')
  endif
endif

if get_option('selinux_module').disabled()
  build_selinux_module = false
else
  if meson.version().version_compare('>=0.53')
    build_selinux_module = fs.is_file('/usr/share/selinux/devel/Makefile')
  else
    build_selinux_module = run_command(
      'test', '-f', '/usr/share/selinux/devel/Makefile',
      check : false,
    ).returncode() == 0
  endif

  if get_option('selinux_module').enabled() and not build_selinux_module
    error('selinux-policy-devel needed to build selinux module')
  endif
endif

if get_option('documentation')
  xsltproc = find_program('xsltproc')
  # TODO: check for -//OASIS//DTD DocBook XML V4.5//EN
  # TODO: check for http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl
endif

if get_option('gir')
  # TODO: GOBJECT_INTROSPECTION_CHECK([1.40.0])
endif

xmlto = find_program('xmlto', required : get_option('docbook_docs'))

cdata = configuration_data()
cdata.set('_GNU_SOURCE', 1)
cdata.set('FLATPAK_COMPILATION', 1)
cdata.set('PACKAGE_MAJOR_VERSION', flatpak_major_version)
cdata.set('PACKAGE_MINOR_VERSION', flatpak_minor_version)
cdata.set('PACKAGE_MICRO_VERSION', flatpak_micro_version)
cdata.set('PACKAGE_EXTRA_VERSION', flatpak_extra_version)
cdata.set_quoted(
  'PACKAGE_STRING',
  '@0@ @1@'.format(meson.project_name(), meson.project_version()),
)
cdata.set_quoted('PACKAGE_VERSION', meson.project_version())
cdata.set_quoted(
  'FLATPAK_BINDIR',
  get_option('prefix') / get_option('bindir'),
)
cdata.set_quoted(
  'FLATPAK_SYSTEMDIR',
  get_option('prefix') / system_install_dir,
)
cdata.set_quoted(
  'FLATPAK_CONFIGDIR',
  get_option('prefix') / get_option('sysconfdir') / 'flatpak',
)
cdata.set_quoted(
  'FLATPAK_BASEDIR',
  get_option('prefix') / get_option('datadir') / 'flatpak',
)
cdata.set_quoted(
  'FLATPAK_TRIGGERDIR',
  get_option('prefix') / get_option('datadir') / 'flatpak' / 'triggers',
)
cdata.set_quoted('LIBEXECDIR', get_option('prefix') / get_option('libexecdir'))
cdata.set_quoted('DATADIR', get_option('prefix') / get_option('datadir'))
cdata.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
cdata.set_quoted('SYSTEM_FONTS_DIR', get_option('system_fonts_dir'))
cdata.set_quoted('SYSTEM_HELPER_USER', get_option('system_helper_user'))
cdata.set_quoted(
  'SYSTEM_FONT_CACHE_DIRS',
  ':'.join(get_option('system_font_cache_dirs')),
)
cdata.set_quoted('G_LOG_DOMAIN', 'flatpak')
cdata.set_quoted('GETTEXT_PACKAGE', 'flatpak')

if get_option('system_bubblewrap') == ''
  cdata.set_quoted('HELPER', get_option('prefix') / get_option('libexecdir') / 'flatpak-bwrap')
else
  cdata.set_quoted('HELPER', get_option('system_bubblewrap'))
endif

if get_option('system_dbus_proxy') == ''
  cdata.set_quoted('DBUSPROXY', get_option('prefix') / get_option('libexecdir') / 'flatpak-dbus-proxy')
else
  cdata.set_quoted('DBUSPROXY', get_option('system_dbus_proxy'))
endif

# Flatpak is Linux-specific, so we assume this is always supported
cdata.set('FLATPAK_EXTERN', '__attribute__((visibility("default"))) extern')

if glib_dep.version().version_compare('>=2.60')
  # Ignore massive GTimeVal deprecation warnings in 2.62
  cdata.set('GLIB_VERSION_MIN_REQUIRED', 'GLIB_VERSION_2_60')
endif

if appstream_dep.version().version_compare('>=0.14.0')
  cdata.set('HAVE_APPSTREAM_0_14_0', 1)
endif

if libseccomp_dep.found()
  cdata.set('ENABLE_SECCOMP', 1)
endif

if xau_dep.found()
  cdata.set('ENABLE_XAUTH', 1)
endif

if not get_option('sandboxed_triggers')
  cdata.set('DISABLE_SANDBOXED_TRIGGERS', 1)
endif

if cc.has_function(
  'archive_read_support_filter_all',
  dependencies : libarchive_dep,
  prefix : '#include <archive.h>',
)
  cdata.set('HAVE_ARCHIVE_READ_SUPPORT_FILTER_ALL', 1)
endif

configure_file(
  output : 'config.h',
  configuration : cdata,
)

if meson.version().version_compare('>=0.53.0')
  # TODO: When we depend on Meson >= 0.57.0, we can print dependencies
  # as themselves rather than as booleans if we want to.
  summary(
    {
      'Build system helper' : build_system_helper,
      'Build selinux module' : build_selinux_module,
      'Build bubblewrap' : (get_option('system_bubblewrap') == ''),
      'Build dbus-proxy' : (get_option('system_dbus_proxy') == ''),
      'Use sandboxed triggers' : get_option('sandboxed_triggers'),
      'Use seccomp' : libseccomp_dep.found(),
      'Privileged group' : get_option('privileged_group'),
      'Use dconf' : dconf_dep.found(),
      'Use libsystemd' : libsystemd_dep.found(),
      'Use libmalcontent' : malcontent_dep.found(),
      'Use libzstd' : libzstd_dep.found(),
      'Use auto sideloading' : get_option('auto_sideloading'),
    },
    bool_yn : true,
  )
endif

if get_option('system_bubblewrap') == ''
  subproject(
    'bubblewrap',
    default_options : [
      'program_prefix=flatpak-',
    ],
  )
endif

if get_option('system_dbus_proxy') == ''
  subproject(
    'dbus-proxy',
    default_options : [
      'warning_level=1',
      'program_prefix=flatpak-',
    ],
  )
endif

# Used for .service files in multiple subdirectories
service_conf_data = configuration_data()
service_conf_data.set('libexecdir', get_option('prefix') / get_option('libexecdir'))
service_conf_data.set('localstatedir', get_option('prefix') / get_option('localstatedir'))
service_conf_data.set('media_dir', get_option('prefix') / get_option('run_media_dir'))
service_conf_data.set('extraargs', '')

subdir('common')
subdir('data')

subdir('app')
subdir('icon-validator')
subdir('oci-authenticator')
subdir('portal')
subdir('revokefs')
subdir('session-helper')

subdir('completion')
subdir('doc')
subdir('po')
subdir('triggers')

if get_option('auto_sideloading')
  subdir('sideload-repos-systemd')
endif

if build_selinux_module
  subdir('selinux')
endif

if build_system_helper
  subdir('system-helper')
endif

subdir('tests')

pkgconfig_variables = []

# TODO: These can be dropped when we require Meson >= 0.62.0
pkgconfig_variables += 'exec_prefix=${prefix}'
pkgconfig_variables += 'datadir=' + ('${prefix}' / get_option('datadir'))

pkgconfig_variables += 'datarootdir=' + ('${prefix}' / get_option('datadir'))
pkgconfig_variables += 'interfaces_dir=${datadir}/dbus-1/interfaces/'

pkgconfig.generate(
  libflatpak,
  description : 'Application sandboxing framework',
  subdirs : 'flatpak',
  requires : [
    'glib-2.0',
    'gio-2.0',
    'ostree-1',
  ],
  requires_private : [
    'gio-unix-2.0',
  ],
  variables : pkgconfig_variables,
)
