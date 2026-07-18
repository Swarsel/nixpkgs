{
  stdenv,
  electron-unwrapped,
  glib,
  gsettings-desktop-schemas,
  gtk3,
  gtk4,
  makeWrapper,
  wrapGAppsHook3,
}:

stdenv.mkDerivation {
  inherit (electron-unwrapped) version;
  inherit (electron-unwrapped) meta;
  pname = "electron";
  strictDeps = true;

  nativeBuildInputs = [
    wrapGAppsHook3
    makeWrapper
  ];

  buildInputs = [
    # needed for GSETTINGS_SCHEMAS_PATH
    gsettings-desktop-schemas
    glib
    gtk3
    gtk4
  ];

  __structuredAttrs = true;

  buildCommand = ''
    gappsWrapperArgsHook
    mkdir -p $out/bin
    makeWrapper "${electron-unwrapped}/libexec/electron/electron" "$out/bin/electron" \
      "''${gappsWrapperArgs[@]}" \
      --set CHROME_DEVEL_SANDBOX $out/libexec/electron/chrome-sandbox

    ln -s ${electron-unwrapped}/libexec $out/libexec
  '';

  dontWrapGApps = true;

  passthru = {
    inherit (electron-unwrapped) headers dist;
    unwrapped = electron-unwrapped;
  };
}
