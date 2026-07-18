{
  lib,
  stdenv,
  fetchFromGitHub,
  asio,
  cmake,
  fmt,
  gnutls,
  jsoncpp,
  libargon2,
  llhttp,
  msgpack-cxx,
  nettle,
  nix-update-script,
  openssl,
  pkg-config,
  readline,
  restinio,
  enableProxyServerAndClient ? false,
  enablePushNotifications ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opendht";
  version = "3.5.4";

  src = fetchFromGitHub {
    owner = "savoirfairelinux";
    repo = "opendht";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mnnd6yATIk/TEuFG/M98d+pfeh42IKWBBYjkTP52xeM=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
    "man"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    asio
    fmt
    nettle
    gnutls
    msgpack-cxx
    readline
    libargon2
  ]
  ++ lib.optionals enableProxyServerAndClient [
    jsoncpp
    restinio
    llhttp
    openssl
  ];

  cmakeFlags =
    lib.optionals enableProxyServerAndClient [
      "-DOPENDHT_PROXY_SERVER=ON"
      "-DOPENDHT_PROXY_CLIENT=ON"
    ]
    ++ lib.optionals enablePushNotifications [
      "-DOPENDHT_PUSH_NOTIFICATIONS=ON"
    ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=v(.+)" ];
  };

  meta = {
    description = "C++11 Kademlia distributed hash table implementation";
    homepage = "https://github.com/savoirfairelinux/opendht";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      taeer
      olynch
      thoughtpolice
    ];

    platforms = lib.platforms.unix;
  };
})
