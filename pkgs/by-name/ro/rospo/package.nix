{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildPackages,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "rospo";
  version = "0.15.3";

  src = fetchFromGitHub {
    owner = "ferama";
    repo = "rospo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nqlUsg/V9v/2hcsaoyuXXhsa7+M/QK9+oQxX9hp/A2k=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-tIIEONPNnS7oF+MSKozaRW6MZq0gcH3KDG+aukCUG+c=";
  doCheck = false;

  postInstall =
    let
      rospoBin =
        if stdenv.buildPlatform.canExecute stdenv.hostPlatform then
          placeholder "out"
        else
          buildPackages.rospo;
    in
    ''
      installShellCompletion --cmd rospo \
        --bash <(${rospoBin}/bin/rospo completion bash) \
        --fish <(${rospoBin}/bin/rospo completion fish) \
        --zsh <(${rospoBin}/bin/rospo completion zsh)
    '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/ferama/rospo/cmd.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Simple, reliable, persistent ssh tunnels with embedded ssh server";
    homepage = "https://github.com/ferama/rospo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sikmir ];
    mainProgram = "rospo";
  };
})
