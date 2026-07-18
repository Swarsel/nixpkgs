{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  callPackage,
  # dependencies
  catalogue,
  # build-system
  cymem,
  cython,
  git,
  hypothesis,
  jinja2,
  langcodes,
  mock,
  murmurhash,
  nix,
  nix-update,
  numpy,
  packaging,
  preshed,
  pydantic,
  # tests
  pytestCheckHook,
  requests,
  setuptools,
  spacy-legacy,
  spacy-loggers,
  spacy-lookups-data,
  # optional-dependencies
  spacy-transformers,
  srsly,
  thinc,
  tqdm,
  typer,
  wasabi,
  weasel,
  # passthru
  writeScript,
}:

buildPythonPackage (finalAttrs: {
  pname = "spacy";
  version = "3.8.14";

  src = fetchFromGitHub {
    owner = "explosion";
    repo = "spaCy";
    tag = "release-v${finalAttrs.version}";
    hash = "sha256-w9cNP304H/EntpoMkXGwkxIVoThkl5HZPDK4+k4Py0Y=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
    mock
  ];

  # Fixes ModuleNotFoundError when running tests on Cythonized code. See #255262
  preCheck = ''
    cd $out
  '';

  __darwinAllowLocalNetworking = true; # needed for test_find_available_port

  build-system = [
    cymem
    cython
    murmurhash
    numpy
    preshed
    thinc
  ];

  dependencies = [
    catalogue
    cymem
    jinja2
    langcodes
    murmurhash
    numpy
    packaging
    preshed
    pydantic
    requests
    setuptools
    spacy-legacy
    spacy-loggers
    srsly
    thinc
    tqdm
    typer
    wasabi
    weasel
  ];

  disabledTestMarks = [ "slow" ];

  disabledTests = [
    # touches network
    "test_download_compatibility"
    "test_validate_compatibility_table"
    "test_project_assets"
    "test_find_available_port"

    # Tests for presence of outdated (and thus missing) spacy models
    # https://github.com/explosion/spaCy/issues/13856
    "test_registry_entries"

    # AssertionError: confection has different version in setup.cfg and in requirements.txt:
    # >=1.3.2,<2.0.0 and >=1.1.0,<2.0.0 respectively
    "test_build_dependencies"
  ];

  optional-dependencies = {
    lookups = [ spacy-lookups-data ];
    transformers = [ spacy-transformers ];
  };

  pyproject = true;
  pythonImportsCheck = [ "spacy" ];
  pythonRelaxDeps = [ "thinc" ];

  passthru = {
    tests.annotation = callPackage ./annotation-test { };

    updateScript = writeScript "update-spacy" ''
      #!${stdenv.shell}
      set -eou pipefail
      PATH=${
        lib.makeBinPath [
          git
          nix
          nix-update
        ]
      }

      nix-update python3Packages.spacy --version-regex 'release-v([0-9.]+)'

      # update spacy models as well
      echo | nix-shell maintainers/scripts/update.nix --argstr package python3Packages.spacy-models.en_core_web_sm
    '';
  };

  meta = {
    description = "Industrial-strength Natural Language Processing (NLP)";
    homepage = "https://github.com/explosion/spaCy";
    changelog = "https://github.com/explosion/spaCy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sarahec ];
    mainProgram = "spacy";
  };
})
