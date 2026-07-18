{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lxml,
  numpy,
  pytestCheckHook,
  scikit-image,
  setuptools,
}:
let
  version = "1.2.1";
in
buildPythonPackage {
  inherit version;
  pname = "mung";

  src = fetchFromGitHub {
    owner = "OMR-Research";
    repo = "mung";
    tag = version;
    hash = "sha256-QljGoZdUJRClQ/QzUsCKD0/ooWaFrKXI+93WFPvmIjE=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    lxml
    numpy
    scikit-image
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "mung" ];

  meta = {
    description = "Music Notation Graph: a data model for optical music recognition";
    homepage = "https://github.com/OMR-Research/mung";
    changelog = "https://github.com/OMR-Research/mung/blob/${version}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ piegames ];
  };
}
