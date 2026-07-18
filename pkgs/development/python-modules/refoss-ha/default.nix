{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "refoss-ha";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "ashionky";
    repo = "refoss_ha";
    tag = "v${version}";
    hash = "sha256-HLPTXE16PizldeURVmoxcRVci12lc1PsCKH+gA1hr8Y=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "refoss_ha" ];

  meta = {
    description = "Refoss support for Home Assistant";
    homepage = "https://github.com/ashionky/refoss_ha";
    changelog = "https://github.com/ashionky/refoss_ha/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
