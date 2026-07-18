{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  setuptools,
}:

buildPythonPackage rec {
  pname = "sockjs";
  version = "0.13.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-V+lZoj8gqNVRSdHl2ws7hwcm8rStgWbUG9z0EbNs33Y=";
  };

  patches = [
    # https://github.com/aio-libs/sockjs/pull/453
    (fetchpatch {
      hash = "sha256-DV+OFiFV/A7ts24xz7pbTYXVvy/NA5kzwayj0m9Kt3I=";
      name = "replace-async-timeout-with-asyncio.timeout.patch";
      url = "https://github.com/aio-libs/sockjs/commit/322cec1ddc4ba35d6409565fa170eb03dbaa405b.patch";
    })
  ];

  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "sockjs" ];

  meta = {
    description = "Sockjs server";
    homepage = "https://github.com/aio-libs/sockjs";
    changelog = "https://github.com/aio-libs/sockjs/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
