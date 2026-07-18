{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchNpmDeps,
  nodejs,
  npmHooks,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "esphome-dashboard";
  version = "20260425.0";

  src = fetchFromGitHub {
    owner = "esphome";
    repo = "dashboard";
    tag = finalAttrs.version;
    hash = "sha256-OhvRPIvytLmWkIvO45arikC3+7WCTdsEOwswuSAx0XA=";
  };

  postPatch = ''
    # https://github.com/esphome/dashboard/pull/639
    patchShebangs script/build
  '';

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  preBuild = ''
    script/build
  '';

  # no tests
  doCheck = false;
  build-system = [ setuptools ];

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-L6tKhijTFAvQwhBBl5Wk6xzI2dtDI6IYfCkiKX75Pvc=";
  };

  pyproject = true;

  pythonImportsCheck = [
    "esphome_dashboard"
  ];

  meta = {
    description = "ESPHome dashboard";
    homepage = "https://esphome.io/";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ hexa ];
  };
})
