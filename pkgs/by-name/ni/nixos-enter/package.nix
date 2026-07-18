{
  lib,
  installShellFiles,
  replaceVarsWith,
  runtimeShell,
  util-linuxMinimal,
}:
replaceVarsWith {
  src = ./nixos-enter.sh;
  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installManPage ${./nixos-enter.8}
  '';

  dir = "bin";
  isExecutable = true;
  name = "nixos-enter";

  replacements = {
    inherit runtimeShell;

    path = lib.makeBinPath [
      util-linuxMinimal
    ];
  };

  meta = {
    description = "Run a command in a NixOS chroot environment";
    homepage = "https://github.com/NixOS/nixpkgs/tree/master/pkgs/by-name/ni/nixos-install";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "nixos-enter";
  };
}
