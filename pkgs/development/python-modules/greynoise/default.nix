{
  lib,
  fetchFromGitHub,
  ansimarkup,
  buildPythonPackage,
  cachetools,
  click,
  click-default-group,
  click-repl,
  colorama,
  dict2xml,
  hatchling,
  jinja2,
  mock,
  more-itertools,
  pytestCheckHook,
  requests,
  six,
  # The REPL depends on click-repl, which is incompatible with our version of
  # click.
  withRepl ? false,
}:

buildPythonPackage rec {
  pname = "greynoise";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "GreyNoise-Intelligence";
    repo = "pygreynoise";
    tag = "v${version}";
    hash = "sha256-ClNKDMfMKcOYOasUqmQoOtKFsAi5wZw/MLTkq5YzpJk=";
  };

  patches = lib.optionals (!withRepl) [
    ./remove-repl.patch
  ];

  nativeCheckInputs = [
    pytestCheckHook
    mock
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    click
    ansimarkup
    cachetools
    colorama
    click-default-group
    dict2xml
    jinja2
    more-itertools
    requests
    six
  ]
  ++ lib.optionals withRepl [
    click-repl
  ];

  pyproject = true;
  pythonImportsCheck = [ "greynoise" ];

  pythonRelaxDeps = [
    "click"
  ];

  meta = {
    description = "Python3 library and command line for GreyNoise";
    homepage = "https://github.com/GreyNoise-Intelligence/pygreynoise";
    changelog = "https://github.com/GreyNoise-Intelligence/pygreynoise/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "greynoise";
  };
}
