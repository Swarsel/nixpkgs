{
  lib,
  stdenv,
  budgie-desktop,
  glib,
  gobject-introspection,
  lndir,
  wrapGAppsHook3,
  plugins ? [ ],
}:

stdenv.mkDerivation {
  inherit (budgie-desktop) version;
  pname = "${budgie-desktop.pname}-with-plugins";
  src = null;

  nativeBuildInputs = [
    glib
    gobject-introspection.setupHook
    wrapGAppsHook3
  ];

  buildInputs = lib.forEach plugins (plugin: plugin.buildInputs) ++ plugins;

  installPhase = ''
    mkdir -p $out
    for i in "''${paths[@]}"; do
      ${lndir}/bin/lndir -silent $i $out
    done
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --set BUDGIE_PLUGIN_LIBDIR "$out/lib/budgie-desktop/plugins"
      --set BUDGIE_PLUGIN_DATADIR "$out/share/budgie-desktop/plugins"
      --set RAVEN_PLUGIN_LIBDIR "$out/lib/budgie-desktop/raven-plugins"
      --set RAVEN_PLUGIN_DATADIR "$out/share/budgie-desktop/raven-plugins"
    )
  '';

  __structuredAttrs = true;
  allowSubstitutes = false;
  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;
  paths = [ budgie-desktop ] ++ plugins;
  preferLocalBuild = true;

  meta = {
    inherit (budgie-desktop.meta)
      description
      homepage
      changelog
      license
      teams
      platforms
      ;
  };
}
