{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "colorscript";
  version = "1.0.0-unstable-2024-09-20";

  src = fetchFromGitHub {
    owner = "EntySec";
    repo = "ColorScript";
    # https://github.com/EntySec/ColorScript/issues/4
    rev = "b98ec077fd2faa700ac5c6dafa0cdd17f649ffbc";
    hash = "sha256-xiN9wln0HU/gs6+L8QN4rmp72KUCAPWO/l2A7te64L0=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "colorscript" ];

  meta = {
    description = "Module for functionality with text, escape codes, octal and hexadecimal codes, and other data";
    homepage = "https://github.com/EntySec/ColorScript";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
