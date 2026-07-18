{
  lib,
  stdenv,
  fetchurl,
  callPackage,
  config,
  unzip,
  licenseAccepted ? config.sc2-headless.accept_license or false,
}:

let
  maps = callPackage ./maps.nix { inherit licenseAccepted; };
in
stdenv.mkDerivation rec {
  pname = "sc2-headless";
  version = "4.7.1";

  src = fetchurl {
    url = "https://blzdistsc2-a.akamaihd.net/Linux/SC2.${version}.zip";
    sha256 = "0q1ry9bd3dm8y4hvh57yfq7s05hl2k2sxi2wsl6h0r3w690v1kdd";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out
    cp -r . "$out"
    rm -r $out/Libs

    cp -ur "${maps.minigames}"/* "${maps.melee}"/* "${maps.ladder2017season1}"/* "${maps.ladder2017season2}"/* "${maps.ladder2017season3}"/* \
      "${maps.ladder2017season4}"/* "${maps.ladder2018season1}"/* "${maps.ladder2018season2}"/* \
      "${maps.ladder2018season3}"/*  "${maps.ladder2018season4}"/* "${maps.ladder2019season1}"/* "$out"/Maps/
  '';

  preFixup = ''
    find $out -type f -print0 | while IFS=''' read -d ''' -r file; do
      isELF "$file" || continue
      patchelf \
        --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath ${
          lib.makeLibraryPath [
            stdenv.cc.cc
            stdenv.cc.libc
          ]
        } \
        "$file"
    done
  '';

  unpackCmd =
    if !licenseAccepted then
      throw ''
        You must accept the Blizzard® Starcraft® II AI and Machine Learning License at
        https://blzdistsc2-a.akamaihd.net/AI_AND_MACHINE_LEARNING_LICENSE.html
        by setting nixpkgs config option 'sc2-headless.accept_license = true;'
      ''
    else
      assert licenseAccepted;
      ''
        unzip -P 'iagreetotheeula' $curSrc
      '';

  meta = {
    description = "Starcraft II headless linux client for machine learning research";

    license = {
      free = false;
      fullName = "BLIZZARD® STARCRAFT® II AI AND MACHINE LEARNING LICENSE";
      url = "https://blzdistsc2-a.akamaihd.net/AI_AND_MACHINE_LEARNING_LICENSE.html";
    };

    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
