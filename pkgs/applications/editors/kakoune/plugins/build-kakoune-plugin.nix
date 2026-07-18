{
  lib,
  stdenv,
  rtpPath ? "share/kak/autoload/plugins",
}:
rec {
  buildKakounePlugin =
    attrs@{
      src,
      buildPhase ? "",
      configurePhase ? "",
      name ? "${attrs.pname}-${attrs.version}",
      namePrefix ? "kakplugin-",
      path ? lib.getName name,
      postInstall ? "",
      preInstall ? "",
      unpackPhase ? "",
      ...
    }:
    stdenv.mkDerivation (
      (removeAttrs attrs [
        "namePrefix"
        "path"
      ])
      // {
        installPhase = ''
          runHook preInstall

          target=$out/${rtpPath}/${path}
          mkdir -p $out/${rtpPath}
          cp -r . $target

          runHook postInstall
        '';

        name = namePrefix + name;
      }
    );

  buildKakounePluginFrom2Nix =
    attrs:
    buildKakounePlugin (
      {
        dontBuild = true;
        dontConfigure = true;
      }
      // attrs
    );
}
