{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  fetchzip,
  setuptools,
}:
let
  rev = "26780de81b8c14d48fe8d757c642086f2af2a66b";

  src = fetchFromGitHub {
    inherit rev;
    owner = "philippj";
    repo = "SteamworksPy";
    hash = "sha256-nSGkEP6tny/Kv2+YjldFCYrLe1jnKOTa+w1/KCpSLsU=";

  };
  steamworksSrc = fetchzip {
    hash = "sha256-yDA92nGj3AKTNI4vnoLaa+7mDqupQv0E4YKRRUWqyZw=";
    url = "https://web.archive.org/web/20250527013243/https://partner.steamgames.com/downloads/steamworks_sdk_162.zip";
  };

  library = stdenv.mkDerivation {
    pname = "steamworkspy-c";
    version = rev;

    installPhase = ''
      mkdir -p $out
      cp SteamworksPy.so $out/
    '';

    sourceRoot = "source/library";

    unpackPhase = ''
      runHook preUnpack

      cp -r ${src} source
      chmod -R 755 source
      cp -r ${steamworksSrc}/public/steam source/library/sdk/
      cp ${steamworksSrc}/redistributable_bin/linux64/libsteam_api.so source/library/

      runHook postUnpack
    '';
  };
in

buildPythonPackage {
  inherit src;
  pname = "steamworkspy";
  version = rev;

  postInstall = ''
    cp ${library}/SteamworksPy.so $out/lib
  '';

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Python API system for Valve's Steamworks";
    homepage = "https://github.com/philippj/SteamworksPy";

    license = with lib.licenses; [
      mit
      # For steamworks headers and libsteamapi.so
      (
        unfreeRedistributable
        // {
          url = "https://partner.steamgames.com/documentation/sdk_access_agreement";
        }
      )
    ];

    maintainers = with lib.maintainers; [ weirdrock ];
    # steamworksSrc is x86_64-linux only
    platforms = [ "x86_64-linux" ];
  };
}
