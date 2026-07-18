{
  krita-plugin-gmic,
  krita-unwrapped,
  symlinkJoin,
  wrapGAppsHook3,
  binaryPlugins ? [
    # Default plugins provided by upstream appimage
    krita-plugin-gmic
  ],
}:
symlinkJoin {
  inherit (krita-unwrapped)
    version
    buildInputs
    meta
    ;

  pname = "krita";

  nativeBuildInputs = krita-unwrapped.nativeBuildInputs ++ [
    wrapGAppsHook3
  ];

  postBuild = ''
    gappsWrapperArgsHook
    wrapQtApp "$out/bin/krita" \
      "''${gappsWrapperArgs[@]}" \
      --prefix PYTHONPATH : "$PYTHONPATH" \
      --set KRITA_PLUGIN_PATH "$out/lib/kritaplugins"
  '';

  paths = [ krita-unwrapped ] ++ binaryPlugins;

  passthru = {
    inherit binaryPlugins;
    unwrapped = krita-unwrapped;
  };
}
