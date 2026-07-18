{
  lib,
  installShellFiles,
  jq,
  nixos-enter,
  nixosTests,
  replaceVarsWith,
  runtimeShell,
  util-linuxMinimal,
}:
replaceVarsWith {
  src = ./nixos-install.sh;
  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installManPage ${./nixos-install.8}
  '';

  dir = "bin";
  isExecutable = true;
  name = "nixos-install";

  replacements = {
    inherit runtimeShell;

    path = lib.makeBinPath [
      jq
      nixos-enter
      util-linuxMinimal
    ];
  };

  passthru.tests.installer-simpleUefiSystemdBoot = nixosTests.installer.simpleUefiSystemdBoot;

  meta = {
    description = "Install bootloader and NixOS";
    homepage = "https://github.com/NixOS/nixpkgs/tree/master/pkgs/by-name/ni/nixos-install";
    license = lib.licenses.mit;
    mainProgram = "nixos-install";
  };
}
