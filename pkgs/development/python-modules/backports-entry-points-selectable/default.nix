{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "backports-entry-points-selectable";
  version = "1.3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-F6i0SucA+6VIaG3SdN3JHAYDcVZc1jgGwgodM5EXRuY=";
    pname = "backports.entry_points_selectable";
  };

  nativeBuildInputs = [ setuptools-scm ];
  # no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "backports.entry_points_selectable" ];
  pythonNamespaces = [ "backports" ];

  meta = {
    description = "Compatibility shim providing selectable entry points for older implementations";
    homepage = "https://github.com/jaraco/backports.entry_points_selectable";
    changelog = "https://github.com/jaraco/backports.entry_points_selectable/blob/v${version}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
