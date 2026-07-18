{
  lib,
  fetchFromGitHub,
  aiofiles,
  buildPythonPackage,
  cryptography,
  protobuf,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "androidtvremote2";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "tronikos";
    repo = "androidtvremote2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-W+L1yQ7FAoKIlYtlM7gfPv8Tco/9hCDDUQQ16xg+++s=";
  };

  # Module only has a dummy test
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiofiles
    cryptography
    protobuf
  ];

  pyproject = true;
  pythonImportsCheck = [ "androidtvremote2" ];

  meta = {
    description = "Library to interact with the Android TV Remote protocol v2";
    homepage = "https://github.com/tronikos/androidtvremote2";
    changelog = "https://github.com/tronikos/androidtvremote2/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
