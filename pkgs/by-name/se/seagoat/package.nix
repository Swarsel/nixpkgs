{
  lib,
  fetchFromGitHub,
  # tests
  gitMinimal,
  nix-update-script,
  python3Packages,
  ripgrep,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "seagoat";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "kantord";
    repo = "SeaGOAT";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HdIvXXpMEynZV6J++kClNDubXuPORn6GEPHSD+UYBv0=";
  };

  nativeCheckInputs =
    with python3Packages;
    [
      pytestCheckHook
      freezegun
      pytest-asyncio
      pytest-mock
      pytest-snapshot
    ]
    ++ [
      gitMinimal
      ripgrep
      versionCheckHook
      writableTmpDirAsHomeHook
    ];

  preCheck = ''
    git init
  '';

  postInstall = ''
    wrapProgram $out/bin/seagoat-server \
      --prefix PATH : "${ripgrep}/bin"
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ python3Packages.poetry-core ];

  dependencies = with python3Packages; [
    appdirs
    blessed
    chardet
    chromadb
    deepmerge
    flask
    gitpython
    halo
    jsonschema
    nest-asyncio
    ollama
    psutil
    pygments
    python-dotenv
    requests
    stop-words
    waitress
  ];

  # require network access
  disabledTestPaths = [
    "tests/test_chroma.py"
  ];

  disabledTests = import ./failing_tests.nix;
  pyproject = true;

  pythonRelaxDeps = [
    "chromadb"
    "psutil"
    "setuptools"
    "stop-words"
    "ollama"
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Local-first semantic code search engine";
    homepage = "https://kantord.github.io/SeaGOAT/";
    changelog = "https://github.com/kantord/SeaGOAT/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lavafroth ];
    mainProgram = "seagoat";
  };
})
