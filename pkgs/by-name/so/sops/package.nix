{
  lib,
  fetchFromGitHub,
  age,
  buildGoModule,
  installShellFiles,
  makeWrapper,
  nix-update-script,
  runCommand,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "sops";
  version = "3.13.2";

  src = fetchFromGitHub {
    owner = "getsops";
    repo = finalAttrs.pname;
    tag = "v${finalAttrs.version}";
    hash = "sha256-en4MsPwqLRi8jlwuzWHgJ+ns42cBXuCzGbnZyGK9Vhk=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  vendorHash = "sha256-qBtVnRJK/E545yTUwYXauVFBcpV8mUSxmush5vQMMrs=";

  postInstall = ''
    installShellCompletion --cmd sops --bash ${./bash_autocomplete}
    installShellCompletion --cmd sops --zsh ${./zsh_autocomplete}
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/getsops/sops/v3/version.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/sops" ];
  passthru.updateScript = nix-update-script { };

  # wrap sops with age plugins
  passthru.withAgePlugins =
    filter:
    runCommand "sops-${finalAttrs.version}-with-age-plugins"
      {
        nativeBuildInputs = [ makeWrapper ];
      }
      ''
        makeWrapper ${lib.getBin finalAttrs.finalPackage}/bin/sops $out/bin/sops \
          --prefix PATH : "${lib.makeBinPath (filter age.passthru.plugins)}"
      '';

  meta = {
    description = "Simple and flexible tool for managing secrets";
    homepage = "https://getsops.io/";
    changelog = "https://github.com/getsops/sops/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      Scrumplex
      mic92
    ];

    mainProgram = "sops";
  };
})
