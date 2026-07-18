{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  colorlog,
  python-dateutil,
  requests,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pyisy";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = "automicus";
    repo = "PyISY";
    tag = "v${version}";
    hash = "sha256-KEjiMmD4mY1sG/vRo1QINQw31jk8MNV6m13fU2ENmJM=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace 'version_format="{tag}"' 'version="${version}"'
  '';

  # no tests implemented
  doCheck = false;
  build-system = [ setuptools-scm ];

  dependencies = [
    aiohttp
    colorlog
    python-dateutil
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyisy" ];

  meta = {
    description = "Python module to talk to ISY994 from UDI";
    homepage = "https://github.com/automicus/PyISY";
    changelog = "https://github.com/automicus/PyISY/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
