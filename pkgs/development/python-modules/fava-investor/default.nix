{
  lib,
  stdenv,
  fetchFromGitHub,
  beancount,
  buildPythonPackage,
  click,
  click-aliases,
  fava,
  packaging,
  pytestCheckHook,
  python-dateutil,
  setuptools,
  setuptools-scm,
  tabulate,
  yfinance,
}:
buildPythonPackage rec {
  pname = "fava-investor";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "redstreet";
    repo = "fava_investor";
    tag = version;
    hash = "sha256-WuXbZcia0n9SoiCSB2SkMUjBHsMOA0gCIf9ZEU9pTPA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    beancount
    click
    click-aliases
    fava
    packaging
    python-dateutil
    tabulate
    yfinance
  ];

  disabledTestPaths = [
    # First differing element 1:
    # '-----------------  --------  ------------'
    # '-------------  --------  ------------'
    #
    #   ['asset_type    amount    percentage',
    # -  '-----------------  --------  ------------',
    # ?                ----
    #
    # +  '-------------  --------  ------------',
    "fava_investor/modules/assetalloc_class/test_asset_allocation.py::TestScriptCheck::test_multicurrency"
    "fava_investor/modules/assetalloc_class/test_asset_allocation.py::TestScriptCheck::test_tree_empty_parent"
  ];

  pyproject = true;
  pythonImportsCheck = [ "fava_investor" ];

  meta = {
    description = "Comprehensive set of reports, analyses, and tools for investments, for Beancount and Fava";
    homepage = "https://github.com/redstreet/fava_investor";
    changelog = "https://github.com/redstreet/fava_investor/blob/main/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ambroisie ];
  };
}
