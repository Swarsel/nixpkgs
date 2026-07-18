{
  lib,
  buildPythonPackage,
  fetchPypi,
  pbr,
  setuptools,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-apidoc";
  version = "0.6.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-MpuYENZpiPSOEnpr0YzI77vRzSC43rRpGjVzivSa2I0=";
    pname = "sphinxcontrib_apidoc";
  };

  postPatch = ''
    # break infite recursion, remove pytest 4 requirement
    rm test-requirements.txt requirements.txt
  '';

  nativeBuildInputs = [
    pbr
    setuptools
  ];

  # Check is disabled due to circular dependency of sphinx
  doCheck = false;
  pyproject = true;
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Sphinx extension for running sphinx-apidoc on each build";
    homepage = "https://github.com/sphinx-contrib/apidoc";
    license = lib.licenses.bsd2;
    teams = [ lib.teams.openstack ];
  };
}
