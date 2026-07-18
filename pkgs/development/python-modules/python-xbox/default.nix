{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  freezegun,
  hatch-regex-commit,
  hatchling,
  httpx,
  ms-cv,
  platformdirs,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
  respx,
}:

buildPythonPackage rec {
  pname = "python-xbox";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "tr4nt0r";
    repo = "python-xbox";
    tag = "v${version}";
    hash = "sha256-5sYN7w/cemZPMt8awsoaUPo845oXiiUsIfl8GG85Umw=";
  };

  nativeCheckInputs = [
    freezegun
    pytest-asyncio
    pytestCheckHook
    respx
  ];

  build-system = [
    hatch-regex-commit
    hatchling
  ];

  dependencies = [
    cryptography
    httpx
    ms-cv
    pydantic
  ];

  optional-dependencies = {
    cli = [
      platformdirs
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pythonxbox" ];

  pythonRelaxDeps = [
    "pydantic"
  ];

  meta = {
    description = ":ibrary to authenticate with Xbox Network and use their API";
    homepage = "https://github.com/tr4nt0r/python-xbox";
    changelog = "https://github.com/tr4nt0r/python-xbox/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
