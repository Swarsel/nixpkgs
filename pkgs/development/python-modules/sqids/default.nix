{
  lib,
  buildPythonPackage,
  fetchPypi,
  hypothesis,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "sqids";
  version = "0.5.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-WsCPDFybaBS8Lnx57lkx4ISdJdlcUOQVdxsCKkT1ivk=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  build-system = [ setuptools-scm ];
  pyproject = true;
  pythonImportsCheck = [ "sqids" ];

  meta = {
    description = "Library that lets you generate short YouTube-looking IDs from numbers";
    homepage = "https://sqids.org/python";
    license = with lib.licenses; mit;
    maintainers = with lib.maintainers; [ panicgh ];
  };
}
