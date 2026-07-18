{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  geoip,
  gnutls,
  gperf,
  guile,
  ipcalc,
  libev,
  libseccomp,
  libxcrypt,
  lz4,
  nettle,
  oath-toolkit,
  pam,
  pkg-config,
  protobufc,
  readline,
  ronn,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ocserv";
  version = "1.4.0";

  src = fetchFromGitLab {
    owner = "openconnect";
    repo = "ocserv";
    tag = finalAttrs.version;
    hash = "sha256-u6gk1foCmx88iw7vMB9If0zHpd1xpzGsfHx2SxgXSX0=";
  };

  nativeBuildInputs = [
    autoreconfHook
    gperf
    pkg-config
    ronn
  ];

  buildInputs = [
    ipcalc
    nettle
    gnutls
    libev
    protobufc
    guile
    geoip
    libseccomp
    readline
    lz4
    pam
    libxcrypt
    oath-toolkit
  ];

  meta = {
    description = "OpenConnect VPN server (ocserv), a server for the OpenConnect VPN client";
    homepage = "https://gitlab.com/openconnect/ocserv";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ neverbehave ];
  };
})
