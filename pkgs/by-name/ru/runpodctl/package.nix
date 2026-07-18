{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "runpodctl";
  version = "2.6.1";

  src = fetchFromGitHub {
    owner = "runpod";
    repo = "runpodctl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-hx0plQ5og4C6UY7r8RjYKo8LVk+WnWhtRErr0riNKbQ=";
  };

  vendorHash = "sha256-38d+nWZDjWgcK091G3JCGtBqyE7iJ60edAhbx8GzxPM=";

  postInstall = ''
    rm $out/bin/docs # remove the docs binary
  '';

  meta = {
    description = "CLI tool to automate / manage GPU pods for runpod.io";
    homepage = "https://github.com/runpod/runpodctl";
    changelog = "https://github.com/runpod/runpodctl/raw/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.georgewhewell ];
    mainProgram = "runpodctl";
  };
})
