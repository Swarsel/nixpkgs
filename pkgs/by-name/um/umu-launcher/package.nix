{
  lib,
  steam,
  umu-launcher-unwrapped,
  extraEnv ? { }, # Environment variables to include in shell profile
  extraLibraries ? pkgs: [ ],
  extraPkgs ? pkgs: [ ],
  extraProfile ? "", # string to append to shell profile
}:
steam.buildRuntimeEnv {
  inherit (umu-launcher-unwrapped) version meta;

  inherit
    extraLibraries
    extraProfile
    extraEnv
    ;

  pname = "umu-launcher";
  # Legendary spawns UMU, doesn't wait for it to exit,
  # and immediately exits itself. This makes it so we can't
  # die with parent, because parent is already dead.
  dieWithParent = false;
  executableName = umu-launcher-unwrapped.meta.mainProgram;

  extraInstallCommands = ''
    ln -s ${umu-launcher-unwrapped}/lib $out/lib
    ln -s ${umu-launcher-unwrapped}/share $out/share
  '';

  extraPkgs = pkgs: [ umu-launcher-unwrapped ] ++ extraPkgs pkgs;
  runScript = lib.getExe umu-launcher-unwrapped;
}
