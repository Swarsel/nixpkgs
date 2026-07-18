{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch2,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pid";
  version = "3.0.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0e33670e83f6a33ebb0822e43a609c3247178d4a375ff50a4689e266d853eb66";
  };

  patches = [
    # apply c9d1550ba2ee73231f8e984d75d808c8cc103748 to remove nose dependency. change is in repo, but hasn't been released on pypi.
    (fetchpatch2 {
      hash = "sha256-2F31LlrJku1xzmI7P+QLyUZ8CzVHx25APp88qwWkZxw=";
      url = "https://github.com/trbs/pid/commit/c9d1550ba2ee73231f8e984d75d808c8cc103748.patch";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Pidfile featuring stale detection and file-locking";
    homepage = "https://github.com/trbs/pid/";
    license = lib.licenses.asl20;
  };
}
