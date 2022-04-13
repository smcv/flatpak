foreach file : [
  'README',
  'pubring.gpg',
  'secring.gpg',
]
  # TODO: When we depend on Meson 0.50.0, we can use
  # install : get_option('installed_tests')
  if get_option('installed_tests')
    configure_file(
      input : file,
      output : file,
      copy : true,
      install_dir : installed_testdir / 'test-keyring',
      install_mode : 'rw-r--r--',
    )
  else
    configure_file(
      input : file,
      output : file,
      copy : true,
    )
  endif
endforeach
