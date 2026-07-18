{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "omekasy";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "ikanago";
    repo = "omekasy";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wPAobYZAytzTIWGBeBVoRLjm/0Io/P7GXL1naB6ssNM=";
  };

  cargoHash = "sha256-sJ8HFANK1fGj9zygq1RgMKcHncVik3St9GSghXP4tp0=";
  buildNoDefaultFeatures = stdenv.targetPlatform.isWasi;

  meta = {
    description = "Command line application that converts alphanumeric characters to various styles defined in Unicode";
    homepage = "https://github.com/ikanago/omekasy";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jcaesar ];
    mainProgram = "omekasy";
  };
})
