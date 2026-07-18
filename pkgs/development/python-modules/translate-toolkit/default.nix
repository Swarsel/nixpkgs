{
  lib,
  fetchFromGitHub,
  addBinToPathHook,
  aeidon,
  buildPythonPackage,
  # optional-dependencies
  charset-normalizer,
  fluent-syntax,
  gettext,
  iniparse,
  # dependencies
  lxml,
  mistletoe,
  phply,
  pyenchant,
  pyparsing,
  pytest-xdist,
  # tests
  pytestCheckHook,
  rapidfuzz,
  ruamel-yaml,
  # build-system
  setuptools-scm,
  syrupy,
  tomlkit,
  unicode-segmentation-rs,
  vobject,
}:

buildPythonPackage (finalAttrs: {
  pname = "translate-toolkit";
  version = "3.19.11";

  src = fetchFromGitHub {
    owner = "translate";
    repo = "translate";
    tag = finalAttrs.version;
    hash = "sha256-+94oo6IYnRR4jnR60C3WNjesK6Tk6jND3xsYyx6sw0U=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    addBinToPathHook
    pytest-xdist
    syrupy
    gettext
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools-scm ];

  dependencies = [
    lxml
    unicode-segmentation-rs
  ];

  disabledTests = [
    # Probably breaks because of nix sandbox
    "test_timezones"
  ];

  optional-dependencies = {
    chardet = [ charset-normalizer ];
    fluent = [ fluent-syntax ];
    ical = [ vobject ];
    ini = [ iniparse ];
    levenshtein = [ rapidfuzz ];
    markdown = [ mistletoe ];
    php = [ phply ];
    rc = [ pyparsing ];
    spellcheck = [ pyenchant ];
    subtitles = [ aeidon ];
    toml = [ tomlkit ];
    yaml = [ ruamel-yaml ];
  };

  pyproject = true;
  pythonImportsCheck = [ "translate" ];
  pythonRelaxDeps = [ "lxml" ];

  meta = {
    description = "Useful localization tools for building localization & translation systems";
    homepage = "https://toolkit.translatehouse.org/";
    changelog = "https://docs.translatehouse.org/projects/translate-toolkit/en/latest/releases/${finalAttrs.src.tag}.html";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ erictapen ];
  };
})
