{
  lib,
  stdenv,
  glib,
  lndir,
  switchboard-with-plugs,
  wingpanel,
  wingpanelIndicators,
  wrapGAppsHook3,
  indicators ? null,
  # Only useful to disable for development testing.
  useDefaultIndicators ? true,
}:

let
  selectedIndicators =
    if indicators == null then
      wingpanelIndicators
    else
      indicators ++ (lib.optionals useDefaultIndicators wingpanelIndicators);
in
stdenv.mkDerivation {
  inherit (wingpanel) version;
  inherit (wingpanel) meta;
  pname = "${wingpanel.pname}-with-indicators";
  src = null;

  nativeBuildInputs = [
    glib
    wrapGAppsHook3
  ];

  buildInputs = lib.concatMap (x: x.buildInputs) selectedIndicators ++ selectedIndicators;

  installPhase = ''
    mkdir -p $out
    for i in $(cat $pathsPath); do
      ${lndir}/bin/lndir -silent $i $out
    done
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --set WINGPANEL_INDICATORS_PATH "$out/lib/wingpanel"
      --set SWITCHBOARD_PLUGS_PATH "${switchboard-with-plugs}/lib/switchboard-3"
    )
  '';

  allowSubstitutes = false;
  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;
  passAsFile = [ "paths" ];

  paths = [
    wingpanel
  ]
  ++ selectedIndicators;

  preferLocalBuild = true;
}
