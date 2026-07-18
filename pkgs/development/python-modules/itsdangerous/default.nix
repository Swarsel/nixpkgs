{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  freezegun,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "itsdangerous";
  version = "2.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-4AUMC32h7qU/+vFJwM+7XG4uK2nEvvIsgfputz5fYXM=";
  };

  nativeCheckInputs = [
    freezegun
    pytestCheckHook
  ];

  build-system = [ flit-core ];
  pyproject = true;

  meta = {
    description = "Safely pass data to untrusted environments and back";
    homepage = "https://itsdangerous.palletsprojects.com";
    changelog = "https://github.com/pallets/itsdangerous/blob/${version}/CHANGES.rst";
    license = lib.licenses.bsd3;
  };
}
