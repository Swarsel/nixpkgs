{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  onlinepayments-sdk-python3,
  pretix-plugin-build,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pretix-worldlinedirect";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "pretix";
    repo = "pretix-worldlinedirect";
    rev = "v${version}";
    hash = "sha256-SqXXnYetz52OFPKM61mANA71hrCEK7FgsdEoxskR5bk=";
  };

  build-system = [
    pretix-plugin-build
    setuptools
  ];

  dependencies = [
    onlinepayments-sdk-python3
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pretix_payonegopay"
    "pretix_worldlinedirect"
  ];

  meta = {
    description = "A pretix plugin to accept payments through Worldline Direct";
    homepage = "https://github.com/pretix/pretix-worldlinedirect";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
