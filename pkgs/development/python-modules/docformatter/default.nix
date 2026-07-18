{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  charset-normalizer,
  mock,
  poetry-core,
  pytestCheckHook,
  untokenize,
}:

buildPythonPackage rec {
  pname = "docformatter";
  version = "1.7.8";

  src = fetchFromGitHub {
    owner = "PyCQA";
    repo = "docformatter";
    tag = "v${version}";
    hash = "sha256-Z1ZW5ljWRDnS2mlAmbQyAcE97nU+PrpKaP1aox3VQtQ=";
  };

  patches = [ ./test-path.patch ];

  postPatch = ''
    substituteInPlace tests/conftest.py \
      --subst-var-by docformatter $out/bin/docformatter
  '';

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    charset-normalizer
    untokenize
  ];

  disabledTests = [
    # AssertionError: assert 'utf_16' == 'latin-1'
    # fixed by https://github.com/PyCQA/docformatter/pull/323
    "test_detect_encoding_with_undetectable_encoding"
  ];

  pyproject = true;
  pythonImportsCheck = [ "docformatter" ];

  meta = {
    description = "Formats docstrings to follow PEP 257";
    homepage = "https://github.com/myint/docformatter";
    changelog = "https://github.com/PyCQA/docformatter/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "docformatter";
  };
}
