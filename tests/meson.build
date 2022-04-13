installed_testdir = get_option('prefix') / get_option('libexecdir') / 'installed-tests' / 'Flatpak'

tests_environment = environment()
tests_environment.set('FLATPAK_CONFIG_DIR', '/dev/null')
tests_environment.set(
  'FLATPAK_PORTAL',
  project_build_root / 'portal' / 'flatpak-portal',
)
tests_environment.set(
  'FLATPAK_REVOKEFS_FUSE',
  project_build_root / 'revokefs' / 'revokefs-fuse',
)
tests_environment.set('FLATPAK_TESTS_DEBUG', '1')
tests_environment.set('FLATPAK_TESTS_STRICT_TAP', '1')
tests_environment.set('FLATPAK_TRIGGERSDIR', project_source_root / 'triggers')
tests_environment.set(
  'FLATPAK_VALIDATE_ICON',
  project_build_root / 'icon-validator' / 'flatpak-validate-icon',
)
tests_environment.set('G_TEST_BUILDDIR', meson.current_build_dir())
tests_environment.set('G_TEST_SRCDIR', meson.current_source_dir())
tests_environment.prepend('GI_TYPELIB_PATH', project_build_root / 'common')
tests_environment.prepend('LD_LIBRARY_PATH', project_build_root / 'common')
tests_environment.prepend('PATH', project_build_root / 'app')

if get_option('system_bubblewrap') == ''
  tests_environment.set('FLATPAK_BWRAP', project_build_root / 'subprojects' / 'bubblewrap' / 'flatpak-bwrap')
else
  tests_environment.set('FLATPAK_BWRAP', get_option('system_bubblewrap'))
endif

if get_option('system_dbus_proxy') == ''
  tests_environment.set('FLATPAK_DBUSPROXY', project_build_root / 'subprojects' / 'dbus-proxy' / 'flatpak-dbus-proxy')
else
  tests_environment.set('FLATPAK_DBUSPROXY', get_option('system_dbus_proxy'))
endif

runtime_repo = custom_target(
  'runtime-repo',
  build_by_default : true,
  command : [
    files('make-runtime-repos'),
    project_build_root / 'app',
    files('make-test-runtime.sh'),
    project_build_root / 'tests/runtime-repo',
    '@OUTPUT@',
  ],
  depends : [flatpak_exe],
  output : 'runtime-repo.stamp',
)

libtestlib = static_library(
  'testlib',
  'testlib.c',
  include_directories : [
    common_include_directories,
  ],
  dependencies : base_deps + [libglnx_dep],
  install : false,
)

c_tests = [
  ['testcommon', {}],
  ['testlibrary', {
    'dependencies' : base_deps + [
      fuse_dep,
      libglnx_dep,
      libostree_dep,
    ],
    'extra_sources' : [
      'can-use-fuse.c',
      'testlib.c',
    ],
    'link_with' : [libflatpak],
    'timeout' : 150,
  }],
  ['test-context', {}],
  ['test-exports', {}],
  ['test-instance', {}],
  ['test-portal', {
    'extra_sources' : [
      portal_gdbus[0],
    ],
  }],
]

foreach testcase : c_tests
  name = testcase[0]
  options = testcase[1]

  exe = executable(
    name,
    sources : [name + '.c'] + options.get('extra_sources', []),
    dependencies : options.get('dependencies', base_deps + [
      appstream_dep,
      json_glib_dep,
      libglnx_dep,
      libostree_dep,
      libsoup_dep,
    ]),
    include_directories : [
      common_include_directories,
      include_directories('../app'),
    ],
    link_with : options.get('link_with', [
      libflatpak_app,
      libflatpak_common,
      libflatpak_common_base,
      libtestlib,
    ] + options.get('extra_link_with', [])),
  )

  if meson.version().version_compare('>=0.50.0')
    test(
      name,
      files(project_source_root / 'buildutil/tap-test'),
      args : [exe],
      depends : runtime_repo,
      env : tests_environment,
      protocol : 'tap',
      timeout : options.get('timeout', 30),
    )
  else
    # Fall back to using exit status rather than TAP
    test(
      name,
      files(project_source_root / 'buildutil/tap-test'),
      args : [exe],
      depends : runtime_repo,
      env : tests_environment,
      timeout : options.get('timeout', 30),
    )
  endif
endforeach

