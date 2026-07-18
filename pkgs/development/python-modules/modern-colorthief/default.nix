{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorthief,
  nix-update-script,
  pillow,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "modern-colorthief";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "baseplate-admin";
    repo = "modern_colorthief";
    tag = version;
    hash = "sha256-oQ0ZAL8GyzKfFoSBJS2LIck2Z1IzZCYrkOc9nXfqyyg=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  nativeCheckInputs = [ pytestCheckHook ] ++ lib.concatAttrValues optional-dependencies;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-csGUiJKAZn8OF3lxfw5VPwZxWDXHpFC0rczkD1+P8Sk=";
  };

  disabledTestPaths = [
    # Requires `fast_colorthief`, which isn't packaged
    "examples/test_time.py"
  ];

  optional-dependencies = {
    test = [
      colorthief
      pillow
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "modern_colorthief" ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    homepage = "https://modern-colorthief.readthedocs.io/";
    changelog = "https://github.com/baseplate-admin/modern_colorthief/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ getchoo ];
  };
}
