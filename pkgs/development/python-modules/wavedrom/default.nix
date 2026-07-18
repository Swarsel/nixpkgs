{
  lib,
  attrdict,
  buildPythonPackage,
  cairosvg,
  fetchPypi,
  pillow,
  pytestCheckHook,
  pyyaml,
  setuptools,
  setuptools-scm,
  six,
  svgwrite,
  xmldiff,
}:

buildPythonPackage (finalAttrs: {
  pname = "wavedrom";
  version = "2.0.3.post3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-MntNXcpZPIElfCAv6lFvepCHR/sRUnw1nwNPW3r39Hs=";
  };

  nativeCheckInputs = [
    cairosvg
    pillow
    pytestCheckHook
    xmldiff
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    attrdict
    pyyaml
    svgwrite
    six
  ];

  disabledTests = [
    # Requires to clone a full git repository
    "test_upstream"
  ];

  pyproject = true;
  pythonImportsCheck = [ "wavedrom" ];

  meta = {
    description = "WaveDrom compatible Python command line";
    homepage = "https://github.com/wallento/wavedrompy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ airwoodix ];
    mainProgram = "wavedrompy";
  };
})
