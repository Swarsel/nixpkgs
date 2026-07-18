{
  lib,
  fetchFromGitHub,
  # dependencies
  attrs,
  buildPythonPackage,
  e2b,
  httpx,
  # build-system
  poetry-core,
}:

buildPythonPackage rec {
  inherit (e2b) version;
  pname = "e2b-code-interpreter";

  src = fetchFromGitHub {
    owner = "e2b-dev";
    repo = "code-interpreter";
    tag = "@e2b/code-interpreter-python@${version}";
    hash = "sha256-a2rc7BtV+qwtqlB+JtLCs0BKN15yfwmG3XWWO8we2LA=";
  };

  # Tests require an API key
  # e2b.exceptions.AuthenticationException: API key is required, please visit the Team tab at https://e2b.dev/dashboard to get your API key.
  doCheck = false;

  build-system = [
    poetry-core
  ];

  dependencies = [
    attrs
    e2b
    httpx
  ];

  pyproject = true;
  pythonImportsCheck = [ "e2b_code_interpreter" ];
  sourceRoot = "${src.name}/python";

  meta = {
    description = "E2B Code Interpreter - Stateful code execution";
    homepage = "https://github.com/e2b-dev/code-interpreter/tree/main/python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
