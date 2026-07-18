{ stdenv, unzip }:
let
  buildFreshRssExtension =
    args@{
      FreshRssExtUniqueId,
      pname,
      src,
      version,
      buildPhase ? ''
        runHook preBuild
        runHook postBuild
      '',
      configurePhase ? ''
        runHook preConfigure
        runHook postConfigure
      '',
      dontPatchELF ? true,
      dontStrip ? true,
      passthru ? { },
      sourceRoot ? "source",
      ...
    }:
    stdenv.mkDerivation (
      (removeAttrs args [ "FreshRssExtUniqueId" ])
      // {
        inherit
          version
          src
          configurePhase
          buildPhase
          dontPatchELF
          dontStrip
          sourceRoot
          ;

        pname = "freshrss-extension-${pname}";

        installPhase = ''
          runHook preInstall

          mkdir -p "$out/$installPrefix"
          find . -mindepth 1 -maxdepth 1 | xargs -d'\n' mv -t "$out/$installPrefix/"

          runHook postInstall
        '';

        installPrefix = "share/freshrss/extensions/xExtension-${FreshRssExtUniqueId}";

        passthru = passthru // {
          inherit FreshRssExtUniqueId;
        };
      }
    );
in
{
  inherit buildFreshRssExtension;
}
