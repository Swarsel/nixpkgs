{
  binutils,
  cargo,
  faust,
  gcc,
  gnumake,
  libjack2,
  openssl,
  pkg-config,
}:

faust.wrapWithBuildEnv {

  propagatedBuildInputs = [
    libjack2
    cargo
    binutils
    gcc
    gnumake
    openssl
    pkg-config
  ];

  baseName = "faust2jackrust";
}
