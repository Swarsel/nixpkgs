{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  googlemaps,
  # runtime
  openssl,
  # build-system
  pretix-plugin-build,
  replaceVars,
  setuptools,
  wallet-py3k,
}:

buildPythonPackage rec {
  pname = "pretix-passbook";
  version = "1.14.1";

  src = fetchFromGitHub {
    owner = "pretix";
    repo = "pretix-passbook";
    rev = "v${version}";
    hash = "sha256-cTXgDr845TGMGWr9bSaFvRPQ0GynXn3CVnZxcf96orc=";
  };

  patches = [
    (replaceVars ./openssl.patch {
      openssl = lib.getExe openssl;
    })
  ];

  doCheck = false; # no tests

  build-system = [
    pretix-plugin-build
    setuptools
  ];

  dependencies = [
    googlemaps
    wallet-py3k
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pretix_passbook"
  ];

  meta = {
    description = "Support for Apple Wallet/Passbook files in pretix";
    homepage = "https://github.com/pretix/pretix-passbook";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
