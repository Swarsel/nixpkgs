{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  mock,
  pytestCheckHook,
  setuptools,
}:

let
  pname = "supervisor";

  version = "4.3.0";
in
buildPythonPackage {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-SivxSa30KZfhu0S3DEO2EydeyYUsPtrMqGqRZrJ+lF4=";
  };

  # wants to write to /tmp/foo which is likely already owned by another
  # nixbld user on hydra
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "supervisor" ];

  meta = {
    description = "System for controlling process state under UNIX";
    homepage = "https://supervisord.org/";
    changelog = "https://github.com/Supervisor/supervisor/blob/${version}/CHANGES.rst";
    license = lib.licenses.free; # http://www.repoze.org/LICENSE.txt
    maintainers = with lib.maintainers; [ zimbatm ];
  };
}
