{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
  pandoc,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "eget";
  version = "1.3.4";

  src = fetchFromGitHub {
    owner = "zyedidia";
    repo = "eget";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-jhVUYyp6t5LleVotQQme07IJVdVnIOVFFtKEmzt8e2k=";
  };

  nativeBuildInputs = [
    pandoc
    installShellFiles
  ];

  vendorHash = "sha256-A3lZtV0pXh4KxINl413xGbw2Pz7OzvIQiFSRubH428c=";

  postInstall = ''
    rm $out/bin/{test,tools}
    pandoc man/eget.md -s -t man -o eget.1
    installManPage eget.1
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${finalAttrs.version}"
  ];

  passthru = {
    tests.version = testers.testVersion {
      version = "v${finalAttrs.version}";
      command = "eget -v";
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Easily install prebuilt binaries from GitHub";
    homepage = "https://github.com/zyedidia/eget";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zendo ];
  };
})
