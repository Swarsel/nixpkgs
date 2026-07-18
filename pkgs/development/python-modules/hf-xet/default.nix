{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  openssl,
  pkg-config,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "hf-xet";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "xet-core";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zAliMR2d2j6ynHQmAljQ8XgDyjuPxNawI1bZks5aRgs=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  buildInputs = [
    openssl
  ];

  env.OPENSSL_NO_VENDOR = 1;
  # No tests (yet?)
  doCheck = false;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      ;

    hash = "sha256-TOgBT0l7TvJamVdIAdAUFRWs8AMRRY+Ydoh6e+3dEp0=";
  };

  pyproject = true;
  pythonImportsCheck = [ "hf_xet" ];
  sourceRoot = "${finalAttrs.src.name}/hf_xet";

  meta = {
    description = "Xet client tech, used in huggingface_hub";
    homepage = "https://github.com/huggingface/xet-core/tree/main/hf_xet";
    changelog = "https://github.com/huggingface/xet-core/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
