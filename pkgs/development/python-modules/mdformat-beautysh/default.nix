{
  lib,
  fetchFromGitHub,
  beautysh,
  buildPythonPackage,
  mdformat,
  mdformat-gfm,
  mdit-py-plugins,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "mdformat-beautysh";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "hukkin";
    repo = "mdformat-beautysh";
    tag = version;
    hash = "sha256-Wzwy2FSknohmgrZ/ACliBDD2lOaQKKHyacAL57Ci3SU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    beautysh
    mdformat
    mdformat-gfm
    mdit-py-plugins
  ];

  pyproject = true;
  pythonImportsCheck = [ "mdformat_beautysh" ];

  meta = {
    description = "Mdformat plugin to beautify Bash scripts";
    homepage = "https://github.com/hukkin/mdformat-beautysh";
    changelog = "https://github.com/hukkin/mdformat-beautysh/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aldoborrero ];
  };
}
