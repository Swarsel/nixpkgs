{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "multipart";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "defnull";
    repo = "multipart";
    tag = "v${version}";
    hash = "sha256-kLiOK6ovW3ki1CONXVQZCJw/U3K1AoR6rrmJUstwZOw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];
  pyproject = true;
  pythonImportsCheck = [ "multipart" ];

  meta = {
    description = "Parser for multipart/form-data";
    homepage = "https://github.com/defnull/multipart";
    changelog = "https://github.com/defnull/multipart/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