executable(
  'hold-lock',
  'hold-lock.c',
  dependencies : base_deps + [libglnx_dep],
  include_directories : [
    common_include_directories,
  ],
)

executable(
  'httpcache',
  'httpcache.c',
  dependencies : base_deps + [
    json_glib_dep,
    libglnx_dep,
    libostree_dep,
    libsoup_dep,
  ],
  include_directories : [
    common_include_directories,
  ],
  link_with : [
    libflatpak_common,
    libflatpak_common_base,
  ],
)

executable(
  'mock-flatpak',
  'mock-flatpak.c',
  dependencies : base_deps + [
    appstream_dep,
    json_glib_dep,
    libglnx_dep,
    libostree_dep,
    libsoup_dep,
  ],
  include_directories : [
    common_include_directories,
  ],
  link_with : [
    libflatpak_app,
    libflatpak_common,
    libflatpak_common_base,
    libtestlib,
  ],
)

executable(
  'test-update-portal',
  sources : [
    'test-update-portal.c',
  ] + portal_gdbus,
  dependencies : base_deps,
  include_directories : [
    common_include_directories,
  ],
)

executable(
  'test-portal-impl',
  'test-portal-impl.c',
  dependencies : base_deps,
  include_directories : [
    common_include_directories,
  ],
)

executable(
  'test-authenticator',
  'test-authenticator.c',
  dependencies : base_deps + [
    libglnx_dep,
  ],
  include_directories : [
    common_include_directories,
  ],
  link_with : [
    libflatpak_common,
    libflatpak_common_base,
  ],
)

executable(
  'try-syscall',
  'try-syscall.c',
)

executable(
  'list-unused',
  'list-unused.c',
  dependencies : base_deps + [
    libglnx_dep,
    libostree_dep,
  ],
  include_directories : [
    common_include_directories,
  ],
  link_with : [
    libflatpak_common,
    libflatpak_common_base,
  ],
)

subdir('share/xdg-desktop-portal/portals')
subdir('services')
subdir('test-keyring')
subdir('test-keyring2')

configure_file(
  input : 'package_version.txt.in',
  output : 'package_version.txt',
  configuration : {
    'PACKAGE_VERSION' : meson.project_version(),
  }
)

if get_option('installed_tests')
  subdir('installed-services')
endif

install_data(
  'http-utils-test-server.py',
  'make-multi-collection-id-repo.sh',
  'make-test-app.sh',
  'make-test-runtime.sh',
  'oci-registry-client.py',
  'oci-registry-server.py',
  'test-webserver.sh',
  'test-wrapper.sh',
  'web-server.py',

  install_dir : installed_testdir,
  install_mode : 'rwxr-xr-x',
)

install_data(
  'libtest.sh',
  'org.flatpak.Authenticator.test.service.in',
  'org.freedesktop.impl.portal.desktop.test.service.in',
  'org.test.Hello.png',
  'session.conf.in',
  'test.filter',
  'test.portal.in',

  install_dir : installed_testdir,
  install_mode : 'rw-r--r--',
)

shared_module(
  'preload',
  'libpreload.c',
  link_args : ['-Wl,-no-undefined'],
)

wrapped_tests = []
subdir('test-matrix')

foreach testcase : wrapped_tests
  name = testcase['name']
  script = testcase.get('script', name)

  timeout = {
    'test-bundle.sh' : 60,
    'test-oci-registry.sh' : 60,
    'test-repo.sh' : 300,
    'test-run.sh' : 90,
    'test-summaries.sh' : 60,
    'test-unused.sh' : 90,
    'test-update-portal.sh' : 90,
  }.get(script, 30)

  is_parallel = {
    'test-history.sh' : false,
  }.get(script, true)

  if meson.version().version_compare('>=0.50.0')
    test(
      name,
      files(project_source_root / 'buildutil/tap-test'),
      args : [meson.current_source_dir() / name],
      depends : runtime_repo,
      env : tests_environment,
      is_parallel : is_parallel,
      protocol : 'tap',
      timeout : timeout,
    )
  else
    # Fall back to using exit status rather than TAP
    test(
      name,
      files(project_source_root / 'buildutil/tap-test'),
      args : [meson.current_source_dir() / name],
      depends : runtime_repo,
      env : tests_environment,
      is_parallel : is_parallel,
      timeout : timeout,
    )
  endif
endforeach
