{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "utils";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "haaksmash";
    repo = "pyutils";
    tag = finalAttrs.version;
    hash = "sha256-eb2trh3eawdAcPo3De9NgYN2HT1+FGju/F4V7lga+R4=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "utils" ];

  meta = {
    description = "Python set of utility functions and objects";
    homepage = "https://github.com/haaksmash/pyutils";
    license = with lib.licenses; [ lgpl3Only ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
