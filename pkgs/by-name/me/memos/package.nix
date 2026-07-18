{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchPnpmDeps,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  stdenvNoCC,
}:
let
  pnpm = pnpm_10;
in
buildGoModule (finalAttrs: {
  pname = "memos";
  version = "0.29.1";

  src = fetchFromGitHub {
    owner = "usememos";
    repo = "memos";
    rev = "v${finalAttrs.version}";
    hash = "sha256-bc9NWP/CauR3gKBOPFg8urD9dSUq0jtfwQOknkPbX0s=";
  };

  vendorHash = "sha256-6oJgxhGS7aD3I0umTQuVMLzcOhzf53g4TZcCtkKrrc8=";

  preBuild = ''
    rm -rf server/router/frontend/dist
    cp -r ${finalAttrs.memos-web} server/router/frontend/dist
  '';

  ldflags = [
    "-X github.com/usememos/memos/internal/version.Version=${finalAttrs.version}"
  ];

  memos-web = stdenvNoCC.mkDerivation (finalWebAttrs: {
    inherit (finalAttrs) version src;
    pname = "memos-web";

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm
    ];

    buildPhase = ''
      runHook preBuild
      pnpm -C web build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r web/dist $out
      runHook postInstall
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit (finalWebAttrs) pname version src;
      inherit pnpm;
      fetcherVersion = 3;
      hash = "sha256-wj8Rh1/wYDKIrJQgdoJBtoP2xeQnrUBORE2Gegxwim0=";
      sourceRoot = "${finalWebAttrs.src.name}/web";
    };

    pnpmRoot = "web";
  });

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--subpackage"
      "memos-web"
    ];
  };

  meta = {
    description = "Lightweight, self-hosted memo hub";
    homepage = "https://usememos.com";
    changelog = "https://github.com/usememos/memos/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      indexyz
      kuflierl
    ];

    mainProgram = "memos";
  };
})
