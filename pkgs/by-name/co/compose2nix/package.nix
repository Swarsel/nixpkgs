{
  lib,
  fetchFromGitHub,
  buildGoModule,
  compose2nix,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "compose2nix";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "aksiksi";
    repo = "compose2nix";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0QCYgzxg0upnrVGDXbX9GgSHyzeMP3yqNor2t8DVwiU=";
  };

  vendorHash = "sha256-8boWHIGvenGugKq+8ysPCsUib7QQ0ov+jbKFDKpls3g=";

  passthru.tests = {
    version = testers.testVersion {
      version = "compose2nix v${finalAttrs.version}";
      package = compose2nix;
    };
  };

  meta = {
    description = "Generate a NixOS config from a Docker Compose project";
    homepage = "https://github.com/aksiksi/compose2nix";
    changelog = "https://github.com/aksiksi/compose2nix/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aksiksi ];
    mainProgram = "compose2nix";
  };
})
