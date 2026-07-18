{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchNpmDeps,
  go-swag,
  nix-update-script,
  nodejs,
  npmHooks,
}:
buildGoModule (finalAttrs: {
  pname = "drasl";
  version = "3.4.4";

  src = fetchFromGitHub {
    owner = "unmojang";
    repo = "drasl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GHwgN1yWf/xav2t03/09x/U0c6fRBDmEn0mDIv+V9ic=";
  };

  postPatch = ''
    substituteInPlace build_config.go --replace-fail "\"/usr/share/drasl\"" "\"$out/share/drasl\""
  '';

  nativeBuildInputs = [
    go-swag
    nodejs
    npmHooks.npmConfigHook
  ];

  vendorHash = "sha256-4Rk59bnDFYpraoGvkBUW6Z5fiXUmm2RLwS1wxScWAMQ=";

  preBuild = ''
    make prebuild
  '';

  postInstall = ''
    mkdir -p "$out/share/drasl"
    cp -R ./{assets,view,public,locales} "$out/share/drasl"
  '';

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-L0y04zLgno5kKUACyokma8uk/fNY2mwdMwsq217SCqI=";
  };

  overrideModAttrs = oldAttrs: {
    nativeBuildInputs = lib.filter (drv: drv != npmHooks.npmConfigHook) oldAttrs.nativeBuildInputs;
    preBuild = null;
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Yggdrasil-compatible API server for Minecraft";
    homepage = "https://github.com/unmojang/drasl";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      evan-goode
      ungeskriptet
    ];

    mainProgram = "drasl";
  };
})
