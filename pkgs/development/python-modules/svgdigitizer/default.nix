{
  lib,
  fetchFromGitHub,
  # dependencies
  astropy,
  buildPythonPackage,
  click,
  frictionless,
  matplotlib,
  mergedeep,
  pandas,
  pillow,
  pybtex,
  pymupdf,
  # tests
  pytestCheckHook,
  pyyaml,
  scipy,
  # build-system
  setuptools,
  svg-path,
  svgpathtools,
  svgwrite,
}:

buildPythonPackage (finalAttrs: {
  pname = "svgdigitizer";
  version = "0.14.4";

  src = fetchFromGitHub {
    owner = "echemdb";
    repo = "svgdigitizer";
    tag = finalAttrs.version;
    hash = "sha256-sDMSzoXa8RnygFjveh1SrF+bFit7OMQh2kbiZ478cM4=";
  };

  # https://github.com/echemdb/svgdigitizer/issues/252
  env.MPLBACKEND = "Agg";

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    astropy
    click
    frictionless
    matplotlib
    mergedeep
    pandas
    pillow
    pybtex
    pymupdf
    pyyaml
    scipy
    svg-path
    svgpathtools
    svgwrite
  ];

  disabledTests = [
    # test tries to connect to doi.org
    "svgdigitizer.pdf.Pdf.bibliographic_entry"
  ];

  pyproject = true;

  pytestFlags = [
    "--doctest-modules"
    "svgdigitizer"
  ];

  pythonImportsCheck = [
    "svgdigitizer"
  ];

  # https://github.com/echemdb/svgdigitizer/issues/298
  pythonRelaxDeps = [
    "astropy"
  ];

  meta = {
    description = "Extract numerical data points from SVG files";
    homepage = "https://github.com/echemdb/svgdigitizer";
    changelog = "https://github.com/echemdb/svgdigitizer/blob/${finalAttrs.src.tag}/ChangeLog";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
})
