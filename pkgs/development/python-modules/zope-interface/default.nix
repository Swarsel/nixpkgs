{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "zope-interface";
  version = "8.2";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.interface";
    tag = version;
    hash = "sha256-hOcg41lcdVWfmT2DqaYzzu4bJZYiG2y5boylJevBv6k=";
  };

  doCheck = false; # Circular deps.
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "zope.interface" ];
  pythonNamespaces = [ "zope" ];

  meta = {
    description = "Implementation of object interfaces, a mechanism for labeling objects as conforming to a given API or contract";
    homepage = "https://github.com/zopefoundation/zope.interface";
    changelog = "https://github.com/zopefoundation/zope.interface/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
}
