{
  lib,
  fetchFromGitHub,
  # dependencies
  attrs,
  azure-common,
  azure-core,
  azure-identity,
  azure-keyvault-secrets,
  azure-kusto-data,
  azure-mgmt-keyvault,
  azure-mgmt-subscription,
  azure-monitor-query,
  beautifulsoup4,
  bokeh,
  buildPythonPackage,
  cryptography,
  deprecated,
  dnspython,
  folium,
  geoip2,
  html5lib,
  httpx,
  importlib-resources,
  ipython,
  ipywidgets,
  keyring,
  lxml,
  msal,
  msal-extensions,
  msrest,
  msrestazure,
  nest-asyncio,
  networkx,
  packaging,
  pandas,
  panel,
  pydantic,
  pygments,
  pyjwt,
  pyyaml,
  # build-system
  setuptools,
  tldextract,
  tqdm,
  typing-extensions,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "msticpy";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "msticpy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-utE77oSCAAYKmsyf8ZPep7spUSIoJXBU6NzeLpDIvUs=";
  };

  # Test requires network access
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    attrs
    azure-common
    azure-core
    azure-identity
    azure-keyvault-secrets
    azure-kusto-data
    azure-mgmt-keyvault
    azure-mgmt-subscription
    azure-monitor-query
    beautifulsoup4
    bokeh
    cryptography
    deprecated
    dnspython
    folium
    geoip2
    html5lib
    httpx
    importlib-resources
    ipython
    ipywidgets
    keyring
    lxml
    msal
    msal-extensions
    msrest
    msrestazure
    nest-asyncio
    networkx
    packaging
    pandas
    panel
    pydantic
    pygments
    pyjwt
    pyyaml
    tldextract
    tqdm
    typing-extensions
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "msticpy" ];

  pythonRelaxDeps = [
    "azure-kusto-data"
    "bokeh"
    "nest_asyncio"
    "pandas"
  ];

  meta = {
    description = "Microsoft Threat Intelligence Security Tools";
    homepage = "https://github.com/microsoft/msticpy";
    changelog = "https://github.com/microsoft/msticpy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
