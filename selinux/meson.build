custom_target(
  'flatpak.pp.bz2',
  input : ['flatpak.te', 'flatpak.fc'],
  output : ['flatpak.pp.bz2'],
  build_by_default : true,
  command : [
    files('build-selinux.sh'),
    '@OUTPUT0@',
    '@INPUT@',
  ],
  install_dir : get_option('datadir') / 'selinux' / 'packages',
)

install_data(
  'flatpak.if',
  install_dir : get_option('datadir') / 'selinux' / 'include' / 'contrib',
)
