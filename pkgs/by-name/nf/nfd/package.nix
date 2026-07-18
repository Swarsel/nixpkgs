{
  lib,
  stdenv,
  fetchFromGitHub,
  boost186,
  libpcap,
  ndn-cxx,
  openssl,
  pkg-config,
  sphinx,
  systemd,
  wafHook,
  websocketpp,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
  withWebSocket ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nfd";
  version = "24.07";

  src = fetchFromGitHub {
    owner = "named-data";
    repo = "NFD";
    rev = "NFD-${finalAttrs.version}";
    hash = "sha256-HbKPO3gwQWOZf4QZE+N7tAiqsNl1GrcwE4EUGjWmf5s=";
  };

  nativeBuildInputs = [
    pkg-config
    sphinx
    wafHook
  ];

  buildInputs = [
    libpcap
    ndn-cxx
    openssl
  ]
  ++ lib.optional withWebSocket websocketpp
  ++ lib.optional withSystemd systemd;

  prePatch = lib.optional withWebSocket ''
    ln -s ${websocketpp}/include/websocketpp websocketpp
  '';

  wafConfigureFlags = [
    "--boost-includes=${boost186.dev}/include"
    "--boost-libs=${boost186.out}/lib"
  ]
  ++ lib.optional (!withWebSocket) "--without-websocket";

  meta = {
    description = "Named Data Networking (NDN) Forwarding Daemon";
    homepage = "https://named-data.net/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ bertof ];
    platforms = lib.platforms.unix;
  };
})
