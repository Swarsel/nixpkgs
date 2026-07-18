{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  check,
  elfutils,
  flex,
  libffi,
  llvm,
  pkg-config,
  which,
  zlib,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nvc";
  version = "1.21.1";

  src = fetchFromGitHub {
    owner = "nickg";
    repo = "nvc";
    tag = "r${finalAttrs.version}";
    hash = "sha256-l4eGEDZrAXOhN5hPQLy2TcQEsQ+TTSNZVBFVwNsoQCo=";
  };

  nativeBuildInputs = [
    autoreconfHook
    check
    flex
    pkg-config
    which
  ];

  buildInputs = [
    libffi
    llvm
    zlib
    zstd
  ]
  ++ lib.optionals (lib.meta.availableOn stdenv.hostPlatform elfutils) [
    elfutils
  ];

  configureFlags = [
    "--enable-vhpi"
    "--disable-lto"
  ];

  preConfigure = ''
    mkdir build
    cd build
  '';

  doCheck = true;
  configureScript = "../configure";

  meta = {
    description = "VHDL compiler and simulator";
    homepage = "https://www.nickg.me.uk/nvc/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = lib.platforms.unix;
    mainProgram = "nvc";
  };
})
