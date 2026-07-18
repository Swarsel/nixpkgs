{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "josepy";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "certbot";
    repo = "josepy";
    tag = "v${version}";
    hash = "sha256-3YzcXdzwf5elkEJeCn4wBb987HTrYM5tT2XfOQIpZ9Q=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    cryptography
  ];

  pyproject = true;
  pythonImportsCheck = [ "josepy" ];

  meta = {
    description = "JOSE protocol implementation in Python";
    homepage = "https://github.com/certbot/josepy";
    changelog = "https://github.com/certbot/josepy/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "jws";
  };
}
