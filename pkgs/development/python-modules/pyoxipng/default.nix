{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "pyoxipng";
  version = "9.1.1";

  src = fetchFromGitHub {
    owner = "nfrasser";
    repo = "pyoxipng";
    tag = "v${version}";
    hash = "sha256-aVya+0+X2p0VaWCZTxVlVUFFlqkqZ7A2lJjhxiXAgrE=";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-wMCx6cujqM4q96b1mg4eovKjWmsv0FcaDBCxy0OodmA=";
  };

  pyproject = true;
  pythonImportsCheck = [ "oxipng" ];

  meta = {
    description = "Python wrapper for multithreaded PNG optimizer oxipng";
    homepage = "https://github.com/nfrasser/pyoxipng";
    changelog = "https://github.com/nfrasser/pyoxipng/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ undefined-landmark ];
  };
}
