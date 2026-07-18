{
  lib,
  stdenv,
  fetchFromGitHub,
  catch2,
  cmake,
  eigen,
  osqp,
  valgrind,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "osqp-eigen";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "robotology";
    repo = "osqp-eigen";
    rev = "v${finalAttrs.version}";
    hash = "sha256-SrQxRyzbheotCTSF7eBFr6nxJxWdze1hFhP/F06cb7g=";
  };

  nativeBuildInputs = [ cmake ];

  propagatedBuildInputs = [
    eigen
    osqp
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTING" true)
    (lib.cmakeBool "OSQPEIGEN_RUN_Valgrind_tests" stdenv.hostPlatform.isLinux)
  ];

  doCheck = true;
  nativeCheckInputs = lib.optional stdenv.hostPlatform.isLinux valgrind;
  checkInputs = [ catch2 ];

  meta = {
    description = "Simple Eigen-C++ wrapper for OSQP library";
    homepage = "https://github.com/robotology/osqp-eigen";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
