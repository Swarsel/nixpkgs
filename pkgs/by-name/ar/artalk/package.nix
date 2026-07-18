{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fetchPnpmDeps,
  installShellFiles,
  nixosTests,
  nodejs,
  pnpmConfigHook,
  pnpm_9,
  versionCheckHook,
}:

let
  pname = "artalk";
  version = "2.9.1";

  src = fetchFromGitHub {
    owner = "ArtalkJS";
    repo = "artalk";
    tag = "v${version}";
    hash = "sha256-gzagE3muNpX/dwF45p11JAN9ElsGXNFQ3fCvF1QhvdU=";
  };

  frontend = stdenv.mkDerivation (finalAttrs: {
    inherit src version;
    pname = "${pname}-frontend";

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm_9
    ];

    buildPhase = ''
      runHook preBuild

      pnpm build:all
      pnpm build:auth

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{dist/{i18n,plugins},sidebar}

      # dist
      cp ./ui/artalk/dist/{Artalk,ArtalkLite}.{css,js} $out/dist
      cp ./ui/artalk/dist/i18n/*.js $out/dist/i18n
      cp ./ui/plugin-*/dist/*.js $out/dist/plugins

      # sidebar
      cp -r ./ui/artalk-sidebar/dist/* $out/sidebar

      runHook postInstall
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 3;
      hash = "sha256-HypDGYb0MRCIDBHY8pVgwFoZQWC8us44cunORZRk3RM=";
      pnpm = pnpm_9;
    };
  });
in
buildGoModule {
  inherit src pname version;
  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-oAqYQzOUjly97H5L5PQ9I2SO2KqiUVxdJA+eoPrHD6Q=";

  preBuild = ''
    cp -r ${frontend}/* ./public
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd artalk \
      --bash <($out/bin/artalk completion bash) \
      --fish <($out/bin/artalk completion fish) \
      --zsh <($out/bin/artalk completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
  ];

  versionCheckProgramArg = "-v";

  passthru.tests = {
    inherit (nixosTests) artalk;
  };

  meta = {
    description = "Self-hosted comment system";
    homepage = "https://github.com/ArtalkJS/Artalk";
    changelog = "https://github.com/ArtalkJS/Artalk/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "artalk";
  };
}
