{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "openstep-parser";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "kronenthaler";
    repo = "openstep-parser";
    tag = version;
    hash = "sha256-ivPvkvVWXw5ftaGvwBR+JxBIlisI0p6k3i/8V2HlaqQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "openstep_parser" ];

  meta = {
    description = "OpenStep plist parser for Python";
    homepage = "https://github.com/kronenthaler/openstep-parser";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ ilaumjd ];
  };
}
