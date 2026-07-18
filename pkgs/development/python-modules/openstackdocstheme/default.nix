{
  lib,
  buildPythonPackage,
  dulwich,
  fetchPypi,
  pbr,
  setuptools,
  sphinx,
}:

buildPythonPackage rec {
  pname = "openstackdocstheme";
  version = "3.5.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-3h1dXtIMk1/CgbUP30ppUo+Q8qdb7PQtGIRD9eGWwJ8=";
  };

  postPatch = ''
    patchShebangs bin/
  '';

  # no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    dulwich
    pbr
    sphinx
  ];

  pyproject = true;
  pythonImportsCheck = [ "openstackdocstheme" ];

  meta = {
    description = "Sphinx theme for RST-sourced documentation published to docs.openstack.org";
    homepage = "https://github.com/openstack/openstackdocstheme";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
