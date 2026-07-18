{
  lib,
  fetchFromGitHub,
  nixosTests,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "toot";
  version = "0.52.1";

  src = fetchFromGitHub {
    owner = "ihabunek";
    repo = "toot";
    tag = finalAttrs.version;
    hash = "sha256-lsX/34bdnAFWn/MNrQjrPIgkbgFusLvuK54Wc6N8bJU=";
  };

  nativeCheckInputs = with python3Packages; [ pytest ];

  checkPhase = ''
    runHook preCheck
    py.test
    runHook postCheck
  '';

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    python-dateutil
    requests
    beautifulsoup4
    wcwidth
    urwid
    tomlkit
    click
    pillow
    term-image
    pysocks
  ];

  pyproject = true;
  passthru.tests.toot = nixosTests.pleroma;

  meta = {
    description = "Mastodon CLI interface";
    homepage = "https://github.com/ihabunek/toot";
    changelog = "https://github.com/ihabunek/toot/blob/refs/tags/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      matthiasbeyer
      aleksana
    ];

    mainProgram = "toot";
  };
})
