{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  click,
  colorama,
  packaging,
  pytest-xdist,
  pytestCheckHook,
  python,
  requirements-parser,
  rustPlatform,
  rustc,
  tomli,
}:

buildPythonPackage (finalAttrs: {
  pname = "deptry";
  version = "0.25.1";

  src = fetchFromGitHub {
    owner = "osprey-oss";
    repo = "deptry";
    tag = finalAttrs.version;
    hash = "sha256-GQWivQMWQ8wi6cWsCbmvSSyPEx1yl9QidO+9mTDrN1c=";
  };

  nativeCheckInputs = [
    pytest-xdist
    pytestCheckHook
  ];

  preCheck = ''
    cp $out/${python.sitePackages}/deptry/rust*.so python/deptry/
  '';

  build-system = [
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-axUqKks3vxiJF2bRI/Qwk7iKjoUNQQc3NynI60n3quY=";
  };

  dependencies = [
    click
    colorama
    packaging
    requirements-parser
    tomli
  ];

  disabledTestPaths = [
    # Don't run CLI tests
    "tests/functional/cli/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "deptry" ];

  meta = {
    description = "Find unused, missing and transitive dependencies in a Python project";
    homepage = "https://github.com/osprey-oss/deptry";
    changelog = "https://github.com/osprey-oss/deptry/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "deptry";
  };
})
