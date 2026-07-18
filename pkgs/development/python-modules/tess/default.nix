{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  numpy,
  pytestCheckHook,
  python,
  scipy,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "tess";
  version = "0.3.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-5Ic06+K7CWRh1t2v3aJ5JlBACvHXqQyYzvU71jZJFtI=";
  };

  # scipy has depecrated since version 1.15.0 the function `sph_harm`, and has
  # been removed in 1.17.0 in favor of `sph_harm_y`
  patches = [ ./scipy_sph_harm.patch ];
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    cd $out/${python.sitePackages}
  '';

  build-system = [
    cython
    setuptools
  ];

  dependencies = [
    numpy
    scipy
  ];

  enabledTestPaths = [ "tess/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "tess" ];

  meta = {
    description = "Module for calculating and analyzing Voronoi tessellations";
    homepage = "https://tess.readthedocs.org";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ drawbu ];
  };
})
