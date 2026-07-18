{
  lib,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kestrel";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "finfet";
    repo = "kestrel";
    rev = "v${finalAttrs.version}";
    hash = "sha256-sDTjlR2XRZn5zq7l1Vul658OVT2431oaJjibfGg0/lA=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  cargoHash = "sha256-8+V9RaEFrU+ZLIqYX/9ipjJ+nM6L6B614Qghm75douw=";

  postInstall = ''
    installManPage docs/man/kestrel.1
    installShellCompletion --bash --name kestrel completion/kestrel.bash-completion
  '';

  meta = {
    description = "File encryption done right";

    longDescription = "
      Kestrel is a data-at-rest file encryption program
      that lets you encrypt files to anyone with a public key.
    ";

    homepage = "https://getkestrel.com";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ zendo ];
    mainProgram = "kestrel";
  };
})
