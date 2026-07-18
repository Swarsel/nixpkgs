{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "pack";
  version = "0.40.3";

  src = fetchFromGitHub {
    owner = "buildpacks";
    repo = "pack";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KKgF05oJDgMQExJtsAc6weor4OxUZl4xNIFY0VoQfs4=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-sRITmNcCwJw4aXLv/wKYOTZai95YY/DY87F4P2+7b5A=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd pack \
      --zsh $(PACK_HOME=$PWD $out/bin/pack completion --shell zsh) \
      --bash $(PACK_HOME=$PWD $out/bin/pack completion --shell bash) \
      --fish $(PACK_HOME=$PWD $out/bin/pack completion --shell fish)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/buildpacks/pack.Version=${finalAttrs.version}"
  ];

  subPackages = [ "." ];

  meta = {
    description = "CLI for building apps using Cloud Native Buildpacks";
    homepage = "https://buildpacks.io/";
    changelog = "https://github.com/buildpacks/pack/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "pack";
  };
})
