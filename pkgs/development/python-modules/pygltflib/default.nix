{
  lib,
  fetchFromGitHub,
  fetchFromGitLab,
  buildPythonPackage,
  dataclasses-json,
  deprecated,
  pytestCheckHook,
  setuptools,
}:

let
  gltf-sample-models = fetchFromGitHub {
    hash = "sha256-TxSg1O6eIiaKagcZUoWZ5Iw/tBKvQIoepRFp3MdVlyI=";
    owner = "KhronosGroup";
    repo = "glTF-Sample-Models";
    rev = "d7a3cc8e51d7c573771ae77a57f16b0662a905c6";
  };
in

buildPythonPackage rec {
  pname = "pygltflib";
  version = "1.16.5";

  src = fetchFromGitLab {
    owner = "dodgyville";
    repo = "pygltflib";
    tag = "v${version}";
    hash = "sha256-3XfOlL+l0isMFv71+uY/PBHCwND54qACoCVYntfCot4=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    dataclasses-json
    deprecated
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    ln -s ${gltf-sample-models} glTF-Sample-Models
  '';

  pyproject = true;
  pythonImportsCheck = [ "pygltflib" ];

  meta = {
    description = "Module for reading and writing basic glTF files";
    homepage = "https://gitlab.com/dodgyville/pygltflib";
    changelog = "https://gitlab.com/dodgyville/pygltflib/-/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
