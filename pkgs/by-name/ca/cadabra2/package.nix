{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  catch2_3,
  cmake,
  glibmm,
  gmpxx,
  gtkmm3,
  jsoncpp,
  makeBinaryWrapper,
  nix-update-script,
  onetbb,
  openssl,
  pkg-config,
  python3,
  sqlite,
  versionCheckHook,
  wrapGAppsHook3,
  writableTmpDirAsHomeHook,
  # Build cadabra as a C++ library
  enableBuildAsCppLibrary ? false,
  # Enable the UI frontend
  enableFrontend ? true,
  # Enable building the Xeus-based Jupyter kernel
  enableJupyter ? false,
  # Enable Mathematica support
  enableMathematica ? false,
  # Enable building the default Jupyter kernel
  enablePyJupyter ? true,
}:

assert lib.assertMsg (
  enableMathematica -> !stdenv.hostPlatform.isDarwin
) "Mathematica scalar backend does not yet work on macOS.";

stdenv.mkDerivation (finalAttrs: {
  pname = "cadabra2";
  version = "2.5.14-p1";

  src = fetchFromGitHub {
    owner = "kpeeters";
    repo = "cadabra2";
    tag = finalAttrs.version;
    hash = "sha256-Pbk9SmJ64CZ+yxMj53JpxULBQye2ETDi8xNKw38cC9k=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'MESSAGE(FATAL_ERROR "Building with -DPACKAGING_MODE=ON also requires -DCMAKE_INSTALL_PREFIX=/usr")' ""
  '';

  nativeBuildInputs = [
    cmake
    makeBinaryWrapper
    pkg-config
    python3
  ]
  ++ lib.optional enableFrontend wrapGAppsHook3;

  buildInputs = [
    boost
    glibmm
    gmpxx
    jsoncpp
    onetbb
    openssl
    python3.pkgs.pybind11
    sqlite
  ]
  ++ lib.optional enableFrontend gtkmm3;

  propagatedBuildInputs = with python3.pkgs; [
    matplotlib
    mpmath
    sympy
    gmpy2
  ];

  cmakeFlags = [
    (lib.cmakeFeature "PYTHON_SITE_PATH" "${placeholder "out"}/${python3.sitePackages}")

    (lib.cmakeBool "ENABLE_FRONTEND" enableFrontend)
    (lib.cmakeBool "ENABLE_JUPYTER" enableJupyter)
    (lib.cmakeBool "ENABLE_PY_JUPYTER" enablePyJupyter)
    (lib.cmakeBool "ENABLE_MATHEMATICA" enableMathematica)
    (lib.cmakeBool "BUILD_AS_CPP_LIBRARY" enableBuildAsCppLibrary)
    (lib.cmakeBool "ENABLE_SYSTEM_JSONCPP" true)
    (lib.cmakeBool "FETCHCONTENT_FULLY_DISCONNECTED" true)
    (lib.cmakeBool "PACKAGING_MODE" true)

    (lib.cmakeBool "BUILD_TESTS" finalAttrs.doCheck)
  ];

  doCheck = true;
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];
  checkInputs = [ catch2_3 ];
  #doInstallCheck = !enableBuildAsCppLibrary;
  doInstallCheck = false; # FIXME: remove this line and uncomment the above after next release
  nativeInstallCheckInputs = [ versionCheckHook ];

  preFixup = ''
    wrapper_args=(
      --prefix PATH : "$out/bin"
      --prefix PYTHONPATH : "$out/${python3.sitePackages}"
      --prefix PYTHONPATH : "${python3.pkgs.makePythonPath finalAttrs.propagatedBuildInputs}"
    )
    gappsWrapperArgs+=("''${wrapper_args[@]}")
  ''
  + lib.optionalString (!enableFrontend) ''
    for program in $out/bin/*; do
      wrapProgram "$program" "''${wrapper_args[@]}"
    done
  '';

  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Field-theory motivated approach to computer algebra";
    homepage = "https://github.com/kpeeters/cadabra2";
    changelog = "https://github.com/kpeeters/cadabra2/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.unix;
    mainProgram = "cadabra2";
    # glibmm not found
    broken = stdenv.hostPlatform.isDarwin;
  };
})
