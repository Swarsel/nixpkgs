{
  lib,
  makeWrapper,
  symlinkJoin,
  wayfire,
  plugins ? [ ],
}:

symlinkJoin {
  inherit (wayfire) version;
  pname = "wayfire-wrapped";
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    for binary in $out/bin/*; do
      wrapProgram $binary \
        --prefix WAYFIRE_PLUGIN_PATH : $out/lib/wayfire \
        --prefix WAYFIRE_PLUGIN_XML_PATH : $out/share/wayfire/metadata
    done
  '';

  paths = [
    wayfire
  ]
  ++ plugins;

  preferLocalBuild = true;

  passthru = wayfire.passthru // {
    unwrapped = wayfire;
  };

  meta = wayfire.meta // {
    # To prevent builds on hydra
    hydraPlatforms = [ ];
    outputsToInstall = [ "out" ];
    # prefer wrapper over the package
    priority = (wayfire.meta.priority or lib.meta.defaultPriority) - 1;
  };
}
