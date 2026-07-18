{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  minify,
  nix-update-script,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "minify";
  version = "2.24.13";

  src = fetchFromGitHub {
    owner = "tdewolff";
    repo = "minify";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wmK+4ryM4pONuDuq5V+Y5/qd0II0QiTJ0pq/3PYQSWQ=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-1a3DrkBj2R22933blXpI2UzMZSc/SN3zn89bBihxWFk=";

  postInstall = ''
    installShellCompletion --cmd minify --bash cmd/minify/bash_completion
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/minify" ];

  passthru = {
    tests.version = testers.testVersion {
      inherit (finalAttrs) version;
      command = "minify --version";
      package = minify;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Go minifiers for web formats";
    homepage = "https://go.tacodewolff.nl/minify";
    changelog = "https://github.com/tdewolff/minify/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "minify";
    downloadPage = "https://github.com/tdewolff/minify";
  };
})
