{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "rfk101py";
  version = "0.0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-O8W404opbjH4AIUAfM01xrzXM/2WzU6q7uxM5ySgdhg=";
  };

  # Package has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "rfk101py" ];

  meta = {
    description = "RFK101 Proximity card reader over Ethernet";
    homepage = "https://github.com/dubnom/rfk101py";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
