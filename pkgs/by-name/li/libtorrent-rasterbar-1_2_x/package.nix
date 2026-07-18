{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  boost-build,
  boost186,
  libiconv,
  ncurses,
  openssl,
  pkg-config,
  python311,
  zlib,
}:

let
  version = "1.2.19";

  # Make sure we override python, so the correct version is chosen
  # for the bindings, if overridden
  boostPython = boost186.override (_: {
    enableMultiThreaded = true;
    enablePython = true;
    enableShared = false;
    enableSingleThreaded = false;
    enableStatic = true;
    python = python311;
    # So that libraries will be named like 'libboost_system.a' instead
    # of 'libboost_system-x64.a'.
    taggedLayout = false;
  });

  opensslStatic = openssl.override (_: {
    static = true;
  });

in
stdenv.mkDerivation {
  inherit version;
  pname = "libtorrent-rasterbar";

  src = fetchFromGitHub {
    owner = "arvidn";
    repo = "libtorrent";
    rev = "v${version}";
    hash = "sha256-HkpaOCBL+0Kc7M9DmnW2dUGC+b60a7n5n3i1SyRfkb4=";
  };

  outputs = [
    "out"
    "dev"
    "python"
  ];

  nativeBuildInputs = [
    autoreconfHook
    boost-build
    pkg-config
    python311.pkgs.setuptools
  ];

  buildInputs = [
    boostPython
    opensslStatic
    zlib
    python311
    libiconv
    ncurses
  ];

  configureFlags = [
    "--enable-python-binding"
    "--with-libiconv=yes"
    "--with-boost=${boostPython.dev}"
    "--with-boost-libdir=${boostPython.out}/lib"
  ];

  preConfigure = ''
    configureFlagsArray+=('PYTHON_INSTALL_PARAMS=--prefix=$(DESTDIR)$(prefix) --single-version-externally-managed --record=installed-files.txt')
  '';

  postInstall = ''
    moveToOutput "include" "$dev"
    moveToOutput "lib/${python311.libPrefix}" "$python"
  '';

  enableParallelBuilding = true;

  preAutoreconf = ''
    mkdir -p build-aux
    cp m4/config.rpath build-aux
  '';

  meta = {
    description = "C++ BitTorrent implementation focusing on efficiency and scalability";
    homepage = "https://libtorrent.org/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
  };
}
