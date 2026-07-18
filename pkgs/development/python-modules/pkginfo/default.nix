{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pkginfo";
  version = "1.12.1.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-XNlXgkrDbxQCYJZOujxr5kQqg1m4xI9K35AhDzOgS3s=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTests = [
    # wheel metadata version mismatch 2.1 vs 2.2
    "test_get_metadata_w_module"
    "test_get_metadata_w_package_name"
    "test_installed_ctor_w_dist_info"
    "test_installed_ctor_w_name"
    "test_installed_ctor_w_package"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pkginfo" ];

  meta = {
    description = "Query metadatdata from sdists, bdists or installed packages";

    longDescription = ''
      This package provides an API for querying the distutils metadata
      written in the PKG-INFO file inside a source distriubtion (an sdist)
      or a binary distribution (e.g., created by running bdist_egg). It can
      also query the EGG-INFO directory of an installed distribution, and the
      *.egg-info stored in a “development checkout” (e.g, created by running
      setup.py develop).
    '';

    homepage = "https://code.launchpad.net/~tseaver/pkginfo";
    changelog = "https://pypi.org/project/pkginfo/#pkginfo-changelog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "pkginfo";
  };
}
