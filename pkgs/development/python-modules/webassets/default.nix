{
  lib,
  buildPythonPackage,
  distutils,
  fetchPypi,
  jinja2,
  mock,
  pytestCheckHook,
  pyyaml,
  setuptools,
  zope-dottedname,
}:

buildPythonPackage rec {
  pname = "webassets";
  version = "3.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-BSDl/W+8wBL0hv78YblmR02o/Bs1sFaansLLB4LxYHo=";
  };

  nativeCheckInputs = [
    jinja2
    mock
    pytestCheckHook
    distutils
  ];

  build-system = [ setuptools ];

  dependencies = [
    pyyaml
    zope-dottedname
  ];

  disabledTests = [
    "TestFilterBaseClass"
    "TestAutoprefixer6Filter"
    "TestBabel"
  ];

  pyproject = true;

  meta = {
    description = "Media asset management for Python, with glue code for various web frameworks";
    homepage = "https://github.com/miracle2k/webassets/";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    mainProgram = "webassets";
  };
}
