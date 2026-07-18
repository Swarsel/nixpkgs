{
  lib,
  makeWrapper,
  obs-studio,
  symlinkJoin,
}:

{
  plugins ? [ ],
}:

symlinkJoin {
  inherit (obs-studio) meta;
  nativeBuildInputs = [ makeWrapper ];

  postBuild =
    let
      # Some plugins needs extra environment, see obs-gstreamer for an example.
      pluginArguments = lib.lists.concatMap (plugin: plugin.obsWrapperArguments or [ ]) plugins;

      pluginsJoined = symlinkJoin {
        name = "obs-studio-plugins";
        paths = plugins;
      };

      wrapCommandLine = [
        "wrapProgram"
        "$out/bin/obs"
        ''--set OBS_PLUGINS_PATH "${pluginsJoined}/lib/obs-plugins"''
        ''--set OBS_PLUGINS_DATA_PATH "${pluginsJoined}/share/obs/obs-plugins"''
      ]
      ++ lib.lists.unique pluginArguments;
    in
    ''
      ${lib.concatStringsSep " " wrapCommandLine}

      # Remove unused obs-plugins dir to not cause confusion
      rm -r $out/share/obs/obs-plugins
      # Leave some breadcrumbs
      echo 'Plugins are at ${pluginsJoined}/share/obs/obs-plugins' > $out/share/obs/obs-plugins-README
    '';

  name = "wrapped-${obs-studio.name}";
  paths = [ obs-studio ] ++ plugins;

  passthru = obs-studio.passthru // {
    passthru.unwrapped = obs-studio;
  };
}
