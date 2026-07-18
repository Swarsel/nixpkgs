{
  lib,
  buildPythonPackage,
  charset-normalizer,
  fetchPypi,
  freetype,
  isPyPy,
  pillow,
  python,
  setuptools,
}:

let
  ft = freetype.overrideAttrs (oldArgs: {
    dontDisableStatic = true;
  });
in
buildPythonPackage rec {
  pname = "reportlab";
  version = "5.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-5ElKDGYjriE7uFb7pSMXGytUp79in9oC1eUlp7iZp4Q=";
  };

  postPatch = ''
    # Remove all the test files that require access to the internet to pass.
    rm tests/test_lib_utils.py
    rm tests/test_platypus_general.py
    rm tests/test_platypus_images.py

    # Remove the tests that require Vera fonts installed
    rm tests/test_graphics_render.py
    rm tests/test_graphics_charts.py
  '';

  buildInputs = [ ft ];

  checkPhase = ''
    runHook preCheck
    pushd tests
    ${python.interpreter} runAll.py
    popd
    runHook postCheck
  '';

  build-system = [ setuptools ];

  dependencies = [
    charset-normalizer
    pillow
  ];

  # See https://bitbucket.org/pypy/compatibility/wiki/reportlab%20toolkit
  disabled = isPyPy;
  pyproject = true;

  meta = {
    description = "Open Source Python library for generating PDFs and graphics";
    homepage = "https://www.reportlab.com/";
    changelog = "https://hg.reportlab.com/hg-public/reportlab/file/tip/CHANGES.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
