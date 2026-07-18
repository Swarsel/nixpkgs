{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cffi,
  crc32c,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "google-crc32c";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "python-crc32c";
    tag = "v${version}";
    hash = "sha256-bNTWyOWie1tPiptJ6NPCyC5kzcCpgOZ0w5hKVw07iwc=";
  };

  buildInputs = [ crc32c ];

  env = {
    CFLAGS = "-I${crc32c}/include";
    LDFLAGS = "-L${crc32c}/lib";
  };

  nativeCheckInputs = [
    pytestCheckHook
    crc32c
  ];

  build-system = [ setuptools ];
  dependencies = [ cffi ];
  pyproject = true;
  pythonImportsCheck = [ "google_crc32c" ];

  meta = {
    description = "Wrapper the google/crc32c hardware-based implementation of the CRC32C hashing algorithm";
    homepage = "https://github.com/googleapis/python-crc32c";
    changelog = "https://github.com/googleapis/python-crc32c/blob/${src.tag}/CHANGELOG.md";
    license = with lib.licenses; [ asl20 ];
    maintainers = [ ];
  };
}
