{
  lib,
  stdenv,
  fetchFromGitHub,
  libtermkey,
  libtool,
  perl,
  pkg-config,
  unibilium,
}:
let
  version = "0.4.5";
in
stdenv.mkDerivation {
  inherit version;
  pname = "libtickit";

  src = fetchFromGitHub {
    owner = "leonerd";
    repo = "libtickit";
    rev = "v${version}";
    hash = "sha256-q8JMNFxmnyOiUso4nXLZjJIBFYR/EF6g45lxVeY0f1s=";
  };

  patches = [
    # Disabled on darwin, since test assumes TERM=linux
    ./001-skip-test-18term-builder-on-macos.patch
  ];

  nativeBuildInputs = [
    pkg-config
    libtool
  ];

  buildInputs = [
    libtermkey
    unibilium
  ];

  makeFlags = [
    "LIBTOOL=${lib.getExe libtool}"
  ];

  doCheck = true;
  nativeCheckInputs = [ perl ];
  enableParallelBuilding = true;

  installFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  meta = {
    description = "Terminal interface construction kit";

    longDescription = ''
      This library provides an abstracted mechanism for building interactive full-screen terminal
      programs. It provides a full set of output drawing functions, and handles keyboard and mouse
      input events.
    '';

    homepage = "https://www.leonerd.org.uk/code/libtickit/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onemoresuza ];
    platforms = lib.platforms.unix;
  };
}
