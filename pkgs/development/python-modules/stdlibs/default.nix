{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
}:

buildPythonPackage rec {
  pname = "stdlibs";
  version = "2026.2.26";

  src = fetchFromGitHub {
    owner = "omnilib";
    repo = "stdlibs";
    tag = "v${version}";
    hash = "sha256-5Brb214tglEEjsJXOvEhlaJgSYCUpOGPbHkmI9AWPoM=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ flit-core ];
  pyproject = true;
  pythonImportsCheck = [ "stdlibs" ];

  meta = {
    description = "Overview of the Python stdlib";
    homepage = "https://github.com/omnilib/stdlibs";
    changelog = "https://github.com/omnilib/stdlibs/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
