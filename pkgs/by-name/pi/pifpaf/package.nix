{
  lib,
  addBinToPathHook,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pifpaf";
  version = "3.4.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-f9nPb483tuvNk82wDtuB6553z18qY/x0tgz1NbVGUWE=";
  };

  nativeCheckInputs =
    with python3Packages;
    [
      requests
      testtools
    ]
    ++ [
      addBinToPathHook
    ];

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    click
    daiquiri
    fixtures
    jinja2
    pbr
    psutil
    xattr
  ];

  pyproject = true;
  pythonImportsCheck = [ "pifpaf" ];

  meta = {
    description = "Suite of tools and fixtures to manage daemons for testing";
    homepage = "https://github.com/jd/pifpaf";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "pifpaf";
  };
})
