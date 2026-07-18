{
  lib,
  stdenv,
  fetchurl,
  SDL2,
  autoPatchelfHook,
  copyDesktopItems,
  darwin,
  imagemagick,
  libGL,
  libarchive,
  libgcc,
  libiconv,
  libmpg123,
  libxmp,
  makeDesktopItem,
  makeWrapper,
  openal,
  runCommand,
  undmg,
  wxwidgets_3_2,
}:

let
  version = "469e";
  srcs = {
    aarch64-darwin = fetchurl {
      hash = "sha256-trOh9GLktwLfDuz5DWY+8fhHzDaq3KHsbdNSeNCR+g0=";
      url = "https://github.com/OldUnreal/UnrealTournamentPatches/releases/download/v${version}/OldUnreal-UTPatch${builtins.elemAt (lib.strings.splitString "-" version) 0}-macOS.dmg";
    };

    aarch64-linux = fetchurl {
      hash = "sha256-TDl4BzsSsEnD/9600nXPx6IxNlDz61uU2wb7/ud8Pjs=";
      url = "https://github.com/OldUnreal/UnrealTournamentPatches/releases/download/v${version}/OldUnreal-UTPatch${builtins.elemAt (lib.strings.splitString "-" version) 0}-Linux-arm64.tar.bz2";
    };

    i686-linux = fetchurl {
      hash = "sha256-y9bYAW77MOOYJ1elgsaIUygDch7B7HOPwor5s+FdPBQ=";
      url = "https://github.com/OldUnreal/UnrealTournamentPatches/releases/download/v${version}/OldUnreal-UTPatch${builtins.elemAt (lib.strings.splitString "-" version) 0}-Linux-x86.tar.bz2";
    };

    x86_64-linux = fetchurl {
      hash = "sha256-CMgGqjchsZcARaoVitkAUTKdmC6KmjZhFTkA6cy/aww=";
      url = "https://github.com/OldUnreal/UnrealTournamentPatches/releases/download/v${version}/OldUnreal-UTPatch${builtins.elemAt (lib.strings.splitString "-" version) 0}-Linux-amd64.tar.bz2";
    };
  };
  # This upload of the game is officially sanctioned by OldUnreal (who has received permission from Epic Games to link to archive.org) and the UT99.org community
  # This is a copy of the original Unreal Tournament: Game of the Year Edition (also known as UT or UT99). The first ISO contains the base game.
  iso1 = fetchurl {
    hash = "sha256-4YSYTKiPABxd3VIDXXbNZOJm4mx0l1Fhte1yNmx0cE8=";
    url = "https://archive.org/download/ut-goty/UT_GOTY_CD1.iso";
  };
  # The second ISO contains bonus maps and game modes
  iso2 = fetchurl {
    hash = "sha256-2V2O4c+VVi7gI/1UA17IgT1CdfY9GEdCMiCYbtyNANg=";
    url = "https://archive.org/download/ut-goty/UT_GOTY_CD2.iso";
  };
  baseGame =
    runCommand "ut1999-iso1"
      {
        src = iso1;
        nativeBuildInputs = [ libarchive ];
      }
      ''
        bsdtar -xvf "$src"
        mkdir $out
        cp -r Music Sounds Textures Maps $out
      '';
  bonusPacks =
    runCommand "ut1999-iso2"
      {
        src = iso2;
        nativeBuildInputs = [ libarchive ];
      }
      ''
        bsdtar -xvf "$src"
        mkdir $out
        cp -r System Sounds Textures maps $out
      '';
  systemDir =
    {
      aarch64-darwin = "System";
      aarch64-linux = "SystemARM64";
      i686-linux = "System";
      x86_64-linux = "System64";
    }
    .${stdenv.hostPlatform.system} or (throw "unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "ut1999";

  src =
    srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      copyDesktopItems
      autoPatchelfHook
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      makeWrapper
      undmg
      darwin.autoSignDarwinBinariesHook
    ];

  buildInputs = [
    libgcc
    wxwidgets_3_2
    SDL2
    libGL
    openal
    libmpg123
    libxmp
    stdenv.cc.cc
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  installPhase =
    let
      outPrefix =
        if stdenv.hostPlatform.isDarwin then
          "$out/Applications/UnrealTournament.app/Contents/MacOS"
        else
          "$out";
    in
    ''
      runHook preInstall
      mkdir -p $out/bin
    ''
    + lib.optionalString (stdenv.hostPlatform.isLinux) ''
      cp -r ./* $out
    ''
    + lib.optionalString (stdenv.hostPlatform.isDarwin) ''
      mkdir -p $out/Applications/
      cp -r "UnrealTournament.app" $out/Applications/
      makeWrapper $out/Applications/UnrealTournament.app/Contents/MacOS/UnrealTournament \
        $out/bin/${finalAttrs.meta.mainProgram}
      # If the darwin build sandbox is enabled, system libiconv is not available
      # https://github.com/OldUnreal/UnrealTournamentPatches/issues/1902
      # Even though ut1999 is able to unpack the map files at runtime, upstream advised to still do it at install time
      # which is why the UCC binary is fixed to access a copy of iconv from the nix store
      install_name_tool -change /usr/lib/libiconv.2.dylib \
        ${libiconv}/lib/libiconv.2.dylib \
        $out/Applications/UnrealTournament.app/Contents/MacOS/UCC
      # Needs manual re-signing, as UCC is used during the build, and the auto signer is part of the fixup phase
      signDarwinBinariesInAllOutputs
    ''
    + ''
      chmod -R 755 $out
      cd ${outPrefix}
      # NOTE: OldUnreal patch doesn't include these folders on linux but could in the future
      # on darwin it does, but they are empty
      rm -rf ./{Music,Sounds}
      cp -r ${baseGame}/{Music,Sounds} .
      chmod u+w ./Sounds
      cp -n ${bonusPacks}/Sounds/* ./Sounds
      cp -n ${bonusPacks}/System/*.{u,int} ./System
    ''
    + lib.optionalString (stdenv.hostPlatform.isLinux) ''
      # maps need no post-processing on linux
      rm -rf ./Maps
      cp -r ${baseGame}/Maps .
      chmod u+w ./Maps
      cp -n ${bonusPacks}/maps/* ./Maps
    ''
    + lib.optionalString (stdenv.hostPlatform.isDarwin) ''
      # Maps need post-processing on darwin
      cp -n ${baseGame}/Maps/* ./Maps || true
      cp -n ${bonusPacks}/maps/* ./Maps || true
      # unpack compressed maps with ucc (needs absolute paths)
      for map in $PWD/Maps/*.uz; do ./UCC decompress $map; done
      mv ${systemDir}/*.unr ./Maps || true
      rm ./Maps/*.uz
    ''
    + ''
      cp -n ${baseGame}/Textures/* ./Textures || true
      cp -n ${bonusPacks}/Textures/* ./Textures || true
    ''
    + lib.optionalString (stdenv.hostPlatform.isLinux) ''
      cp -n ${baseGame}/System/*.{u,int} ./System || true
      ln -s "$out/${systemDir}/ut-bin" "$out/bin/ut1999"
      ln -s "$out/${systemDir}/ucc-bin" "$out/bin/ut1999-ucc"

      install -D "${./ut1999.svg}" "$out/share/icons/hicolor/scalable/apps/ut1999.svg"
      for size in 16 24 32 48 64 128 192 256; do
        square=$(printf "%sx%s" $size $size)
        ${imagemagick}/bin/magick -background none ${./ut1999.svg} -resize $square ut1999_$square.png
        install -D "ut1999_$square.png" "$out/share/icons/hicolor/$square/apps/ut1999.png"
      done

      # TODO consider to remove shared libraries that can be provided by nixpkgs for darwin too
      # Remove bundled libraries to use native versions instead
      rm $out/${systemDir}/libmpg123.so* \
        $out/${systemDir}/libopenal.so* \
        $out/${systemDir}/libSDL2* \
        $out/${systemDir}/libxmp.so*
        # NOTE: what about fmod?
        #$out/${systemDir}/libfmod.so*
    ''
    + ''
      runHook postInstall
    '';

  # Bring in game's .so files into lookup. Otherwise game fails to start
  # as: `Object not found: Class Render.Render`
  appendRunpaths = [
    "${placeholder "out"}/${systemDir}"
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "Unreal Tournament GOTY (1999) with the OldUnreal patch.";
      desktopName = "Unreal Tournament GOTY (1999)";
      exec = "ut1999";
      icon = "ut1999";
      name = "ut1999";
    })
  ];

  sourceRoot = ".";

  passthru = {
    # The ISOs can be appended to `system.extraDependencies` in order to prevent them from getting garbage collected and redownloaded during rebuilds.
    isos = [
      iso1
      iso2
    ];
  };

  meta = {
    description = "Unreal Tournament GOTY (1999) with the OldUnreal patch";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      eliandoran
      dwt
    ];

    platforms = lib.attrNames srcs;
    mainProgram = "ut1999";
  };
})
