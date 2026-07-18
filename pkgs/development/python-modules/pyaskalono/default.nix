{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "pyaskalono";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "kumekay";
    repo = "pyaskalono";
    tag = "v${version}";
    hash = "sha256-gNQCtubPs8XjE+ZTuTTzZGkxOhK3/Fv3lDLparaUdaQ=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-rQP6So9tG/9cjB588v+6lp2h+0SjaiWPhKrSXgDYugE=";
  };

  pyproject = true;
  pythonImportsCheck = [ "askalono" ];

  meta = {
    description = "Python wrapper for askalono";
    homepage = "https://github.com/kumekay/pyaskalono/";
    changelog = "https://github.com/kumekay/pyaskalono/releases/tag/v${version}";
    license = [ lib.licenses.asl20 ];
    maintainers = with lib.maintainers; [ erictapen ];
  };
}
