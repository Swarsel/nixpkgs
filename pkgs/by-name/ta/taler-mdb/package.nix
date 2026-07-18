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
  libnfc,
  libsodium,
  pkg-config,
  qrencode,
  taler-exchange,
  taler-merchant,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "taler-mdb";
  version = "1.3.0";

  src = fetchgit {
    url = "https://git-www.taler.net/taler-mdb.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bslsC/m75kt8JoIQPp53u64SxghwZloOHehctphpNwI=";
    fetchSubmodules = true;
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
    libnfc
    libsodium
    qrencode
    taler-exchange
    taler-merchant
  ];

  doCheck = true;

  meta = {
    description = "Sales integration with the Multi-Drop-Bus of Snack machines, NFC readers and QR code display";
    homepage = "https://git-www.taler.net/taler-mdb.git";
    license = lib.licenses.agpl3Plus;
    maintainers = [ ];
    mainProgram = "taler-mdb";
    teams = with lib.teams; [ ngi ];
  };
})
