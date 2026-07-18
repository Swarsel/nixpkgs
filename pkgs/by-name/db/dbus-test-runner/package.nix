{
  lib,
  stdenv,
  autoreconfHook,
  bash,
  dbus,
  dbus-glib,
  fetchbzr,
  gettext,
  glib,
  intltool,
  pkg-config,
  python3,
  testers,
  xvfb-run,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dbus-test-runner";
  version = "unstable-2019-10-02";

  src = fetchbzr {
    url = "lp:dbus-test-runner";
    rev = "109";
    sha256 = "sha256-4yH19X98SVqpviCBIWzIX6FYHWxCbREpuKCNjQuTFDk=";
  };

  patches = [
    # glib gettext is deprecated and broken, so use regular gettext instead
    ./use-regular-gettext.patch
  ];

  postPatch = ''
    patchShebangs tests/test-wait-outputer

    # Tests `cat` together build shell scripts
    # true is a PATHable call, bash a shebang
    substituteInPlace tests/Makefile.am \
      --replace '/bin/true' 'true' \
      --replace '/bin/bash' '${lib.getExe bash}'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    glib # for autoconf macro, gtester, gdbus
    gettext
    intltool
    pkg-config
  ];

  buildInputs = [
    dbus-glib
    glib
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  nativeCheckInputs = [
    bash
    dbus
    (python3.withPackages (
      ps: with ps; [
        python-dbusmock
      ]
    ))
    xvfb-run
  ];

  checkFlags = [
    "XVFB_RUN=${lib.getExe xvfb-run}"
  ];

  enableParallelBuilding = true;
  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "Small little utility to run a couple of executables under a new DBus session for testing";
    homepage = "https://launchpad.net/dbus-test-runner";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
    mainProgram = "dbus-test-runner";

    pkgConfigModules = [
      "dbustest-1"
    ];

    teams = [ lib.teams.lomiri ];
  };
})
