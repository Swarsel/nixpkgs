{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  cssselect,
  html5lib,
  hypothesis,
  lxml,
  mypy,
  pdm-backend,
  pook,
  pyright,
  pytestCheckHook,
  typeguard,
  types-html5lib,
  typing-extensions,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "types-lxml";
  version = "2026.01.01";

  src = fetchFromGitHub {
    owner = "abelcheung";
    repo = "types-lxml";
    tag = finalAttrs.version;
    hash = "sha256-odkIwuh2VxDliRd6cPTCBSz19zxIBOBlVN0Sisngkn0=";
  };

  nativeCheckInputs = [
    beautifulsoup4
    html5lib
    hypothesis
    lxml
    pook
    pytestCheckHook
    typeguard
    urllib3
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  # there may only be one conftest.py
  preCheck = ''
    rm -r tests/static
    mv tests/runtime/* tests/
    rmdir tests/runtime
    substituteInPlace tests/conftest.py \
      --replace-fail '"pytest-revealtype-injector",' "" \
      --replace-fail 'runtime.register_strategy' 'tests.register_strategy'
  '';

  build-system = [ pdm-backend ];

  dependencies = [
    cssselect
    beautifulsoup4
    types-html5lib
    typing-extensions
  ];

  disabledTests = [
    "test_single_ns_all_tag_2"
    "test_default_ns"
    # Tests require network access
    "TestRelaxNGInput"
    "TestXmldtdid"
    "TestIddict"
    "TestParseid"
    # BaseExceptionGroup: Hypothesis found 5 distinct failures. (5 sub-exceptions)
    "test_start_arg_bad_1"
    "test_stop_arg_bad_1"
    "test_index_arg_bad_1"
  ];

  optional-dependencies = {
    mypy = [ mypy ];
    pyright = [ pyright ];
  };

  pyproject = true;
  pythonImportsCheck = [ "lxml-stubs" ];
  pythonRelaxDeps = [ "beautifulsoup4" ];

  meta = {
    description = "Complete lxml external type annotation";
    homepage = "https://github.com/abelcheung/types-lxml";
    changelog = "https://github.com/abelcheung/types-lxml/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
