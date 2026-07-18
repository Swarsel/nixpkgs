{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optionals
  cryptography,
  # build-system
  flit-core,
  fonttools,
  # tests
  fpdf2,
  myst-parser,
  pillow,
  pytest-timeout,
  pytestCheckHook,
  sphinx-rtd-theme,
  # docs
  sphinxHook,
}:

buildPythonPackage rec {
  pname = "pypdf";
  version = "6.14.2";

  src = fetchFromGitHub {
    owner = "py-pdf";
    repo = "pypdf";
    tag = version;
    hash = "sha256-h7JuQTTUZ5tWoAhixjp+grDVA3JQ8PbHcMBzIyCMOJU=";
    # fetch sample files used in tests
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "doc"
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "--disable-socket" ""
  '';

  nativeBuildInputs = [
    sphinxHook
    sphinx-rtd-theme
    myst-parser
  ];

  nativeCheckInputs = [
    (fpdf2.overridePythonAttrs { doCheck = false; }) # avoid reference loop
    pytestCheckHook
    pytest-timeout
  ]
  ++ optional-dependencies.full;

  build-system = [ flit-core ];

  disabledTestMarks = [
    # don't access the network
    "enable_socket"
  ];

  optional-dependencies = rec {
    crypto = [ cryptography ];
    fonts = [ fonttools ];
    full = crypto ++ fonts ++ image;
    image = [ pillow ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pypdf" ];

  meta = {
    description = "Pure-python PDF library capable of splitting, merging, cropping, and transforming the pages of PDF files";
    homepage = "https://github.com/py-pdf/pypdf";
    changelog = "https://github.com/py-pdf/pypdf/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ javaes ];
  };
}
