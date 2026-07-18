{
  lib,
  stdenv,
  fetchFromGitHub,
  arrow,
  buildPythonPackage,
  cloudpickle,
  cryptography,
  lz4,
  numpy,
  pytestCheckHook,
  ruamel-yaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "construct";
  version = "2.10.70";

  src = fetchFromGitHub {
    owner = "construct";
    repo = "construct";
    tag = "v${version}";
    hash = "sha256-5otjjIyje0+z/Y/C2ivmu08PNm0oJcSSvZkQfGxHDuQ=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    # Not an explicit dependency, but it's imported by an entrypoint
    lz4
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  disabledTests = [
    "test_benchmarks"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ "test_multiprocessing" ];

  optional-dependencies = {
    extras = [
      arrow
      cloudpickle
      cryptography
      numpy
      ruamel-yaml
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "construct" ];

  meta = {
    description = "Powerful declarative parser (and builder) for binary data";
    homepage = "https://construct.readthedocs.org/";
    changelog = "https://github.com/construct/construct/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bjornfor ];
  };
}
