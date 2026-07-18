{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  setuptools,
}:

buildPythonPackage rec {
  pname = "linknlink";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "xuanxuan000";
    repo = "python-linknlink";
    tag = version;
    hash = "sha256-ObPEcdDHi+SPFjuVKBtu7/5/IgHcam+IWblxxS3+mmI=";
  };

  # Module has no test
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ cryptography ];
  pyproject = true;
  pythonImportsCheck = [ "linknlink" ];

  meta = {
    description = "Module and CLI for controlling Linklink devices locally";
    homepage = "https://github.com/xuanxuan000/python-linknlink";
    changelog = "https://github.com/xuanxuan000/python-linknlink/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
