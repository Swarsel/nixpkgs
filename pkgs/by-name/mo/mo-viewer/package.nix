{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchPnpmDeps,
  installShellFiles,
  jq,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  stdenvNoCC,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "mo-viewer";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "k1LoW";
    repo = "mo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DbcktOAdcg/v5q3gYgxMvSHVtwXODz9xHoPqiiWBaP4=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-rmtJswO3DWWxpb2uk91aIatc7ugNmsqzwlEeKdX7ITE=";
  env.CGO_ENABLED = 0;

  preBuild = ''
    cp -r ${finalAttrs.frontend} internal/static/dist
  '';

  doCheck = !stdenvNoCC.hostPlatform.isDarwin;

  postInstall = lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
    installShellCompletion --cmd 'mo' \
      --bash <("$out/bin/mo" completion bash) \
      --zsh <("$out/bin/mo" completion zsh) \
      --fish <("$out/bin/mo" completion fish)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  frontend = stdenvNoCC.mkDerivation (finalFrontendAttrs: {
    inherit (finalAttrs) version src;
    pname = "${finalAttrs.pname}-frontend";

    postPatch = ''
      jq 'del(.pnpm.executionEnv)' internal/frontend/package.json > internal/frontend/package.json.tmp
      mv internal/frontend/package.json.tmp internal/frontend/package.json
    '';

    nativeBuildInputs = [
      nodejs
      pnpm_10
      pnpmConfigHook
      jq
    ];

    buildPhase = ''
      runHook preBuild
      pnpm -C internal/frontend run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r internal/static/dist $out
      runHook postInstall
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit (finalFrontendAttrs) pname version src;
      fetcherVersion = 4;
      hash = "sha256-thlwYvB7y6RFwLknbQt5evF4xQVzllrQqVYDdKSbEUM=";
      pnpm = pnpm_10;
      sourceRoot = "${finalFrontendAttrs.src.name}/internal/frontend";
    };

    pnpmRoot = "internal/frontend";
  });

  ldflags = [
    "-s"
    "-w"
    "-X github.com/k1LoW/mo/version.Revision=v${finalAttrs.version}"
  ];

  versionCheckProgramArg = "--version";

  meta = {
    description = "Markdown viewer that opens .md files in a browser";
    homepage = "https://github.com/k1LoW/mo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ryota2357 ];
    mainProgram = "mo";
  };
})
