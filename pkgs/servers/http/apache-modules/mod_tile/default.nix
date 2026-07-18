{
  lib,
  stdenv,
  fetchFromGitHub,
  apacheHttpd,
  apr,
  aprutil,
  boost,
  cairo,
  cmake,
  curl,
  glib,
  harfbuzz,
  iana-etc,
  icu,
  iniparser,
  jq,
  libmemcached,
  mapnik,
  memcached,
  nix-update-script,
  pkg-config,
  ps,
}:

stdenv.mkDerivation rec {
  pname = "mod_tile";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "openstreetmap";
    repo = "mod_tile";
    tag = "v${version}";
    hash = "sha256-zDe+pFzK16K+8I0v1Z7p83PIgQlVDbjcnD4vzwdB1Oo=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    apacheHttpd
    apr
    aprutil
    boost
    cairo
    curl
    glib
    harfbuzz
    icu
    iniparser
    libmemcached
    mapnik
  ];

  # Explicitly specify directory paths
  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
    (lib.cmakeFeature "CMAKE_INSTALL_MANDIR" "share/man")
    (lib.cmakeFeature "CMAKE_INSTALL_MODULESDIR" "modules")
    (lib.cmakeFeature "CMAKE_INSTALL_PREFIX" "")
    (lib.cmakeBool "ENABLE_TESTS" doCheck)
  ];

  doCheck = true;

  nativeCheckInputs = [
    iana-etc
    ps
  ]
  ++ lib.filter (pkg: !pkg.meta.broken) [
    jq
    memcached
  ];

  enableParallelBuilding = true;
  # Do not run tests in parallel
  enableParallelChecking = false;
  # And use DESTDIR to define the install destination
  installFlags = [ "DESTDIR=$(out)" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Efficiently render and serve OpenStreetMap tiles using Apache and Mapnik";
    homepage = "https://github.com/openstreetmap/mod_tile";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ jglukasik ];
    platforms = lib.platforms.linux;
  };
}
