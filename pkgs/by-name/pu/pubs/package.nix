{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "pubs";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "pubs";
    repo = "pubs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-U/9MLqfXrzYVGttFSafw4pYDy26WgdsJMCxciZzO1pw=";
  };

  patches = [
    # https://github.com/pubs/pubs/pull/278
    (fetchpatch {
      hash = "sha256-6qoufKPv3k6C9BQTZ2/175Nk7zWPh89vG+zebx6ZFOk=";
      url = "https://github.com/pubs/pubs/commit/9623d2c3ca8ff6d2bb7f6c8d8624f9a174d831bc.patch";
    })
    # https://github.com/pubs/pubs/pull/279
    (fetchpatch {
      hash = "sha256-UBkKiYaG6y6z8lsRpdcsaGsoklv6qj07KWdfkQcVl2g=";
      url = "https://github.com/pubs/pubs/commit/05e214eb406447196c77c8aa3e4658f70e505f23.patch";
    })
  ];

  nativeCheckInputs = with python3.pkgs; [
    ddt
    mock
    pyfakefs
    pytestCheckHook
  ];

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    argcomplete
    beautifulsoup4
    bibtexparser
    configobj
    feedparser
    python-dateutil
    pyyaml
    requests
    six
    standard-pipes # https://github.com/pubs/pubs/issues/282
  ];

  disabledTestPaths = [
    # Disabling git tests because they expect git to be preconfigured
    # with the user's details. See
    # https://github.com/NixOS/nixpkgs/issues/94663
    "tests/test_git.py"
  ];

  disabledTests = [
    # https://github.com/pubs/pubs/issues/276
    "test_readme"
    # AssertionError: Lists differ: ['Ini[112 chars]d to...
    "test_add_non_standard"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pubs"
  ];

  meta = {
    description = "Command-line bibliography manager";
    homepage = "https://github.com/pubs/pubs";
    changelog = "https://github.com/pubs/pubs/blob/v${finalAttrs.version}/changelog.md";
    license = lib.licenses.lgpl3Only;

    maintainers = with lib.maintainers; [
      dotlambda
    ];

    mainProgram = "pubs";
  };
})
