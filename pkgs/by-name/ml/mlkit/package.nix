{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  mlton,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mlkit";
  version = "4.7.21";

  src = fetchFromGitHub {
    owner = "melsman";
    repo = "mlkit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-c1GdM3K6dgY0EgHu01adBXwAxuMehRfo73Lo71couJ4=";
  };

  nativeBuildInputs = [
    autoreconfHook
    mlton
  ];

  buildFlags = [
    "mlkit"
    "mlkit_libs"
    "smltojs"
    "smltojs_basislibs"
    "barry"
  ];

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    echo ==== Running MLKit test suite: test ====
    make -C test_dev test
    echo ==== Running MLKit test suite: test_prof ====
    make -C test_dev test_prof
    echo ==== Running Barry test suite ====
    make -C test/barry
    runHook postCheck
  '';

  # MLKit intentionally has some of these in its test suite.
  # Since the test suite is available in `$out/share/mlkit/test`, we must disable this check.
  dontCheckForBrokenSymlinks = true;

  installTargets = [
    "install"
    "install_smltojs"
    "install_barry"
  ];

  meta = {
    description = "Standard ML Compiler and Toolkit";
    homepage = "https://elsman.com/mlkit/";
    changelog = "https://github.com/melsman/mlkit/blob/v${finalAttrs.version}/NEWS.md";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ athas ];

    platforms = [
      "x86_64-linux"
    ];
  };
})
