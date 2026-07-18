{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  coverage,
  ply,
  pycodestyle,
  pydocstyle,
  pyflakes,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "plyara";
  version = "2.2.8";

  src = fetchFromGitHub {
    owner = "plyara";
    repo = "plyara";
    tag = "v${version}";
    hash = "sha256-WaQgqx003it+D0AGDxV6aSKO89F2iR9d8L4zvHyd0iQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pycodestyle
    pydocstyle
    pyflakes
    coverage
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    ply
  ];

  disabledTests = [
    # touches network
    "test_third_party_repositories"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "plyara"
  ];

  meta = {
    description = "Parse YARA rules";
    homepage = "https://github.com/plyara/plyara";
    changelog = "https://github.com/plyara/plyara/releases/tag/v${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      _13621
      ivyfanchiang
    ];
  };
}
