{
  lib,
  fetchFromGitHub,
  autoflake,
  black,
  buildPythonPackage,
  # propagated build inputs
  click,
  coverage,
  fastapi,
  flake8,
  httpx,
  ipython,
  jinja2,
  mypy,
  nbconvert,
  nbdev,
  pandas,
  pytest-cov-stub,
  pytest-mock,
  # native check inputs
  pytestCheckHook,
  python-multipart,
  requests,
  requests-toolbelt,
  types-requests,
  types-ujson,
  uvicorn,
}:
let
  version = "0.10.11";
in
buildPythonPackage {
  inherit version;
  pname = "unstructured-api-tools";

  src = fetchFromGitHub {
    owner = "Unstructured-IO";
    repo = "unstructured-api-tools";
    tag = version;
    hash = "sha256-t1fK40ayR2bxc1iMIwvn/OHuyVlR98Gq+NpIhOmaP+4=";
  };

  propagatedBuildInputs = [
    click
    fastapi
    jinja2
    mypy
    nbconvert
    python-multipart
    pandas
    types-requests
    types-ujson
    uvicorn
    autoflake
  ]
  ++ uvicorn.optional-dependencies.standard;

  # test require file generation but it complains about a missing file mypy
  doCheck = false;

  # preCheck = ''
  #   substituteInPlace Makefile \
  #     --replace "PYTHONPATH=." "" \
  #     --replace "mypy" "${mypy}/bin/mypy"
  #   make generate-test-api
  # '';
  nativeCheckInputs = [
    pytestCheckHook
    black
    coverage
    flake8
    httpx
    ipython
    pytest-cov-stub
    requests
    requests-toolbelt
    nbdev
    pytest-mock
  ];

  format = "setuptools";
  pythonImportsCheck = [ "unstructured_api_tools" ];

  meta = {
    description = "";
    homepage = "https://github.com/Unstructured-IO/unstructured-api-tools";
    changelog = "https://github.com/Unstructured-IO/unstructured-api-tools/blob/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
    mainProgram = "unstructured_api_tools";
  };
}
