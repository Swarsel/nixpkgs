{
  lib,
  fetchFromGitHub,
  # dependencies
  babelfish,
  beautifulsoup4,
  buildPythonPackage,
  chardet,
  click,
  click-option-group,
  # nativeCheckInputs
  colorama,
  defusedxml,
  dogpile-cache,
  enzyme,
  guessit,
  hatch-vcs,
  # build-system
  hatchling,
  knowit,
  mypy,
  platformdirs,
  pypandoc,
  pysubs2,
  pytest-cov-stub,
  pytest-xdist,
  pytestCheckHook,
  rarfile,
  requests,
  srt,
  stevedore,
  sympy,
  tomli,
  tomlkit,
  vcrpy,
}:

buildPythonPackage rec {
  pname = "subliminal";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "Diaoul";
    repo = "subliminal";
    tag = version;
    hash = "sha256-fNrWdj8jnTH8O7mrltyApgBOd7zMA5wcaMizG6/Z0BU=";
  };

  propagatedBuildInputs = [
    babelfish
    beautifulsoup4
    chardet
    click
    click-option-group
    defusedxml
    dogpile-cache
    enzyme
    guessit
    knowit
    srt
    pysubs2
    rarfile
    requests
    platformdirs
    stevedore
    tomli
    tomlkit
  ];

  nativeCheckInputs = [
    colorama
    pypandoc
    pytestCheckHook
    pytest-cov-stub
    pytest-xdist
    mypy
    sympy
    vcrpy
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  disabledTests = [
    # Tests require network access
    "integration"
    "test_cli_cache"
    "test_cli_download"
    "test_is_supported_archive"
    "test_refine"
    "test_scan"
    "test_hash"
  ];

  pyproject = true;
  pythonImportsCheck = [ "subliminal" ];

  meta = {
    description = "Python library to search and download subtitles";
    homepage = "https://github.com/Diaoul/subliminal";
    changelog = "https://github.com/Diaoul/subliminal/blob/${src.tag}/HISTORY.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
    mainProgram = "subliminal";
  };
}
