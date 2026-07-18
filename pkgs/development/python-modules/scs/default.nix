{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  buildPythonPackage,
  lapack,
  # build-system
  meson-python,
  numpy,
  pkg-config,
  pkgs,
  # check inputs
  pytestCheckHook,
  # dependencies
  scipy,
}:

buildPythonPackage (finalAttrs: {
  inherit (pkgs.scs) version;
  pname = "scs";

  src = fetchFromGitHub {
    owner = "bodono";
    repo = "scs-python";
    tag = finalAttrs.version;
    hash = "sha256-ZB1A6613ZgwGsZ97MpK9c1vUfNe+0RkUULtzQxGKd88=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "numpy >= 2.0.0" "numpy"
  '';

  buildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [
    blas
    lapack
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    meson-python
    numpy
    pkg-config
  ];

  dependencies = [
    numpy
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "scs" ];

  meta = {
    inherit (pkgs.scs.meta) homepage;
    description = "Python interface for SCS: Splitting Conic Solver";

    longDescription = ''
      Solves convex cone programs via operator splitting.
      Can solve: linear programs (LPs), second-order cone programs (SOCPs), semidefinite programs (SDPs),
      exponential cone programs (ECPs), and power cone programs (PCPs), or problems with any combination of those cones.
    '';

    changelog = "https://github.com/bodono/scs-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://github.com/bodono/scs-python";
  };
})
