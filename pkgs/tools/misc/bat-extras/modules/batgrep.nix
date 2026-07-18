{
  buildBatExtrasPkg,
  coreutils,
  less,
  ripgrep,
}:
buildBatExtrasPkg {
  # The tests are broken with the new bat 0.26.0
  # https://github.com/eth-p/bat-extras/issues/143
  doCheck = false;

  dependencies = [
    less
    coreutils
    ripgrep
  ];

  name = "batgrep";
  meta.description = "Quickly search through and highlight files using ripgrep";
}
