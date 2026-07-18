{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optional-dependencies
  furo,
  myst-parser,
  # build-system
  poetry-core,
  # tests
  pytest-asyncio_0,
  pytest-cov-stub,
  pytestCheckHook,
  sphinx,
  sphinxHook,
}:

buildPythonPackage rec {
  pname = "aiohappyeyeballs";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "bdraco";
    repo = "aiohappyeyeballs";
    tag = "v${version}";
    hash = "sha256-BqwKo1zZ7CqkUZ9H05fbbHVj/z3m0xaERh5dGBDKFYI=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeCheckInputs = [
    pytest-asyncio_0
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ poetry-core ] ++ optional-dependencies.docs;

  optional-dependencies = {
    docs = [
      furo
      myst-parser
      sphinx
      sphinxHook
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "aiohappyeyeballs" ];

  meta = {
    description = "Happy Eyeballs for pre-resolved hosts";
    homepage = "https://github.com/bdraco/aiohappyeyeballs";
    changelog = "https://github.com/bdraco/aiohappyeyeballs/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.psfl;

    maintainers = with lib.maintainers; [
      fab
      hexa
    ];
  };
}
