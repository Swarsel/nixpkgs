{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "picocrypt-cli";
  version = "1.49";

  src = fetchFromGitHub {
    owner = "Picocrypt";
    repo = "CLI";
    tag = finalAttrs.version;
    hash = "sha256-r+ySKCVRPYHY+8s6uCj2ZQyMArccPjpa4d4lvYjrmmU=";
  };

  vendorHash = "sha256-HscCZ6z/tGLNlm6AjYmAG156LS3VGeye12eyeqYVGtw=";
  env.CGO_ENABLED = 1;

  ldflags = [
    "-s"
    "-w"
  ];

  sourceRoot = "${finalAttrs.src.name}/picocrypt";

  meta = {
    description = "Command-line interface for Picocrypt";
    homepage = "https://github.com/Picocrypt/CLI";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ryand56 ];
    mainProgram = "picocrypt";
  };
})
