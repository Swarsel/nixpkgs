{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  conjure-python-client,
  ffmpeg-python,
  hatchling,
  nominal-api,
  nominal-api-protos,
  pandas,
  pytest-cov-stub,
  pytestCheckHook,
  python-dateutil,
  pyyaml,
  requests,
  tabulate,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "nominal";
  version = "1.104.3";

  src = fetchFromGitHub {
    owner = "nominal-io";
    repo = "nominal-client";
    tag = "v${version}";
    hash = "sha256-+hJzDQND+eQ/za+V7HXHhwoGfIusXBUUWWSYwWu39ew=";
  };

  nativeCheckInputs = [
    nominal-api-protos
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    requests
    conjure-python-client
    nominal-api
    python-dateutil
    pandas
    typing-extensions
    click
    pyyaml
    tabulate
    ffmpeg-python
  ];

  disabledTestPaths = [
    "tests/cli/test_auth.py::test_good_request"
  ];

  optional-dependencies = {
    protos = [ nominal-api-protos ];
    # tdms = [ nptdms ]; nptdms is not in nixpkgs
  };

  pyproject = true;

  pythonImportsCheck = [
    "nominal"
    "nominal.core"
  ];

  meta = {
    description = "Automate Nominal workflows in Python";
    homepage = "https://github.com/nominal-io/nominal-client";
    changelog = "https://github.com/nominal-io/nominal-client/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ alkasm ];
  };
}
