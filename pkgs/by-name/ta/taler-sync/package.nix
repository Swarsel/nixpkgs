{
  lib,
  stdenv,
  autoreconfHook,
  curlWithGnuTls,
  fetchgit,
  gnunet,
  jansson,
  libgcrypt,
  libmicrohttpd,
  libpq,
  libsodium,
  libtool,
  pkg-config,
  runtimeShell,
  taler-exchange,
  taler-merchant,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "taler-sync";
  version = "1.3.0";

  src = fetchgit {
    url = "https://git-www.taler.net/sync.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1m26ORKsN0GHJWQ/5gtMO3x1ng+GsZK9Y80413vF5pI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    libgcrypt
    pkg-config
  ];

  buildInputs = [
    curlWithGnuTls
    gnunet
    jansson
    libgcrypt
    libmicrohttpd
    libpq
    libsodium
    libtool
    taler-exchange
    taler-merchant
  ];

  preFixup = ''
    substituteInPlace "$out/bin/sync-dbconfig" \
      --replace-fail "/bin/bash" "${runtimeShell}"
  '';

  meta = {
    description = "Backup and synchronization service";
    homepage = "https://git-www.taler.net/sync.git";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = lib.platforms.linux;
    teams = with lib.teams; [ ngi ];
  };
})
