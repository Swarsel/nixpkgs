{
  lib,
  buildPythonPackage,
  cryptography,
  deprecated,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "jwcrypto";
  version = "1.5.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-dxqHdioMCBrmFmlYqVT4CEiCCyqwZpN9yLg3nWWxsDk=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    cryptography
    deprecated
    typing-extensions
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "jwcrypto" ];

  meta = {
    description = "Implementation of JOSE Web standards";
    homepage = "https://github.com/latchset/jwcrypto";
    changelog = "https://github.com/latchset/jwcrypto/releases/tag/v${version}";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
  };
}
