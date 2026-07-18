{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  defusedxml,
  gql,
  graphql-core,
  marshmallow,
  pydantic,
  pydantic-extra-types,
  pytest-cov-stub,
  pytest-datafiles,
  pytest-vcr,
  pytestCheckHook,
  python-box,
  python-dateutil,
  requests,
  requests-pkcs12,
  requests-toolbelt,
  responses,
  restfly,
  semver,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytenable";
  version = "26.6.1";

  src = fetchFromGitHub {
    owner = "tenable";
    repo = "pyTenable";
    tag = finalAttrs.version;
    hash = "sha256-KRZbrJgIxdNAnlmP7Ww/JasoDJqJZkBkd0qXm9gfXp4=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-datafiles
    pytest-vcr
    pytestCheckHook
    requests-pkcs12
    responses
  ];

  build-system = [ setuptools ];

  dependencies = [
    cryptography
    defusedxml
    gql
    graphql-core
    marshmallow
    pydantic
    pydantic-extra-types
    python-box
    python-dateutil
    requests
    requests-toolbelt
    restfly
    semver
    typing-extensions
  ];

  disabledTestPaths = [
    # Disable tests that requires network access
    "tests/io/"
  ];

  disabledTests = [
    # Disable tests that requires a Docker container
    "test_uploads_docker_push_name_typeerror"
    "test_uploads_docker_push_tag_typeerror"
    "test_uploads_docker_push_cs_name_typeerror"
    "test_uploads_docker_push_cs_tag_typeerror"
    # Test requires network access
    "test_assets_list_vcr"
    "test_events_list_vcr"
    "test_session_ssl_error"
    # https://github.com/tenable/pyTenable/issues/953
    "test_construct_query_str"
    "test_construct_query_stored_file"
    "test_iterator_empty_page"
    "test_iterator_max_page_term"
    "test_iterator_pagination"
    "test_iterator_total_term"
  ];

  pyproject = true;

  pytestFlags = [
    "-Wignore::pytest.PytestRemovedIn9Warning"
  ];

  pythonImportsCheck = [ "tenable" ];

  meta = {
    description = "Python library for the Tenable.io and TenableSC API";
    homepage = "https://github.com/tenable/pyTenable";
    changelog = "https://github.com/tenable/pyTenable/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
