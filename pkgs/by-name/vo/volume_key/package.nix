{
  lib,
  stdenv,
  autoreconfHook,
  buildPackages,
  cryptsetup,
  fetchgit,
  gettext,
  glib,
  gpgme,
  ncurses,
  nss,
  pkg-config,
  python3,
  swig,
  util-linux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "volume_key";
  version = "0.3.11";

  src = fetchgit {
    url = "https://pagure.io/volume_key.git";
    rev = "volume_key-${finalAttrs.version}";
    sha256 = "1sqdbcih1c39bjiv4mm1m7acc3lfh2i2hf2r9i7rk8adfzq8awma";
  };

  outputs = [
    "out"
    "man"
    "dev"
    "py"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    gettext
    gpgme
    pkg-config
    swig
  ];

  buildInputs = [
    glib
    cryptsetup
    nss
    util-linux
    ncurses
  ];

  configureFlags = [
    "--with-gpgme-prefix=${gpgme.dev}"
  ];

  makeFlags = [
    "pyexecdir=$(py)/${python3.sitePackages}"
    "pythondir=$(py)/${python3.sitePackages}"
  ];

  env = lib.optionalAttrs stdenv.cc.isGNU {
    NIX_CFLAGS_COMPILE = toString [
      "-Wno-error=implicit-function-declaration"
      "-Wno-error=int-conversion"
    ];
  };

  preConfigure = ''
    export PYTHON="${buildPackages.python3}/bin/python"
    export PYTHON3_CONFIG="${python3}/bin/python3-config"
  '';

  doCheck = false; # fails 1 out of 1 tests, needs `certutil`

  meta = {
    description = "Library for manipulating storage volume encryption keys and storing them separately from volumes to handle forgotten passphrases, and the associated command-line tool";
    homepage = "https://pagure.io/volume_key/";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "volume_key";
  };
})
