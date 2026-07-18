{
  lib,
  fetchFromGitHub,
  aiosmtpd,
  buildPythonPackage,
  jaraco-collections,
  jaraco-text,
  keyring,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "jaraco-email";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "jaraco";
    repo = "jaraco.email";
    tag = "v${version}";
    hash = "sha256-2dU+tbrP86Oy8ej1Xa0+fNRB83tGBTUsOWbZyQsMKu8=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = [
    aiosmtpd
    jaraco-text
    jaraco-collections
    keyring
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "jaraco.email" ];

  meta = {
    description = "E-mail facilities by jaraco";
    homepage = "https://github.com/jaraco/jaraco.email";
    changelog = "https://github.com/jaraco/jaraco.email/blob/${src.tag}/NEWS.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
