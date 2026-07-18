{
  lib,
  stdenv,
  glib,
  lndir,
  marco,
  mate-applets,
  mate-indicator-applet,
  mate-media,
  mate-netbook,
  mate-notification-daemon,
  mate-panel,
  mate-power-manager,
  mate-sensors-applet,
  mate-utils,
  wrapGAppsHook3,
  applets ? [ ],
  useDefaultApplets ? true,
}:

let
  selectedApplets =
    applets
    ++ (lib.optionals useDefaultApplets [
      mate-applets
      mate-indicator-applet
      mate-netbook
      mate-notification-daemon
      mate-media
      mate-power-manager
      mate-sensors-applet
      mate-utils
    ]);
in
stdenv.mkDerivation {
  inherit (mate-panel) version outputs;
  inherit (mate-panel) meta;
  pname = "${mate-panel.pname}-with-applets";
  src = null;

  nativeBuildInputs = [
    glib
    wrapGAppsHook3
  ];

  buildInputs =
    lib.concatMap (x: x.buildInputs) selectedApplets
    ++ selectedApplets
    ++ [ mate-panel ]
    ++ mate-panel.buildInputs
    ++ mate-panel.propagatedBuildInputs;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    for i in "''${paths[@]}"; do
      ${lndir}/bin/lndir -silent $i $out
    done

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --set MATE_PANEL_APPLETS_DIR "$out/share/mate-panel/applets"
      --set MATE_PANEL_EXTRA_MODULES "$out/lib/mate-panel/applets"
      # Workspace switcher settings
      --prefix XDG_DATA_DIRS : "${glib.getSchemaDataDirPath marco}"
    )
  '';

  __structuredAttrs = true;
  allowSubstitutes = false;
  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;

  paths = [
    mate-panel.out
    mate-panel.man
  ]
  ++ selectedApplets;

  preferLocalBuild = true;
}
