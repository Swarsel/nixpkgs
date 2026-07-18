{
  lib,
  fetchFromGitHub,
  asdf,
  asdf-astropy,
  asdf-wcs-schemas,
  astropy,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  scipy,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "gwcs";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "spacetelescope";
    repo = "gwcs";
    tag = finalAttrs.version;
    hash = "sha256-0iUnapBn8yDCx1tqHD10Ljid15yBuqlICyFuva2LNPk=";
  };

  postPatch = ''
    sed -i "/--doctest-rst/d" pyproject.toml
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    asdf
    asdf-astropy
    asdf-wcs-schemas
    astropy
    numpy
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "gwcs" ];

  meta = {
    description = "Module to manage the Generalized World Coordinate System";
    homepage = "https://github.com/spacetelescope/gwcs";
    changelog = "https://github.com/spacetelescope/gwcs/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
})
