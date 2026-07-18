{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pyyaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyaml-env";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "mkaranasou";
    repo = "pyaml_env";
    tag = "v${version}";
    hash = "sha256-Mp5Zn2JA6j/OTkPCRggNdqdWkrUYyYHMVK6hy/EI0I8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ pyyaml ];
  pyproject = true;
  pythonImportsCheck = [ "pyaml_env" ];

  meta = {
    description = "Parse YAML configuration with environment variables in Python";
    homepage = "https://github.com/mkaranasou/pyaml_env";
    changelog = "https://github.com/mkaranasou/pyaml_env/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
