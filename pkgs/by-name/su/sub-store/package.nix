{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  fetchPnpmDeps,
  makeBinaryWrapper,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
}:
let
  pnpm = pnpm_10;
in
buildNpmPackage (finalAttrs: {
  pname = "sub-store";
  version = "2.22.26";

  src = fetchFromGitHub {
    owner = "sub-store-org";
    repo = "Sub-Store";
    tag = finalAttrs.version;
    hash = "sha256-EDYPDLB4oKAcArim9xIeyH4ijrRa4tTa2elfDaOpBfk=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    pnpm
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r dist $out/share/sub-store
    makeWrapper ${lib.getExe nodejs} $out/bin/sub-store \
      --add-flags "$out/share/sub-store/sub-store.bundle.js"

    runHook postInstall
  '';

  npmBuildScript = "bundle:esbuild";
  npmConfigHook = pnpmConfigHook;
  npmDeps = null;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      ;

    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-4RFzky/KaRSNvBizH717KtiwavO+KB69AwPKAAnTmh4=";
  };

  sourceRoot = "${finalAttrs.src.name}/backend";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Advanced Subscription Manager for QX, Loon, Surge, Stash, Egern and Shadowrocket";
    homepage = "https://github.com/sub-store-org/Sub-Store";
    changelog = "https://github.com/sub-store-org/Sub-Store/releases/tag/${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = nodejs.meta.platforms;
    mainProgram = "sub-store";
  };
})
