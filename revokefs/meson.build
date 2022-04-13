executable(
  'revokefs-fuse',
  install_dir : get_option('libexecdir'),
  sources : [
    'main.c',
    'writer.c',
  ],
  dependencies : base_deps + [
    fuse_dep,
    libglnx_dep,
  ],
)

executable(
  'revokefs-demo',
  install : false,
  sources : ['demo.c'],
  dependencies : base_deps,
)
