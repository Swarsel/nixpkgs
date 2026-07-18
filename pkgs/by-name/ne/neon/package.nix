{
  lib,
  stdenv,
  fetchurl,
  bash,
  libxml2,
  pkg-config,
  compressionSupport ? true,
  openssl ? null,
  shared ? !stdenv.hostPlatform.isStatic,
  sslSupport ? true,
  static ? stdenv.hostPlatform.isStatic,
  zlib ? null,
}:

assert compressionSupport -> zlib != null;
assert sslSupport -> openssl != null;
assert static || shared;

let
  inherit (lib) optionals;
in

stdenv.mkDerivation rec {
  pname = "neon";
  version = "0.37.1";

  src = fetchurl {
    url = "https://notroj.github.io/${pname}/${pname}-${version}.tar.gz";
    sha256 = "sha256-qZtyYlJaRU0QZc923RckD9gI38TvFWNpkP+DpdDZ50A=";
  };

  patches = optionals stdenv.hostPlatform.isDarwin [ ./darwin-fix-configure.patch ];
  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libxml2
    openssl
    bash
  ]
  ++ lib.optional compressionSupport zlib;

  configureFlags = [
    (lib.enableFeature shared "shared")
    (lib.enableFeature static "static")
    (lib.withFeature compressionSupport "zlib")
    (lib.withFeature sslSupport "ssl")
  ];

  preConfigure = ''
    export PKG_CONFIG="$(command -v "$PKG_CONFIG")"
  '';

  passthru = { inherit compressionSupport sslSupport; };

  meta = {
    description = "HTTP and WebDAV client library";
    homepage = "https://notroj.github.io/neon/";
    changelog = "https://github.com/notroj/${pname}/blob/${version}/NEWS";
    license = lib.licenses.lgpl2;
    platforms = lib.platforms.unix;
    mainProgram = "neon-config";
  };
}
