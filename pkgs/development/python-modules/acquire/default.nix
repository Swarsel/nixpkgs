{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  defusedxml,
  dissect-cstruct,
  dissect-target,
  minio,
  pycryptodome,
  pytestCheckHook,
  requests,
  requests-toolbelt,
  rich,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "acquire";
  version = "3.22";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "acquire";
    tag = version;
    hash = "sha256-CtzVHnQALqA5D0wJQ74lAw9HunVFZEkKvij6RQaQrBE=";
  };

  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.full;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    defusedxml
    dissect-cstruct
    dissect-target
  ];

  disabledTests = [
    "output_encrypt"
    "test_collector_collect_glob"
    "test_collector_collect_path_with_dir"
    "test_misc_osx"
    "test_misc_unix"
  ];

  optional-dependencies = {
    full = [
      dissect-target
      minio
      pycryptodome
      requests
      requests-toolbelt
      rich
    ]
    ++ dissect-target.optional-dependencies.full;
  };

  pyproject = true;
  pythonImportsCheck = [ "acquire" ];

  meta = {
    description = "Tool to quickly gather forensic artifacts from disk images or a live system";
    homepage = "https://github.com/fox-it/acquire";
    changelog = "https://github.com/fox-it/acquire/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
