{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  hatchling,
}:

buildPythonPackage rec {
  pname = "genie-partner-sdk";
  version = "1.0.11";

  src = fetchPypi {
    inherit version;
    hash = "sha256-eNeN+mtpPzY6p0iVo/ot0eLza/aeJP70PxNHx7/MVoY=";
    pname = "genie_partner_sdk";
  };

  nativeBuildInputs = [ hatchling ];
  propagatedBuildInputs = [ aiohttp ];
  # No tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "genie_partner_sdk" ];

  meta = {
    description = "SDK to interact with the AladdinConnect (or OHD) partner API";
    homepage = "https://github.com/Genie-Garage/aladdin-python-sdk";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
