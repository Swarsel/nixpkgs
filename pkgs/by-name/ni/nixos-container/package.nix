{
  installShellFiles,
  nixosTests,
  path,
  perl,
  replaceVarsWith,
  shadow,
  util-linux,
  configurationDirectory ? "/etc/nixos-containers",
  stateDirectory ? "/var/lib/nixos-containers",
}:
replaceVarsWith {
  src = ./nixos-container.pl;
  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --cmd nixos-container \
      --bash ${./nixos-container-completion.sh} \
      --fish ${./nixos-container-completion.fish}
  '';

  dir = "bin";
  isExecutable = true;
  name = "nixos-container";

  replacements = {
    inherit configurationDirectory stateDirectory util-linux;
    lib = "${path + "/lib"}";

    perl = perl.withPackages (p: [
      p.FileSlurp
      p.IPCRun
    ]);

    su = "${shadow.su}/bin/su";
  };

  passthru = {
    tests = {
      inherit (nixosTests)
        containers-imperative
        containers-ip
        containers-tmpfs
        containers-ephemeral
        containers-unified-hierarchy
        ;
    };
  };

  meta.mainProgram = "nixos-container";
}
