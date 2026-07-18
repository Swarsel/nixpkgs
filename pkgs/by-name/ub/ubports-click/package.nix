{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  dbus,
  dbus-test-runner,
  dpkg,
  fetchpatch,
  getopt,
  gitUpdater,
  glib,
  gobject-introspection,
  json-glib,
  libgee,
  perl,
  pkg-config,
  properties-cpp,
  python3Packages,
  testers,
  vala,
  wrapGAppsHook3,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "click";
  version = "0.5.2";

  src = fetchFromGitLab {
    owner = "ubports";
    repo = "development/core/click";
    tag = finalAttrs.version;
    hash = "sha256-AV3n6tghvpV/6Ew6Lokf8QAGBIMbHFAnp6G4pefVn+8=";
  };

  patches = [
    # Remove when version > 0.5.2
    (fetchpatch {
      hash = "sha256-kio+DdtuagUNYEosyQY3q3H+dJM3cLQRW9wUKUcpUTY=";
      name = "0001-click-fix-Wimplicit-function-declaration.patch";
      url = "https://gitlab.com/ubports/development/core/click/-/commit/8f654978a12e6f9a0b6ff64296ec5565e3ff5cd0.patch";
    })

    # Remove when version > 0.5.2
    (fetchpatch {
      hash = "sha256-QaWRhxO61wAzULVqPLdJrLuBCr3+NhKmQlEPuYq843I=";
      name = "0002-click-Add-uid_t-and-gid_t-to-the-ctypes-_typemap.patch";
      url = "https://gitlab.com/ubports/development/core/click/-/commit/cbcd23b08b02fa122434e1edd69c2b3dcb6a8793.patch";
    })
  ];

  postPatch =
    # These should be proper Requires, using the header needs their headers
    ''
      substituteInPlace lib/click/click-*.pc.in \
        --replace-fail 'Requires.private' 'Requires'
    ''
    # Don't completely override PKG_CONFIG_PATH
    + ''
      substituteInPlace click_package/tests/Makefile.am \
        --replace-fail 'PKG_CONFIG_PATH=$(top_builddir)/lib/click' 'PKG_CONFIG_PATH=$(top_builddir)/lib/click:$(PKG_CONFIG_PATH)'
    ''
    + ''
      patchShebangs bin/click
    '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    dbus-test-runner # Always checking for this
    getopt
    gobject-introspection
    perl
    pkg-config
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    json-glib
    libgee
    properties-cpp
  ];

  configureFlags = [
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
    "--with-systemduserunitdir=${placeholder "out"}/lib/systemd/user"
  ];

  preConfigure = ''
    export click_cv_perl_vendorlib=$out/${perl.libPrefix}
    export PYTHON_INSTALL_FLAGS="--prefix=$out"
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  nativeCheckInputs = [
    dbus
    dpkg
    python3Packages.unittestCheckHook
    writableTmpDirAsHomeHook
  ];

  checkInputs = with python3Packages; [
    python-apt
    six
  ];

  preCheck =
    # tests recompile some files for loaded predefines, doesn't use any optimisation level for it
    # makes test output harder to read, so make the warning go away
    ''
      export NIX_CFLAGS_COMPILE+=" -U_FORTIFY_SOURCE"
    ''
    # Haven't been able to get them excluded via disabledTest{s,Paths}, just deleting them
    + ''
      for path in $disabledTestPaths; do
        rm -v $path
      done
    '';

  preFixup = ''
    makeWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "$out/lib"
    )
  '';

  build-system = [
    python3Packages.setuptools_80
  ];

  dependencies = with python3Packages; [
    python-debian
    chardet
    pygobject3
  ];

  disabledTestPaths = [
    # From apt: Unable to determine a suitable packaging system type
    "click_package/tests/integration/test_signatures.py"
    "click_package/tests/test_build.py"
    "click_package/tests/test_install.py"
    "click_package/tests/test_scripts.py"
  ];

  enableParallelBuilding = true;

  pkgsBuildBuild = [
    pkg-config
  ];

  pyproject = false;

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
      versionCheck = true;
    };

    updateScript = gitUpdater { };
  };

  meta = {
    description = "Tool to build click packages, mainly used for Ubuntu Touch";
    homepage = "https://gitlab.com/ubports/development/core/click";
    changelog = "https://gitlab.com/ubports/development/core/click/-/blob/${finalAttrs.version}/ChangeLog";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      ilyakooo0
    ];

    platforms = lib.platforms.linux;
    mainProgram = "click";

    pkgConfigModules = [
      "click-0.4"
    ];

    teams = [ lib.teams.lomiri ];
  };
})
