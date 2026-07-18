{
  lib,
  fetchFromGitHub,
  base58,
  beautifulsoup4,
  bech32,
  buildPythonPackage,
  cashaddress,
  cbor,
  docx2python,
  eth-hash,
  intervaltree,
  langdetect,
  lxml,
  pdfminer-six,
  phonenumbers,
  python-magic,
  readabilipy,
  setuptools,
  solders,
}:

buildPythonPackage (finalAttrs: {
  pname = "iocsearcher";
  version = "2.8.3";

  src = fetchFromGitHub {
    owner = "malicialab";
    repo = "iocsearcher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jNITY4X6ywlkjzS5Udpd46JG7PoycXyy0uJ7+UqjuF4=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    base58
    beautifulsoup4
    bech32
    cashaddress
    cbor
    docx2python
    eth-hash
    intervaltree
    langdetect
    lxml
    pdfminer-six
    phonenumbers
    python-magic
    readabilipy
    solders
  ]
  ++ eth-hash.optional-dependencies.pycryptodome;

  pyproject = true;
  pythonImportsCheck = [ "iocsearcher" ];

  meta = {
    description = "Library and command line tool for extracting indicators of compromise (IOCs)";
    homepage = "https://github.com/malicialab/iocsearcher";
    changelog = "https://github.com/malicialab/iocsearcher/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "iocsearcher";
  };
})
