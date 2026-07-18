{
  clapper-enhancers,
  clapper-unwrapped,
  gobject-introspection,
  lndir,
  stdenvNoCC,
  wrapGAppsHook4,
}:

stdenvNoCC.mkDerivation {
  inherit (clapper-unwrapped) version meta;
  pname = "clapper";
  src = clapper-unwrapped;

  nativeBuildInputs = [
    wrapGAppsHook4
    gobject-introspection
    lndir
  ];

  buildInputs = [ clapper-unwrapped ] ++ clapper-unwrapped.buildInputs;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    lndir $src $out
    dbusfile=share/dbus-1/services/com.github.rafostar.Clapper.service
    rm $out/$dbusfile
    cp $src/$dbusfile $out/$dbusfile
    substituteInPlace $out/$dbusfile \
      --replace-fail $src/bin/clapper $out/bin/clapper

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --set-default CLAPPER_ENHANCERS_PATH "${clapper-enhancers}/${clapper-enhancers.passthru.pluginPath}"
    )
  '';

  dontBuild = true;
  dontConfigure = true;
}
