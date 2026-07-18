{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pathvalidate";
  version = "3.3.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-sYwHISv+rWJDRbuOHWFBzc8Vo5c2mU6guUA1rSsboXc=";
  };

  # Requires `pytest-md-report`, causing infinite recursion.
  doCheck = false;
  build-system = [ setuptools-scm ];
  pyproject = true;
  pythonImportsCheck = [ "pathvalidate" ];

  meta = {
    description = "Library to sanitize/validate a string such as filenames/file-paths/etc";
    homepage = "https://github.com/thombashi/pathvalidate";
    changelog = "https://github.com/thombashi/pathvalidate/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ oxalica ];
  };
}
