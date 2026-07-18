{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  docutils, # for manpages
  openssl, # for tests
  pkg-config,
  python3Packages, # for tests
  enableManpages ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "eiwd";
  version = "2.22-1";

  src = fetchFromGitHub {
    owner = "illiliti";
    repo = "eiwd";
    tag = finalAttrs.version;
    hash = "sha256-rmkXR4RZbtD6lh8cGrHLWVGTw4fQqP9+Z9qaftG1ld0=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "doc"
  ]
  ++ lib.optionals enableManpages [
    "man"
  ]
  ++ lib.optionals finalAttrs.doCheck [
    "test"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ]
  ++ lib.optionals enableManpages [
    docutils # only for the man pages
  ];

  configureFlags = [
    "--disable-dbus"
  ]
  ++ lib.optionals (!enableManpages) [
    "--disable-manual-pages"
  ];

  # override this to false if you don't want to build python3
  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkInputs = [
    python3Packages.python
    (lib.getBin openssl)
  ];

  # prevent the `install-data-local` Makefile rule from running;
  # all it does is attempt to `mkdir` the `localstatedir`.
  preInstall = ''
    mkdir install-data-local
    substituteInPlace Makefile --replace \
      '$(MKDIR_P) -m 700 $(DESTDIR)$(daemon_storagedir)' \
      'true'
  '';

  postInstall = ''
    mkdir -p $doc/share/doc
    cp -a doc $doc/share/doc/iwd
    cp -a README AUTHORS TODO $doc/share/doc/iwd
  ''
  + lib.optionalString finalAttrs.finalPackage.doCheck ''
    mkdir -p $test/bin
    cp -a test/* $test/bin/
  '';

  enableParallelBuilding = true;

  postUnpack = ''
    patchShebangs .
  '';

  meta = {
    description = "Fork of iwd (wifi daemon) which does not require dbus";
    homepage = "https://github.com/illiliti/eiwd/";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
  };
})
