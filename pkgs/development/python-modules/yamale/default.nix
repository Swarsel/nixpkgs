{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pyyaml,
  ruamel-yaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "yamale";
  version = "6.1.0";

  src = fetchFromGitHub {
    owner = "23andMe";
    repo = "yamale";
    tag = version;
    hash = "sha256-+UZJhZLJEZVGPF9D9B8blGh4pLszQnDoOl5xQMpvVl0=";
  };

  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.ruamel;
  build-system = [ setuptools ];

  dependencies = [
    pyyaml
  ];

  optional-dependencies = {
    ruamel = [ ruamel-yaml ];
  };

  pyproject = true;
  pythonImportsCheck = [ "yamale" ];

  meta = {
    description = "Schema and validator for YAML";
    homepage = "https://github.com/23andMe/Yamale";
    changelog = "https://github.com/23andMe/Yamale/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rtburns-jpl ];
    mainProgram = "yamale";
  };
}
