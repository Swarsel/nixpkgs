{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "http-ece";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "web-push-libs";
    repo = "encrypted-content-encoding";
    rev = version;
    hash = "sha256-HjXJWoOvCVOdEto4Ss4HPUuf+uNcQkfvj/cxJGHOhQ8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];
  dependencies = [ cryptography ];
  pyproject = true;
  sourceRoot = "${src.name}/python";

  meta = {
    description = "Encipher HTTP Messages";
    homepage = "https://github.com/web-push-libs/encrypted-content-encoding";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ peterhoeg ];
  };
}
