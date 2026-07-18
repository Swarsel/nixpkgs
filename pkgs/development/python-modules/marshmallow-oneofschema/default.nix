{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  marshmallow,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "marshmallow-oneofschema";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "marshmallow-code";
    repo = "marshmallow-oneofschema";
    tag = version;
    hash = "sha256-Hk36wxZV1hVqIbqDOkEDlqABRKE6s/NyA/yBEXzj/yM=";
  };

  nativeBuildInputs = [ flit-core ];
  propagatedBuildInputs = [ marshmallow ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "marshmallow_oneofschema" ];

  meta = {
    description = "Marshmallow library extension that allows schema (de)multiplexing";
    homepage = "https://github.com/marshmallow-code/marshmallow-oneofschema";
    changelog = "https://github.com/marshmallow-code/marshmallow-oneofschema/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
