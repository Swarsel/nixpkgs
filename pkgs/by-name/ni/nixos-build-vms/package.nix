{
  installShellFiles,
  replaceVarsWith,
  runtimeShell,
}:
replaceVarsWith {
  src = ./nixos-build-vms.sh;
  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installManPage ${./nixos-build-vms.8}
  '';

  dir = "bin";
  isExecutable = true;
  name = "nixos-build-vms";

  replacements = {
    inherit runtimeShell;
    buildVms = "${./build-vms.nix}";
  };

  meta.mainProgram = "nixos-build-vms";
}
