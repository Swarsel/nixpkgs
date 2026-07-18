{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "nvcat";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "brianhuster";
    repo = "nvcat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-F23trNMmoifPyOVp5hK+xUM3m96PIBniO9mmyfTMnFE=";
  };

  vendorHash = "sha256-IZ1+RAKKYG9TblT30FmqMGswnUrzLdrK+haNmqGdGSk=";

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "v(.+)"
    ];
  };

  meta = {
    description = "`cat` but with syntax highlighting powered by Neovim";

    longDescription = ''
      A command-line utility that displays files with Neovim's syntax highlighting in the terminal.
    '';

    homepage = "https://github.com/brianhuster/nvcat";
    changelog = "https://github.com/brianhuster/nvcat/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ olillin ];
    mainProgram = "nvcat";
  };
})
