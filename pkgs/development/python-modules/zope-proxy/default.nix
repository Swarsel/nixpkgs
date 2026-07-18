{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  zope-interface,
}:

buildPythonPackage rec {
  pname = "zope-proxy";
  version = "7.1";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.proxy";
    tag = version;
    hash = "sha256-p5uDHNF7kZJkFibNbM0JLrw5BYqs+qnNH3t0UBt0Krg=";
  };

  # circular deps
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ zope-interface ];
  pyproject = true;
  pythonImportsCheck = [ "zope.proxy" ];
  pythonNamespaces = [ "zope" ];

  meta = {
    description = "Generic Transparent Proxies";
    homepage = "https://github.com/zopefoundation/zope.proxy";
    changelog = "https://github.com/zopefoundation/zope.proxy/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
}
