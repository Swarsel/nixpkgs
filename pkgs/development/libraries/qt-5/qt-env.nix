{ buildEnv, qtbase }:
name: paths:

buildEnv {
  inherit name;

  postBuild = ''
    rm "$out/bin/qmake"
    cp "${qtbase.dev}/bin/qmake" "$out/bin"
    cat >"$out/bin/qt.conf" <<EOF
    [Paths]
    Prefix = $out
    Plugins = ${qtbase.qtPluginPrefix}
    Qml2Imports = ${qtbase.qtQmlPrefix}
    Documentation = ${qtbase.qtDocPrefix}
    EOF
  '';

  extraOutputsToInstall = [
    "out"
    "dev"
  ];

  paths = [ qtbase ] ++ paths;

  pathsToLink = [
    "/bin"
    "/mkspecs"
    "/include"
    "/lib"
    "/share"
  ];
}
