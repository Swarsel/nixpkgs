{
  lib,
  attrs,
  buildPythonPackage,
  fetchPypi,
  platformdirs,
  setuptools,
  tomli,
  versioningit,
}:

buildPythonPackage rec {
  pname = "pueblo";
  version = "0.0.19";

  # This tarball doesn't include tests unfortunately, and the GitHub tarball
  # could have been an alternative, but versioningit fails to detect the
  # version of it correctly, even with setuptools-scm and
  # SETUPTOOLS_SCM_PRETEND_VERSION = version added. Since this is a pure Python
  # package, we can rely on upstream to run the tests before releasing, and it
  # should work for us as well.
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-TGPjM6lOHUTKOdp+lu67ENvkmyfUVdAUaMIHgCxto3U=";
  };

  doCheck = false; # no tests in sdist

  build-system = [
    setuptools
    versioningit
  ];

  dependencies = [
    attrs
    platformdirs
    tomli
  ];

  pyproject = true;
  pythonImportsCheck = [ "pueblo" ];

  meta = {
    description = "Python toolbox library";
    homepage = "https://github.com/pyveci/pueblo";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
