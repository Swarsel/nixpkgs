{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  invoke,
  poetry-core,
  pytestCheckHook,
  ruamel-yaml,
  textfsm,
  toml,
  yamllint,
}:

buildPythonPackage rec {
  pname = "ntc-templates";
  version = "8.1.0";

  src = fetchFromGitHub {
    owner = "networktocode";
    repo = "ntc-templates";
    tag = "v${version}";
    hash = "sha256-J1Icf9UG5IMYBH90Mfxd+p+rk57z2OXQENnoRAaepN4=";
  };

  nativeCheckInputs = [
    invoke
    pytestCheckHook
    ruamel-yaml
    toml
    yamllint
  ];

  build-system = [ poetry-core ];
  dependencies = [ textfsm ];
  pyproject = true;
  pythonRelaxDeps = [ "textfsm" ];

  meta = {
    description = "TextFSM templates for parsing show commands of network devices";
    homepage = "https://github.com/networktocode/ntc-templates";
    changelog = "https://github.com/networktocode/ntc-templates/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
