{
  lib,
  stdenv,
  glib,
  lndir,
  plugs,
  switchboard,
  switchboardPlugs,
  wrapGAppsHook4,
  testName ? null,
  # Only useful to disable for development testing.
  useDefaultPlugs ? true,
}:

let
  selectedPlugs =
    if plugs == null then
      switchboardPlugs
    else
      plugs ++ (lib.optionals useDefaultPlugs switchboardPlugs);

  testingName = lib.optionalString (testName != null) "${testName}-";
in
stdenv.mkDerivation {
  inherit (switchboard) version;
  inherit (switchboard) meta;
  pname = "${testingName}${switchboard.pname}-with-plugs";
  src = null;
  strictDeps = true;

  nativeBuildInputs = [
    glib
    lndir
    wrapGAppsHook4
  ];

  buildInputs = lib.concatMap (x: x.buildInputs) selectedPlugs ++ selectedPlugs;

  installPhase = ''
    mkdir -p $out
    for i in $(cat $pathsPath); do
      lndir -silent $i $out
    done

    dbus_file="share/dbus-1/services/io.elementary.settings.service"
    rm -f "$out/$dbus_file"
    substitute "${switchboard}/$dbus_file" "$out/$dbus_file" \
      --replace-fail "${switchboard}" "$out"
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --set SWITCHBOARD_PLUGS_PATH "$out/lib/switchboard-3"
    )
  '';

  allowSubstitutes = false;
  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;
  passAsFile = [ "paths" ];

  paths = [
    switchboard
  ]
  ++ selectedPlugs;

  preferLocalBuild = true;
}
