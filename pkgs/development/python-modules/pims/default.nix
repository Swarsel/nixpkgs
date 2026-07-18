{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  imageio,
  jinja2,
  jpype1,
  matplotlib,
  moviepy,
  numpy,
  packaging,
  pytestCheckHook,
  scikit-image,
  setuptools,
  slicerator,
  tifffile,
}:

buildPythonPackage (finalAttrs: {
  pname = "pims";
  version = "0.7";

  src = fetchFromGitHub {
    owner = "soft-matter";
    repo = "pims";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3SBZk11w6eTZFmETMRJaYncxY38CYne1KzoF5oRgzuY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.extras;

  build-system = [
    setuptools
  ];

  dependencies = [
    slicerator
    imageio
    numpy
    packaging
    tifffile # imported within try-excet block so optional but setup.py requires it.
  ];

  disabledTestPaths = [
    # AssertionError: Tuples differ: (377, 505, 4) != (384, 512, 4)
    "pims/tests/test_display.py"

    # tests require internet connection
    "pims/tests/test_bioformats.py"
  ];

  disabledTests = [
    # NotImplementedError: Do not know how to deal with infinite readers
    "TestVideo_ImageIO"
  ];

  optional-dependencies = {
    # CI says its extras
    extras = [
      jinja2
      jpype1
      matplotlib
      moviepy
      scikit-image
    ];
  };

  pyproject = true;

  pytestFlags = [
    "-Wignore::Warning"
  ];

  pythonImportsCheck = [ "pims" ];

  meta = {
    description = "Module to load video and sequential images in various formats";
    homepage = "https://github.com/soft-matter/pims";
    changelog = "https://github.com/soft-matter/pims/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
})
