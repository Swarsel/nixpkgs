{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  juju,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "juju";
  version = "3.6.21";

  src = fetchFromGitHub {
    owner = "juju";
    repo = "juju";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Gvrzk3xaMtEpOxMBMH17Aam14eymISYmuokdEyGGgCY=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-Aod6k9etHDEW5WtetlA15MB0ZfaVFLbIK0Ud4gy/MuY=";
  # Disable tests because it attempts to use a mongodb instance
  doCheck = false;

  postInstall = ''
    for file in etc/bash_completion.d/*; do
      installShellCompletion --bash "$file"
    done
  '';

  subPackages = [
    "cmd/juju"
  ];

  passthru.tests.version = testers.testVersion {
    command = "HOME=\"$(mktemp -d)\" juju --version";
    package = juju;
  };

  meta = {
    description = "Open source modelling tool for operating software in the cloud";
    homepage = "https://juju.is";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ citadelcore ];
    mainProgram = "juju";
  };
})
