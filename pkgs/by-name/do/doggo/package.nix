{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "doggo";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "mr-karan";
    repo = "doggo";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xzwgNuvEedqC0DS0cMi472x2Tx0mWdk+22E9Bz1G9Tk=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-AJQQVhrYhgazCwI2Dnvorj4Y78iwVO7mhx1gzZUA9BI=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd doggo \
      --bash <($out/bin/doggo completions bash) \
      --fish <($out/bin/doggo completions fish) \
      --zsh <($out/bin/doggo completions zsh)
  '';

  ldflags = [
    "-s"
    "-X main.buildVersion=v${finalAttrs.version}"
  ];

  subPackages = [ "cmd/doggo" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line DNS Client for Humans. Written in Golang";

    longDescription = ''
      doggo is a modern command-line DNS client (like dig) written in Golang.
      It outputs information in a neat concise manner and supports protocols like DoH, DoT, DoQ, and DNSCrypt as well
    '';

    homepage = "https://github.com/mr-karan/doggo";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      georgesalkhouri
      ma27
    ];

    mainProgram = "doggo";
  };
})
