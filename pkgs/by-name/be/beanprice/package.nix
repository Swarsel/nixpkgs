{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "beanprice";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "beancount";
    repo = "beanprice";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Lhr8CRysZbI6dpPwRSN6DgvnKrxsIzH5YyZXRLU1l3Q=";
  };

  nativeCheckInputs = with python3Packages; [
    click
    pytestCheckHook
    regex
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    beancount
    curl-cffi
    diskcache
    python-dateutil
    regex
    requests
  ];

  # Disable tests that require internet access
  disabledTestPaths = [
    "beanprice/price_test.py"
    "beanprice/sources/yahoo_test.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "beanprice" ];

  meta = {
    description = "Price quotes fetcher for Beancount";

    longDescription = ''
      A script to fetch market data prices from various sources on the internet
      and render them for plain text accounting price syntax (and Beancount).
    '';

    homepage = "https://github.com/beancount/beanprice";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ alapshin ];
    mainProgram = "bean-price";
    broken = lib.versionOlder python3Packages.beancount.version "3";
  };
})
