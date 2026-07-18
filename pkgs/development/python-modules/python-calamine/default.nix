{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  libiconv,
  packaging,
  poetry-core,
  pytestCheckHook,
  rustPlatform,
  rustc,
}:

buildPythonPackage rec {
  pname = "python-calamine";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "dimastbk";
    repo = "python-calamine";
    tag = "v${version}";
    hash = "sha256-vPI2SWOMwEpN0w7BWvFFz1eeXiU9t4xhdl3TpO39l/Q=";
  };

  buildInputs = [ libiconv ];
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    cargo
    poetry-core
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-DR84RulbTpwipYKHLtXdCa8Yr2Irv1W1o3NrCT8FRq4=";
  };

  dependencies = [ packaging ];
  pyproject = true;
  pythonImportsCheck = [ "python_calamine" ];

  meta = {
    description = "Python binding for calamine";
    homepage = "https://github.com/dimastbk/python-calamine";
    changelog = "https://github.com/dimastbk/python-calamine/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "python-calamine";
  };
}
