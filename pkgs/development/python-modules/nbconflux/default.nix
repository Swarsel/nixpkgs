{
  lib,
  fetchFromGitHub,
  bleach,
  buildPythonPackage,
  html5lib,
  nbconvert,
  pytestCheckHook,
  requests,
  responses,
  setuptools,
  traitlets,
  versioneer,
}:

buildPythonPackage rec {
  pname = "nbconflux";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "vericast";
    repo = "nbconflux";
    tag = version;
    hash = "sha256-kHIuboFKLVsu5zlZ0bM1BUoQR8f1l0XWcaaVI9bECJw=";
  };

  patches = [
    # The original setup.py file is missing commas in the install_requires list
    ./setup-py.patch
  ];

  postPatch = ''
    # remove vendorized versioneer.py
    rm versioneer.py
  '';

  env.JUPYTER_PATH = "${nbconvert}/share/jupyter";

  nativeCheckInputs = [
    pytestCheckHook
    responses
  ];

  build-system = [
    setuptools
    versioneer
  ];

  dependencies = [
    bleach
    html5lib
    nbconvert
    requests
    traitlets
  ];

  disabledTests = [
    "test_post_to_confluence"
    "test_optional_components"
  ];

  pyproject = true;

  meta = {
    description = "Converts Jupyter Notebooks to Atlassian Confluence (R) pages using nbconvert";
    homepage = "https://github.com/Valassis-Digital-Media/nbconflux";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "nbconflux";
  };
}
