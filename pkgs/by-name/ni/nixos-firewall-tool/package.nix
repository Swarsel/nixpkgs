{
  lib,
  bash,
  buildPackages,
  installShellFiles,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "nixos-firewall-tool";
  version = lib.trivial.release;
  src = builtins.filterSource (name: _: !(lib.hasSuffix ".nix" name)) ./.;

  postPatch = ''
    patchShebangs --host nixos-firewall-tool
  '';

  strictDeps = true;
  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ bash ];
  doCheck = buildPackages.shellcheck-minimal.compiler.bootstrapAvailable;
  nativeCheckInputs = [ buildPackages.shellcheck-minimal ];

  checkPhase = ''
    shellcheck nixos-firewall-tool
  '';

  installPhase = ''
    installBin nixos-firewall-tool
    installManPage nixos-firewall-tool.1
    installShellCompletion nixos-firewall-tool.{bash,fish}
  '';

  meta = {
    description = "Tool to temporarily manipulate the NixOS firewall";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      clerie
      rvfg
      garyguo
    ];

    platforms = lib.platforms.linux;
    mainProgram = "nixos-firewall-tool";
  };
}
