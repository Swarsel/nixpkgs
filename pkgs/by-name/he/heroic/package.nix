{
  heroic-unwrapped,
  steam,
  extraEnv ? { },
  extraLibraries ? pkgs: [ ],
  extraPkgs ? pkgs: [ ],
}:

steam.buildRuntimeEnv {
  inherit (heroic-unwrapped) version meta;
  inherit extraLibraries extraEnv;
  pname = "heroic";

  extraInstallCommands = ''
    mkdir -p $out/share
    ln -s ${heroic-unwrapped}/share/applications $out/share
    ln -s ${heroic-unwrapped}/share/icons $out/share
  '';

  extraPkgs = pkgs: [ heroic-unwrapped ] ++ extraPkgs pkgs;
  privateTmp = false;
  runScript = "heroic";
}
