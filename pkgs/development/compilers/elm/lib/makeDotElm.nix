{
  lib,
  stdenv,
  fetchurl,
  registryDat,
}:

ver: deps:
let
  cmds = lib.mapAttrsToList (
    name: info:
    let
      pkg = stdenv.mkDerivation {
        src = fetchurl {
          inherit (info) sha256;
          url = "https://github.com/${name}/archive/${info.version}.tar.gz";
          meta.homepage = "https://github.com/${name}/";
        };

        installPhase = ''
          mkdir -p $out
          cp -r * $out
        '';

        dontBuild = true;
        dontConfigure = true;
        name = lib.replaceStrings [ "/" ] [ "-" ] name + "-${info.version}";
      };
    in
    ''
      mkdir -p .elm/${ver}/packages/${name}
      cp -R ${pkg} .elm/${ver}/packages/${name}/${info.version}
    ''
  ) deps;
in
(lib.concatStrings cmds)
+ ''
  mkdir -p .elm/${ver}/packages;
  cp ${registryDat} .elm/${ver}/packages/registry.dat;
  chmod -R +w .elm
''
