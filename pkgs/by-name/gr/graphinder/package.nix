{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "graphinder";
  version = "2.0.0b4";

  src = fetchFromGitHub {
    owner = "Escape-Technologies";
    repo = "graphinder";
    tag = "v${finalAttrs.version}";
    hash = "sha256-emBWhEJxYRAw3WTd8t+lurnHX8SeCcLBHGH9B+Owuag=";
  };

  nativeCheckInputs = with python3.pkgs; [
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    aiohttp
    beautifulsoup4
    requests
    setuptools
  ];

  disabledTests = [
    # Tests require network access
    "test_domain_class"
    "test_extract_file_zip"
    "test_fetch_assets"
    "test_full_run"
    "test_init_domain_tasks"
    "test_is_gql_endpoint"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "graphinder"
  ];

  meta = {
    description = "Tool to find GraphQL endpoints using subdomain enumeration";
    homepage = "https://github.com/Escape-Technologies/graphinder";
    changelog = "https://github.com/Escape-Technologies/graphinder/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "graphinder";
  };
})
