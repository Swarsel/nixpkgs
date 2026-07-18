{
  lib,
  fetchFromGitHub,
  buildGoModule,
  docker-credential-helpers,
  gitMinimal,
  makeWrapper,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "dockerfile-pin";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "azu";
    repo = "dockerfile-pin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vBBcLQ4ZgiLbUMuDvn8Um24yB9EknuUeU+sxMdg+qoc=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-CgMFIYoM+nWiZ5NXtTlXHhrjzVYxoVg0YVpQq3LLrjI=";
  nativeCheckInputs = [ gitMinimal ];
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postFixup = ''
    wrapProgram $out/bin/dockerfile-pin \
      --prefix PATH : ${lib.makeBinPath [ docker-credential-helpers ]}
  '';

  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/azu/dockerfile-pin/cmd.version=${finalAttrs.version}"
  ];

  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Add sha256 digests to Docker images in Dockerfiles, Compose, and GitHub Actions";
    homepage = "https://github.com/azu/dockerfile-pin";
    changelog = "https://github.com/azu/dockerfile-pin/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ airrnot ];
    mainProgram = "dockerfile-pin";
  };
})
