{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  certifi,
  chardet,
  cython,
  imagecodecs,
  lmdb,
  matplotlib,
  numpy,
  pandas,
  pynrrd,
  pytestCheckHook,
  requests,
  scipy,
  sdflit,
  seaborn,
  setuptools,
  tifffile,
  tqdm,
  typing-extensions,
  urllib3,
  wheel,
}:

buildPythonPackage (finalAttrs: {
  pname = "swcgeom";
  version = "0.21.6";

  src = fetchFromGitHub {
    owner = "yzx9";
    repo = "swcgeom";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Q9YvHHUAYGX3m9jJ+ogTYRrdPaCdrcNY2cNlKK7ThX4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    # make sure import the built version, not the source one
    rm -r swcgeom
  '';

  __structuredAttrs = true;

  build-system = [
    cython
    numpy
    setuptools
    wheel
  ];

  dependencies = [
    imagecodecs
    matplotlib
    numpy
    pandas
    pynrrd
    scipy
    sdflit
    seaborn
    tifffile
    tqdm
    typing-extensions
  ];

  optional-dependencies = {
    all = [
      beautifulsoup4
      certifi
      chardet
      lmdb
      requests
      urllib3
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "swcgeom"
  ];

  meta = {
    description = "Neuron geometry library for swc format";
    homepage = "https://github.com/yzx9/swcgeom";
    changelog = "https://github.com/yzx9/swcgeom/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ yzx9 ];
  };
})
