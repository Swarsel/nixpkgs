{
  lib,
  fetchFromGitHub,
  buildNimPackage,
  versionCheckHook,
}:

buildNimPackage (finalAttrs: {
  pname = "mosdepth";
  version = "0.3.13";

  src = fetchFromGitHub {
    owner = "brentp";
    repo = "mosdepth";
    rev = "v${finalAttrs.version}";
    hash = "sha256-UjyfJSykAbE2RhRsixNx2JwCINMdSmukF5oW9OalyeA=";
  };

  nativeBuildInputs = [ versionCheckHook ];
  doInstallCheck = true;
  lockFile = ./lock.json;
  nimFlags = [ ''--passC:"-Wno-incompatible-pointer-types"'' ];

  meta = {
    description = "Fast BAM/CRAM depth calculation for WGS, exome, or targeted sequencing";
    homepage = "https://github.com/brentp/mosdepth";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jbedo
    ];

    platforms = lib.platforms.linux;
    mainProgram = "mosdepth";
  };
})
