{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "mac-vendor-lookup";
  version = "0.1.15";

  src = fetchFromGitHub {
    owner = "bauerj";
    repo = "mac_vendor_lookup";
    tag = finalAttrs.version;
    hash = "sha256-RLCEyDalwQUVmcZdVPN1cyKLIPbWcZfjzIkClUZCeJU=";
  };

  postPatch = ''
    sed -i '/mac-vendors.txt/d' setup.py
  '';

  doCheck = false; # no tests
  build-system = [ setuptools ];

  dependencies = [
    aiofiles
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "mac_vendor_lookup" ];

  meta = {
    description = "Find the vendor for a given MAC address";
    homepage = "https://github.com/bauerj/mac_vendor_lookup";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "mac_vendor_lookup";
  };
})
