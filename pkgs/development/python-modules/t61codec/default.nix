{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "t61codec";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "exhuma";
    repo = "t61codec";
    tag = "v${version}";
    hash = "sha256-PNUahn6NpNWdK3yhcQ23qb08lkZeNW61GosShLiyPc8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "t61codec" ];

  meta = {
    description = "Python codec for T.61 strings";
    homepage = "https://github.com/exhuma/t61codec";
    changelog = "https://github.com/exhuma/t61codec/blob/v${version}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
