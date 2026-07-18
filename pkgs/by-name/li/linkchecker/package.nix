{
  lib,
  fetchFromGitHub,
  gettext,
  python3Packages,
  pdfSupport ? true,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "linkchecker";
  version = "10.6.0";

  src = fetchFromGitHub {
    owner = "linkchecker";
    repo = "linkchecker";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CzDShtqcGO2TP5qNVf2zkI3Yyh80I+pSVIFzmi3AaGQ=";
  };

  nativeBuildInputs = [ gettext ];

  nativeCheckInputs = with python3Packages; [
    pyopenssl
    parameterized
    pytestCheckHook
    pyftpdlib
  ];

  # Needed for tests to be able to create a ~/.local/share/linkchecker/plugins directory
  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  __darwinAllowLocalNetworking = true;

  build-system = with python3Packages; [
    hatchling
    hatch-vcs
    polib # translations
  ];

  dependencies =
    with python3Packages;
    [
      argcomplete
      beautifulsoup4
      dnspython
      requests
    ]
    ++ lib.optional pdfSupport pdfminer-six;

  disabledTests = [
    "test_timeit2" # flakey, and depends sleep being precise to the milisecond
  ];

  pyproject = true;

  meta = {
    description = "Check websites for broken links";
    homepage = "https://linkcheck.github.io/linkchecker/";
    changelog = "https://github.com/linkchecker/linkchecker/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      peterhoeg
      tweber
    ];

    mainProgram = "linkchecker";
  };
})
