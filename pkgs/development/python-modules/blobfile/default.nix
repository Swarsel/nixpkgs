{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  filelock,
  lxml,
  pycryptodomex,
  setuptools,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "blobfile";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "christopher-hesse";
    repo = "blobfile";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aTHEJ1P+v9IWXPg9LN+KG1TlEVJh0qTl8J41iWpoPWk=";
  };

  # Tests require a running Docker instance
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    pycryptodomex
    filelock
    urllib3
    lxml
  ];

  pyproject = true;
  pythonImportsCheck = [ "blobfile" ];

  meta = {
    description = "Read Google Cloud Storage, Azure Blobs, and local paths with the same interface";
    homepage = "https://github.com/christopher-hesse/blobfile";
    changelog = "https://github.com/christopher-hesse/blobfile/blob/${finalAttrs.src.tag}/CHANGES.md";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ happysalada ];
  };
})
