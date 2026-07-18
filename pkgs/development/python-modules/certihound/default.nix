{
  lib,
  buildPythonPackage,
  click,
  cryptography,
  fetchPypi,
  impacket,
  ldap3,
  pydantic,
  rich,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "certihound";
  version = "0.3.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-uSoI4bz5h3Guy8TtfHjsk0zo9LNL2BJ5ZRFMFPk2Up0=";
  };

  # Tests are stripped in pypi
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    ldap3
    impacket
    cryptography
    pydantic
    click
    rich
  ];

  pyproject = true;
  pythonImportsCheck = [ "certihound" ];

  meta = {
    description = "Active Directory Certificate Services (ADCS) enumeration library with BloodHound CE v6 export support";
    homepage = "https://github.com/0x0Trace/Certihound";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ letgamer ];
  };
})
