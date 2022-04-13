public_headers = [
  'flatpak-bundle-ref.h',
  'flatpak-error.h',
  'flatpak-installation.h',
  'flatpak-installed-ref.h',
  'flatpak-instance.h',
  'flatpak-portal-error.h',
  'flatpak-ref.h',
  'flatpak-related-ref.h',
  'flatpak-remote-ref.h',
  'flatpak-remote.h',
  'flatpak-transaction.h',
  'flatpak.h',
]

flatpak_version_macros = configure_file(
  input : 'flatpak-version-macros.h.in',
  output : 'flatpak-version-macros.h',
  configuration : {
    'FLATPAK_MAJOR_VERSION' : flatpak_major_version,
    'FLATPAK_MINOR_VERSION' : flatpak_minor_version,
    'FLATPAK_MICRO_VERSION' : flatpak_micro_version,
  },
)

# TODO: Can we use mkenums_simple?
enums = gnome.mkenums(
  'flatpak-enum-types',
  c_template : 'flatpak-enum-types.c.template',
  h_template : 'flatpak-enum-types.h.template',
  install_header : true,
  sources : public_headers,
)

flatpak_gdbus = gnome.gdbus_codegen(
  'flatpak-dbus-generated',
  sources: [
    '../data/org.freedesktop.Flatpak.xml',
    '../data/org.freedesktop.Flatpak.Authenticator.xml',
  ],
  interface_prefix : 'org.freedesktop.Flatpak.',
  namespace : 'Flatpak',
)

flatpak_document_gdbus = gnome.gdbus_codegen(
  'flatpak-document-dbus-generated',
  sources: [
    '../data/org.freedesktop.portal.Documents.xml',
  ],
  interface_prefix : 'org.freedesktop.portal.',
  namespace : 'XdpDbus',
)

systemd_gdbus = gnome.gdbus_codegen(
  'flatpak-systemd-dbus-generated',
  sources: [
    '../data/org.freedesktop.systemd1.xml',
  ],
  interface_prefix : 'org.freedesktop.systemd1.',
  namespace : 'Systemd',
)

variant_schema_compiler_command = [
  global_source_root / 'subprojects' / 'variant-schema-compiler' / 'variant-schema-compiler',
]

if get_option('internal_checks')
  variant_schema_compiler_command += ['--internal-validation']
endif

variant_schema_compiler_command += [
  '--outfile', '@OUTPUT0@',
  '--outfile-header', '@OUTPUT1@',
  '--prefix', 'var',
  '@INPUT@',
]

flatpak_variant = custom_target(
  'flatpak-variant-private.h',
  input : [
    '../data/flatpak-variants.gv',
  ],
  output : [
    'flatpak-variant-impl-private.h',
    'flatpak-variant-private.h',
  ],
  build_by_default : true,
  command : variant_schema_compiler_command,
)

libflatpak_common_base = static_library(
  'flatpak-common-base',
  sources : [
    'flatpak-utils-base.c',
    'flatpak-utils-base-private.h',
  ] + flatpak_gdbus + flatpak_document_gdbus,
  include_directories : [
    common_include_directories,
  ],
  dependencies : base_deps + [libglnx_dep],
  install : false,
)

sources = [
  'flatpak-appdata.c',
  'flatpak-auth.c',
  'flatpak-bundle-ref.c',
  'flatpak-bwrap.c',
  'flatpak-chain-input-stream.c',
  'flatpak-context.c',
  'flatpak-dir.c',
  'flatpak-error.c',
  'flatpak-exports.c',
  'flatpak-installation.c',
  'flatpak-installed-ref.c',
  'flatpak-instance.c',
  'flatpak-json-oci.c',
  'flatpak-json.c',
  'flatpak-oci-registry.c',
  'flatpak-portal-error.c',
  'flatpak-progress.c',
  'flatpak-prune.c',
  'flatpak-ref-utils.c',
  'flatpak-ref.c',
  'flatpak-related-ref.c',
  'flatpak-remote-ref.c',
  'flatpak-remote.c',
  'flatpak-run.c',
  'flatpak-transaction.c',
  'flatpak-utils-http.c',
  'flatpak-utils.c',
  'flatpak-zstd-decompressor.c',
] + enums + public_headers + systemd_gdbus

if malcontent_dep.found()
  sources += ['flatpak-parental-controls.c']
endif

libflatpak_common = static_library(
  'flatpak-common',
  include_directories : [
    common_include_directories,
  ],
  dependencies : [
    base_deps,
    dconf_dep,
    gpgme_dep,
    json_glib_dep,
    libarchive_dep,
    libglnx_dep,
    libostree_dep,
    libseccomp_dep,
    libsoup_dep,
    libsystemd_dep,
    libxml_dep,
    libzstd_dep,
    malcontent_dep,
    polkit_agent_dep,
    xau_dep,
  ],
  link_with : [
    libflatpak_common_base,
  ],
  sources : sources + [
    flatpak_variant[0],
    flatpak_variant[1],
  ],
  install : false,
)

libflatpak = library(
  'flatpak',
  include_directories : [
    common_include_directories,
  ],
  link_args : ['-export-dynamic'],
  soversion : '0',
  version : '0.@0@.0'.format(flatpak_binary_age),
  sources : [
    'flatpak.c'
  ],
  link_whole : [
    libflatpak_common_base,
    libflatpak_common,
  ]
)

test_libflatpak = executable(
  'test-libflatpak',
  'test-lib.c',
  include_directories : [
    common_include_directories,
  ],
  dependencies : base_deps + [libglnx_dep],
  link_with : [
    libflatpak,
  ],
  install : false,
)

if get_option('gir')
  gnome.generate_gir(
    libflatpak,
    export_packages : 'flatpak',
    extra_args : [
      '-DFLATPAK_EXTERN=extern',
      '-DFLATPAK_COMPILATION=1',
      '--warn-all',
    ],
    header : 'flatpak.h',
    identifier_prefix : 'Flatpak',
    includes : ['GObject-2.0', 'Gio-2.0'],
    link_with : [libflatpak],
    namespace : 'Flatpak',
    nsversion : '1.0',
    sources : [enums, public_headers, sources, flatpak_version_macros],
    symbol_prefix : 'flatpak',
  )
endif
