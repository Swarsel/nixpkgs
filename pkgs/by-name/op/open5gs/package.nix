{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  cmake,
  curl,
  flex,
  gnutls,
  libgcrypt,
  libidn,
  libmicrohttpd,
  libnghttp2,
  libtins,
  libyaml,
  lksctp-tools,
  meson,
  mongoc,
  mongosh,
  ninja,
  openssl,
  pkg-config,
  talloc,
  usrsctp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "open5gs";
  version = "2.7.7";

  src = fetchFromGitHub {
    owner = "open5gs";
    repo = "open5gs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZK4q6m/9v+us+6dWpi0k188KfFu1b6G9pGE4VGAe4+4=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cmake
    flex
    bison
  ];

  buildInputs = [
    talloc
    mongoc
    libyaml
    libmicrohttpd
    libgcrypt
    libidn
    openssl
    curl
    libtins
    gnutls
    libnghttp2.dev
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    lksctp-tools
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isLinux) [
    usrsctp
  ];

  mesonFlags = [
    "-Dwerror=false"
    "--buildtype=release"
  ];

  preConfigure = ''
    cp -R --no-preserve=mode,ownership ${finalAttrs.diameter} subprojects/freeDiameter
    cp -R --no-preserve=mode,ownership ${finalAttrs.libtins} subprojects/libtins
    cp -R --no-preserve=mode,ownership ${finalAttrs.promc} subprojects/prometheus-client-c
  '';

  postInstall = ''
    cp misc/db/open5gs-dbctl $out/bin
    substituteInPlace $out/bin/open5gs-dbctl \
      --replace "mongosh" "${lib.getExe mongosh}"
  '';

  diameter = fetchFromGitHub {
    hash = "sha256-S8jL+9rW9RDwQc7NU8MOzMe9/iRbshWa2QLqXoiV85Q=";
    owner = "open5gs";
    repo = "freeDiameter";
    rev = "13f5a5996b5fa1a46ed780635c7fc6fcd09b4290"; # r1.5.0
  };

  libtins = fetchFromGitHub {
    hash = "sha256-BxSBNKI+jwI33lN+vmYCYSDAxsVDXS190byAzq6lB/A=";
    owner = "open5gs";
    repo = "libtins";
    rev = "bf22438172d269e6db70e27246dffd8e1f0b96e3"; # r4.5
  };

  promc = fetchFromGitHub {
    hash = "sha256-COZV4UeB7YRfpLwloIfc/WdlTP9huwVfXrJWH4jmvB8=";
    owner = "open5gs";
    repo = "prometheus-client-c";
    rev = "a58ba25bf87a9b1b7c6be4e6f4c62047d620f402"; # open5gs branch
  };

  meta = {
    description = "4G/5G core network components";
    homepage = "https://open5gs.org/";
    changelog = "https://github.com/open5gs/open5gs/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      bot-wxt1221
      xddxdd
    ];

    platforms = lib.platforms.unix;
  };
})
