{
  lib,
  fetchFromGitHub,
  azure-common,
  azure-core,
  buildPythonPackage,
  gitUpdater,
  isodate,
  setuptools,
}:

buildPythonPackage rec {
  pname = "azure-search-documents";
  version = "11.5.2";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-sdk-for-python";
    tag = "azure_search_documents_${version}";
    hash = "sha256-RcVdqI50lsYed9L6Kz7faNLec1Y9zq685SGnwaEw6Qc=";
  };

  # require devtools_testutils which is a internal package for azure-sdk
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-core
    isodate
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.search.documents" ];
  sourceRoot = "${src.name}/sdk/search/azure-search-documents";

  passthru = {
    # multiple packages in the repo and the updater picks the wrong tag
    skipBulkUpdate = true;
    updateScript = gitUpdater { rev-prefix = "azure.search.documents_"; };
  };

  meta = {
    description = "Microsoft Azure Cognitive Search Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/search/azure-search-documents";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/${src.tag}/sdk/search/azure-search-documents/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
