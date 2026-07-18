{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  bitlbee,
  libgcrypt,
  libtool,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bitlbee-steam";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "bitlbee";
    repo = "bitlbee-steam";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WPUelgClqGiKmClIkGEMaBbtUrBlwN85L4Rs/qpIOYg=";
  };

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
  ];

  buildInputs = [
    bitlbee
    libtool
    libgcrypt
  ];

  # Source uses `bool` as a variable name, reserved in C23.
  env.NIX_CFLAGS_COMPILE = "-std=gnu17";

  preConfigure = ''
    export BITLBEE_PLUGINDIR=$out/lib/bitlbee
    ./autogen.sh
  '';

  meta = {
    description = "Steam protocol plugin for BitlBee";
    homepage = "https://github.com/jgeboski/bitlbee-steam";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
})
