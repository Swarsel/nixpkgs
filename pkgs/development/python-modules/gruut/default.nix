{
  lib,
  fetchFromGitHub,
  # dependencies
  babel,
  buildPythonPackage,
  callPackage,
  dateparser,
  gruut-ipa,
  jsonlines,
  networkx,
  num2words,
  numpy,
  # optional dependencies
  pydub,
  # checks
  pytestCheckHook,
  python-crfsuite,
  rapidfuzz,
  # build-system
  setuptools,
}:

let
  langPkgs = [
    "ar"
    "ca"
    "cs"
    "de"
    "en"
    "es"
    "fa"
    "fr"
    "it"
    "lb"
    "nl"
    "pt"
    "ru"
    "sv"
    "sw"
  ];
in
buildPythonPackage rec {
  pname = "gruut";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "gruut";
    tag = "v${version}";
    hash = "sha256-iwde6elsAbICZ+Rc7CPgcZTOux1hweVZc/gf4K+hP9M=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];

  dependencies = [
    babel
    dateparser
    gruut-ipa
    jsonlines
    networkx
    num2words
    numpy
    python-crfsuite
  ]
  ++ optional-dependencies.en;

  disabledTests = [
    # https://github.com/rhasspy/gruut/issues/25
    "test_lexicon_external"

    # requires mishkal library
    "test_fa"
    "test_ar"
  ];

  optional-dependencies = {
    train = [
      pydub
      rapidfuzz
    ];
  }
  // lib.genAttrs langPkgs (lang: [
    (callPackage ./language-pack.nix {
      inherit
        lang
        version
        src
        build-system
        ;
    })
  ]);

  pyproject = true;
  pythonImportsCheck = [ "gruut" ];
  pythonRelaxDeps = true;

  meta = {
    description = "Tokenizer, text cleaner, and phonemizer for many human languages";
    homepage = "https://github.com/rhasspy/gruut";
    license = lib.licenses.mit;
    mainProgram = "gruut";
    teams = [ lib.teams.tts ];
  };
}
