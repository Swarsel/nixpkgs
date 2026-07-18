{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  autoreconfHook,
  avahi,
  bison,
  config,
  curl,
  ffmpeg,
  flex,
  gettext,
  gnutls,
  gperf,
  json_c,
  libconfuse,
  libevent,
  libgcrypt,
  libgpg-error,
  libplist,
  libpulseaudio,
  libsodium,
  libtool,
  libunistring,
  libwebsockets,
  libxml2,
  nix-update-script,
  pkg-config,
  protobufc,
  sqlite,
  zlib,
  chromecastSupport ? config.chromecast or stdenv.hostPlatform.isLinux,
  pulseSupport ? config.pulseaudio or stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "owntone";
  version = "29.2";

  src = fetchFromGitHub {
    owner = "owntone";
    repo = "owntone-server";
    tag = finalAttrs.version;
    hash = "sha256-cCbCShIgopm3HhNVyvr6Q8fe8LkxwNE/51/0qkS27WE=";
  };

  patches = [
    ./gettext-0.25.patch
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    autoreconfHook
    bison
    flex
    libtool
    gperf
    pkg-config
  ];

  buildInputs = [
    avahi
    curl
    ffmpeg
    gettext
    json_c
    libconfuse
    libevent
    libgcrypt
    libgpg-error
    libplist
    libsodium
    libunistring
    libwebsockets
    libxml2
    protobufc
    sqlite
    zlib
  ]
  ++ lib.optionals chromecastSupport [ gnutls ]
  ++ lib.optionals pulseSupport [ libpulseaudio ];

  configureFlags =
    lib.optionals chromecastSupport [ "--enable-chromecast" ]
    ++ lib.optionals pulseSupport [ "--with-pulseaudio" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Media server to stream audio to AirPlay and Chromecast receivers";
    homepage = "https://github.com/owntone/owntone-server";
    changelog = "https://github.com/owntone/owntone-server/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      hensoko
    ];

    platforms = lib.platforms.linux;
    mainProgram = "owntone";
    downloadPage = "https://github.com/owntone/owntone-server/releases/tag/${finalAttrs.version}";
  };
})
