{
  lib,
  fetchurl,
  makeWrapper,
  p7zip,
  pvz-portable-unwrapped,
  stdenvNoCC,
  symlinkJoin,
  doFixBugs ? false,
  # set it to a dir or a zip containing main.pak and properties; can be a path or a derivation
  # example: ./Plants_vs._Zombies_1.2.0.1073_EN.zip
  # https://github.com/wszqkzqk/PvZ-Portable/blob/main/archlinux/README.md#prepare-game-assets
  gameAssets ? fetchurl {
    hash = "sha256-S0u00Z+2OeVpiYPjnXrQYcdme87BkFZWBTLHrQ1n0OQ=";
    url = "https://web.archive.org/web/20220717170711/http://static-www.ec.popcap.com/binaries/popcap_downloads/PlantsVsZombiesSetup.exe";
    meta.license = lib.licenses.unfree;
  },
  limboPage ? true,
  pvzDebug ? false,
}:

let
  unwrapped = pvz-portable-unwrapped.override { inherit pvzDebug limboPage doFixBugs; };

  assets = stdenvNoCC.mkDerivation {
    src = gameAssets;
    nativeBuildInputs = [ p7zip ];

    installPhase = ''
      runHook preInstall

      dir="$(find -type f -name main.pak -printf %h -execdir test -d properties \; | head -n 1)"
      if [[ -z "$dir" ]]; then
        echo "main.pak and properties not found in $src"
        exit 1
      fi

      mkdir -p $out/share/pvz-portable
      cp -ar "$dir"/{main.pak,properties} $out/share/pvz-portable

      runHook postInstall
    '';

    name = "pvz-portable-assets";

    unpackCmd = ''
      [[ -d $curSrc ]] && cp -ar $curSrc source || 7z x $curSrc -osource -ba -bd
    '';
  };

in
symlinkJoin (finalAttrs: {
  inherit (finalAttrs.passthru.unwrapped) version meta;
  pname = "pvz-portable";
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/pvz-portable --add-flags -resdir=$out/share/pvz-portable
  '';

  paths = [
    finalAttrs.passthru.unwrapped
    finalAttrs.passthru.assets
  ];

  passthru = { inherit unwrapped assets; };
})
