{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  marshmallow,
  marshmallow-dataclass,
  pdm-backend,
  pytestCheckHook,
  requests,
  responses,
  setuptools,
  typing-extensions,
  vcrpy,
}:

buildPythonPackage rec {
  pname = "pygitguardian";
  version = "1.32.0";

  src = fetchFromGitHub {
    owner = "GitGuardian";
    repo = "py-gitguardian";
    tag = "v${version}";
    hash = "sha256-f8DkRwgtwaB5R78zklAI0ZvA2gfSwsHFOS3IgDgcEEo=";
  };

  env.GITGUARDIAN_API_KEY = "Test key for tests";

  nativeCheckInputs = [
    pytestCheckHook
    vcrpy
    responses
  ];

  build-system = [ pdm-backend ];

  dependencies = [
    marshmallow
    marshmallow-dataclass
    requests
    setuptools
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "pygitguardian" ];

  meta = {
    description = "Library to access the GitGuardian API";
    homepage = "https://github.com/GitGuardian/py-gitguardian";
    changelog = "https://github.com/GitGuardian/py-gitguardian/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
