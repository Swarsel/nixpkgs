{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "requests-aws4auth";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "tedder";
    repo = "requests-aws4auth";
    tag = "v${version}";
    hash = "sha256-GIbv4/a1ZdcIOemanzDiueLcKg8pUVeIFSAfErIr0HI=";
  };

  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.httpx;
  build-system = [ setuptools ];
  dependencies = [ requests ];

  optional-dependencies = {
    httpx = [ httpx ];
  };

  pyproject = true;
  pythonImportsCheck = [ "requests_aws4auth" ];

  meta = {
    description = "Amazon Web Services version 4 authentication for the Python Requests library";
    homepage = "https://github.com/sam-washington/requests-aws4auth";
    changelog = "https://github.com/tedder/requests-aws4auth/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ basvandijk ];
  };
}
