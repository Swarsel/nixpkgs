{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  check,
  pkg-config,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "netmask";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "tlby";
    repo = "netmask";
    rev = "v${finalAttrs.version}";
    hash = "sha256-BXCZsk+52nygxtY1s4C79WCwy/iOSwgRnQYnauWGipQ=";
  };

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    pkg-config
  ];

  buildInputs = [ texinfo ];
  doCheck = true;
  nativeCheckInputs = [ check ];

  meta = {
    description = "IP address formatting tool";
    homepage = "https://github.com/tlby/netmask";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.jensbin ];
    platforms = lib.platforms.unix;
    mainProgram = "netmask";
  };
})
