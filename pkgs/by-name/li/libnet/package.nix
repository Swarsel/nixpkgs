{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  bash,
  libtool,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnet";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "libnet";
    repo = "libnet";
    rev = "v${finalAttrs.version}";
    hash = "sha256-P3LaDMMNPyEnA8nO1Bm7H0mW/hVBr0cFdg+p2JmWcGI=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    libtool
  ];

  buildInputs = [
    bash
  ];

  preConfigure = "./autogen.sh";

  preFixup = ''
    moveToOutput bin/libnet-config "$dev"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Portable framework for low-level network packet construction";
    homepage = "https://github.com/libnet/libnet";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    mainProgram = "libnet-config";
  };
})
