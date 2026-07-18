{
  lib,
  stdenv,
  attrdict,
  # build
  autoPatchelfHook,
  buildPackages,
  buildPythonPackage,
  # runtime
  cairo,
  cython,
  doxygen,
  fetchPypi,
  fetchpatch,
  gst_all_1,
  gtk3,
  libGL,
  libGLU,
  libgbm,
  libglvnd,
  libsm,
  libxinerama,
  libxtst,
  libxxf86vm,
  # propagates
  numpy,
  pango,
  pillow,
  pkg-config,
  # checks
  py,
  pytest,
  pytest-forked,
  python,
  replaceVars,
  requests,
  setuptools,
  sip,
  six,
  webkitgtk_4_1,
  which,
  wxGTK,
  xorgproto,
  xvfb-run,
}:

buildPythonPackage (finalAttrs: {
  pname = "wxpython";
  version = "4.2.5";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-ROg20bzNmcOHkLsDS27PcNkGD2c0MgVg98Sw0AYUR5M=";
  };

  patches = [
    (replaceVars ./4.2-ctypes.patch {
      libcairo = "${lib.getLib cairo}/lib/libcairo${stdenv.hostPlatform.extensions.sharedLibrary}";
      libgdk = "${lib.getLib gtk3}/lib/libgdk-3${stdenv.hostPlatform.extensions.sharedLibrary}";
      libpangocairo = "${lib.getLib pango}/lib/libpangocairo-1.0${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
    ./0001-add-missing-bool-c.patch # Add missing bool.c from old source
  ];

  # https://github.com/wxWidgets/Phoenix/issues/2575
  postPatch = ''
    ln -s ${lib.getExe buildPackages.waf} bin/waf
    substituteInPlace build.py \
      --replace-fail "distutils.dep_util" "setuptools.modified" \
      --replace-fail "runcmd(cmd, fatal=False)" "runcmd(cmd, fatal=True)" # fail when pytest reports errors
  '';

  nativeBuildInputs = [
    attrdict
    cython
    pkg-config
    requests
    setuptools
    sip
    which
    wxGTK
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = [
    wxGTK
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    libGL
    libGLU
    libsm
    libxinerama
    libxtst
    libxxf86vm
    libglvnd
    libgbm
    webkitgtk_4_1
    xorgproto
  ];

  propagatedBuildInputs = [
    numpy
    pillow
    six
  ];

  buildPhase = ''
    runHook preBuild

    export DOXYGEN=${doxygen}/bin/doxygen
    export PATH="${wxGTK}/bin:$PATH"

    ${python.pythonOnBuildForHost.interpreter} build.py -v --use_syswx dox etg sip --nodoc build_py

    runHook postBuild
  '';

  # The majority of the tests require a graphical environment, but xvfb-run is available only on Linux.
  # Tests fail randomly on OfBorg and Hydra.
  doCheck = false;

  nativeCheckInputs = [
    py # py must be ordered before pytest (see https://github.com/pytest-dev/pytest-forked/issues/88)
    pytest
    pytest-forked
    xvfb-run
  ];

  checkPhase =
    let
      # Some tests appear to be incompatible with xvfb-run.
      skippedTests = [
        "dirdlg"
        "display"
        "filectrl"
        "filedlg"
        "filedlgcustomize"
        "frame"
        "glcanvas"
        "pickers"
        "windowid"
      ];
      testArguments = lib.concatMapStringsSep " " (
        test: "--ignore unittests/test_${test}.py"
      ) skippedTests;
    in
    ''
      runHook preCheck

      HOME=$(mktemp -d) xvfb-run ${python.interpreter} build.py -v --extra_pytest='${testArguments}' test

      runHook postCheck
    '';

  installPhase = ''
    runHook preInstall

    ${python.pythonOnBuildForHost.interpreter} setup.py install --skip-build --prefix=$out
    wrapPythonPrograms

    runHook postInstall
  '';

  pyproject = false;
  wafPath = "bin/waf";

  meta = {
    description = "Cross platform GUI toolkit for Python, Phoenix version";
    homepage = "http://wxpython.org/";
    changelog = "https://github.com/wxWidgets/Phoenix/blob/wxPython-${finalAttrs.version}/CHANGES.rst";

    license = with lib.licenses; [
      lgpl2Plus
      wxWindowsException31
    ];
  };
})
