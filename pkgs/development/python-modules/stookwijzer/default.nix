{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytz,
  setuptools,
}:

buildPythonPackage rec {
  pname = "stookwijzer";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "fwestenberg";
    repo = "stookwijzer";
    tag = "v${version}";
    hash = "sha256-T4u3KuKWAXRkHbjPt4qkiisnLjx9JMD0DW6enOlu69g=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    pytz
  ];

  pyproject = true;
  pythonImportsCheck = [ "stookwijzer" ];

  meta = {
    description = "Python package for the Stookwijzer API";
    homepage = "https://github.com/fwestenberg/stookwijzer";
    changelog = "https://github.com/fwestenberg/stookwijzer/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
