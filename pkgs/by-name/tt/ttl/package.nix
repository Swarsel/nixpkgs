{
  lib,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ttl";
  version = "0.19.1";

  src = fetchFromGitHub {
    owner = "lance0";
    repo = "ttl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xY0z5GH6aLL38wOH6B2V9pAv9HnrJfpmQDjDKGSL4qo=";
  };

  nativeBuildInputs = [
    installShellFiles
    versionCheckHook
  ];

  cargoHash = "sha256-zYO3sY/MdDPfypDeseabTtwMeeUZQ8OiVfch+5fRetI=";

  postInstall = ''
    installShellCompletion --cmd ttl \
      --bash <($out/bin/ttl --completions bash) \
      --fish <($out/bin/ttl --completions fish) \
      --zsh <($out/bin/ttl --completions zsh)
  '';

  doInstallCheck = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Modern traceroute/mtr-style TUI";

    longDescription = ''
      ttl provides a live traceroute interface that can trace multiple targets,
      detect ECMP paths, run PMTUD, export JSON/CSV reports, and optionally
      enrich hop data with DNS, ASN, geolocation, and PeeringDB information.
    '';

    homepage = "https://github.com/lance0/ttl";
    changelog = "https://github.com/lance0/ttl/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ vincentbernat ];
    platforms = lib.platforms.all;
    mainProgram = "ttl";
  };
})
