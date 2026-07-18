{
  lib,
  stdenv,
  autoreconfHook,
  curl,
  fetchgit,
  gnunet,
  jansson,
  libgcrypt,
  libmicrohttpd,
  libsodium,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "taler-twister";
  version = "1.0.0";

  src = fetchgit {
    url = "https://git-www.taler.net/twister.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ir+kU9bCWwhqR88hmNHB5cm1DXOQowI5y6GdhWpX/L0=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    curl
    gnunet
    jansson
    libgcrypt
    libmicrohttpd
    libsodium
  ];

  doInstallCheck = true;

  meta = {
    description = "Fault injector for HTTP traffic";
    homepage = "https://git-www.taler.net/twister.git";
    license = lib.licenses.agpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "twister";
    teams = with lib.teams; [ ngi ];
  };
})
