{
  feedbackd,
  glycin-loaders,
  gtk4,
  highscore-blastem,
  highscore-bsnes,
  highscore-desmume,
  highscore-gearsystem,
  highscore-mednafen,
  highscore-mgba,
  highscore-mupen64plus,
  highscore-nestopia,
  highscore-prosystem,
  highscore-sameboy,
  highscore-stella,
  highscore-unwrapped,
  librsvg,
  symlinkJoin,
  wrapGAppsHook4,
  # Allow users to override
  cores ? builtins.filter (p: p.meta.available) [
    highscore-blastem
    highscore-bsnes
    highscore-desmume
    highscore-gearsystem
    highscore-mednafen
    highscore-mgba
    highscore-mupen64plus
    highscore-nestopia
    highscore-prosystem
    highscore-sameboy
    highscore-stella
  ],
}:

symlinkJoin {
  inherit (highscore-unwrapped) version meta;
  pname = "highscore";

  nativeBuildInputs = [
    wrapGAppsHook4
  ];

  buildInputs = [
    # For gsettings-schemas
    highscore-unwrapped
    gtk4
    feedbackd
    # For GDK_PIXBUF_MODULE_FILE
    librsvg
  ];

  # symlinkJoin doesn't run other build phases
  postBuild = ''
    rm $out/share/dbus-1/services/app.drey.Highscore{,.SearchProvider}.service
    cp {${highscore-unwrapped},$out}/share/dbus-1/services/app.drey.Highscore.service
    cp {${highscore-unwrapped},$out}/share/dbus-1/services/app.drey.Highscore.SearchProvider.service
    substituteInPlace $out/share/dbus-1/services/app.drey.Highscore{,.SearchProvider}.service \
      --replace-fail "${highscore-unwrapped}" "$out"

    gappsWrapperArgsHook

    makeWrapper ${highscore-unwrapped}/bin/highscore $out/bin/highscore \
      "''${gappsWrapperArgs[@]}" \
      --prefix XDG_DATA_DIRS : "${glycin-loaders}/share" \
      --set HIGHSCORE_CORES_DIR $out/lib/highscore/cores
  '';

  dontWrapGApps = true;
  paths = [ highscore-unwrapped ] ++ cores;
}
