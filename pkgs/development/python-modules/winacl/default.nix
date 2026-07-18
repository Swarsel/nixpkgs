{
  lib,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "winacl";
  version = "0.1.9";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-r3DC7DAXi/njyKHEjCXoeBI1/iwbMhrbRuLyrh+NSqs=";
  };

  # Project doesn't have tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ cryptography ];
  pyproject = true;
  pythonImportsCheck = [ "winacl" ];

  meta = {
    description = "Python module for ACL/ACE/Security descriptor manipulation";
    homepage = "https://github.com/skelsec/winacl";
    changelog = "https://github.com/skelsec/winacl/releases/tag/${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
