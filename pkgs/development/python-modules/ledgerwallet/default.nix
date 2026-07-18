{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  construct,
  cryptography,
  ecdsa,
  hidapi,
  intelhex,
  pillow,
  protobuf,
  requests,
  setuptools,
  setuptools-scm,
  tabulate,
  toml,
}:

buildPythonPackage rec {
  pname = "ledgerwallet";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "LedgerHQ";
    repo = "ledgerctl";
    rev = "v${version}";
    hash = "sha256-roDfj+igDBS+sTJL4hwYNg5vZzaq+F8QvDA9NucnrMA=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"protobuf >=3.20,<4"' '"protobuf >=3.20"'
  '';

  buildInputs = [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = [
    cryptography
    click
    construct
    ecdsa
    hidapi
    intelhex
    pillow
    protobuf
    requests
    tabulate
    toml
  ];

  # Regenerate protobuf bindings to lift the version upper-bound and enable
  # compatibility the current default protobuf library.
  preBuild = ''
    protoc --python_out=. --pyi_out=. ledgerwallet/proto/*.proto
  '';

  pyproject = true;
  pythonImportsCheck = [ "ledgerwallet" ];

  meta = {
    description = "Library to control Ledger devices";
    homepage = "https://github.com/LedgerHQ/ledgerctl";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      erdnaxe
    ];

    mainProgram = "ledgerctl";
  };
}
