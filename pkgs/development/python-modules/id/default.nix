{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pretend,
  pytestCheckHook,
  requests,
}:

buildPythonPackage rec {
  pname = "id";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "di";
    repo = "id";
    tag = "v${version}";
    hash = "sha256-6Vkbs/i1roAtPGwLxdM+XKDrMTo0+NfVpAUpw6GPg9U=";
  };

  nativeCheckInputs = [
    pretend
    pytestCheckHook
  ];

  build-system = [ flit-core ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "id" ];

  meta = {
    description = "Tool for generating OIDC identities";
    homepage = "https://github.com/di/id";
    changelog = "https://github.com/di/id/blob/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
