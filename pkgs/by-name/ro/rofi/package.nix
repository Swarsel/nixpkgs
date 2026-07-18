{
  lib,
  gdk-pixbuf,
  hicolor-icon-theme,
  makeWrapper,
  rofi-unwrapped,
  symlinkJoin,
  wrapGAppsHook3,
  plugins ? [ ],
  symlink-dmenu ? false,
  theme ? null,
}:

symlinkJoin {
  inherit (rofi-unwrapped) version;
  pname = "rofi";

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [ gdk-pixbuf ];

  postBuild = ''
    rm -rf $out/bin
    mkdir $out/bin
    ln -s ${rofi-unwrapped}/bin/* $out/bin
    rm $out/bin/rofi

    gappsWrapperArgsHook
    makeWrapper ${rofi-unwrapped}/bin/rofi $out/bin/rofi \
      ''${gappsWrapperArgs[@]} \
      --prefix XDG_DATA_DIRS : ${hicolor-icon-theme}/share \
      ${
        lib.optionalString (plugins != [ ])
          "--prefix XDG_DATA_DIRS : ${lib.concatStringsSep ":" (lib.forEach plugins (p: "${p.out}/share"))}"
      } \
      ${lib.optionalString (theme != null) ''--add-flags "-theme ${theme}"''} \
      ${lib.optionalString (plugins != [ ]) ''--add-flags "-plugin-path $out/lib/rofi"''}

    ${lib.optionalString symlink-dmenu "ln -s ${rofi-unwrapped}/bin/rofi $out/bin/dmenu"}

    rm $out/bin/rofi-theme-selector
    makeWrapper ${rofi-unwrapped}/bin/rofi-theme-selector $out/bin/rofi-theme-selector \
      --prefix XDG_DATA_DIRS : $out/share
  '';

  dontWrapGApps = true;

  paths = [
    rofi-unwrapped.out
  ]
  ++ (lib.forEach plugins (p: p.out));

  preferLocalBuild = true;
  passthru.unwrapped = rofi-unwrapped;

  meta = rofi-unwrapped.meta // {
    priority = (rofi-unwrapped.meta.priority or lib.meta.defaultPriority) - 1;
  };
}
