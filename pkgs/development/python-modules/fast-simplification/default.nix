{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  nix-update-script,
  numpy,
  pytestCheckHook,
  pyvista,
  setuptools,
  wheel,
}:

buildPythonPackage (finalAttrs: {
  pname = "fast-simplification";
  version = "0.1.13";

  src = fetchFromGitHub {
    owner = "pyvista";
    repo = "fast-simplification";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MgAOGB4wJQ68GyotaxiR9Xdho+TckHKEglQvCE2TWVY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pyvista
  ];

  # make sure import the built version, not the source one
  preCheck = ''
    rm -r fast_simplification
  '';

  build-system = [
    cython
    numpy
    setuptools
    wheel
  ];

  dependencies = [
    numpy
  ];

  disabledTests = [
    # need network to download data
    "test_collapses_louis"
    "test_human"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "fast_simplification"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast Quadratic Mesh Simplification";
    homepage = "https://github.com/pyvista/fast-simplification";
    changelog = "https://github.com/pyvista/fast-simplification/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      yzx9
    ];
  };
})
