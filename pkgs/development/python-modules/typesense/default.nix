{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  curl,
  faker,
  isort,
  pytest-mock,
  pytestCheckHook,
  python-dotenv,
  requests,
  requests-mock,
  setuptools,
  typesense,
}:

buildPythonPackage rec {
  pname = "typesense";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "typesense";
    repo = "typesense-python";
    tag = "v${version}";
    hash = "sha256-vo9DW4kinb00zWW4yX8ibyelQxW3eVabn+oMddPEd18=";
  };

  patches = [
    # See <https://github.com/typesense/typesense-python/pull/103>.
    ./linux-only-metrics.patch
    ./generated-temp-path.patch
  ];

  nativeCheckInputs = [
    pytestCheckHook
    typesense
    curl
    pytest-mock
    requests-mock
    python-dotenv
    faker
    isort
  ];

  preCheck = ''
    TYPESENSE_API_KEY="xyz" \
    TYPESENSE_DATA_DIR="$(mktemp -d)" \
    typesense-server &

    typesense_pid=$!

    # Wait for typesense to finish starting.
    timeout 20 bash -c '
      while ! curl -s --fail localhost:8108/health; do sleep 1; done
    ' || false
  '';

  postCheck = ''
    kill $typesense_pid
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  disabledTestMarks = [ "open_ai" ];
  disabledTests = [ "import_typing_extensions" ];
  pyproject = true;
  pythonImportsCheck = [ "typesense" ];

  meta = {
    description = "Python client for Typesense, an open source and typo tolerant search engine";
    homepage = "https://github.com/typesense/typesense-python";
    license = lib.licenses.asl20;
    teams = [ lib.teams.ngi ];
  };
}
