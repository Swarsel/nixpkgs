{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  fetchpatch2,
  ratelim,
  requests,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "geocoder";
  version = "1.38.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-yZJTdMlhV30K7kA7Ceb46hlx2RPwEfAMpwx2vq96d+c=";
  };

  patches = [
    # Remove future package to address CVE-2025-50817, https://github.com/DenisCarriere/geocoder/pull/488
    (fetchpatch2 {
      hash = "sha256-v1sFe8xMzJjaPkRVdzW8MK3eYgFORxl+iug/qHvc26U=";
      name = "remove-future.patch";
      url = "https://github.com/DenisCarriere/geocoder/commit/b15f3bb227414e90020a560176eb06fd39660df5.patch";
    })
  ];

  # Tests are outdated
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    click
    ratelim
    requests
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "geocoder" ];

  meta = {
    description = "Module for geocoding";
    homepage = "https://pypi.org/project/geocoder/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
