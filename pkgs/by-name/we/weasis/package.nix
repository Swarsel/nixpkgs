{
  lib,
  stdenv,
  copyDesktopItems,
  fetchzip,
  jdk25,
  libGL,
  libx11,
  libxrender,
  libxxf86vm,
  makeBinaryWrapper,
  makeDesktopItem,
  unzip,
}:

let
  selectSystem =
    attrs:
    attrs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  platform = selectSystem {
    "aarch64-darwin" = "macosx-aarch64";
    "aarch64-linux" = "linux-aarch64";
    "x86_64-linux" = "linux-x86-64";
  };

  runtimeDeps = [
    libGL
    libx11
    libxrender
    libxxf86vm
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "weasis";
  version = "4.6.6";

  # Their build instructions indicate to use the packaging script
  src = fetchzip {
    url = "https://github.com/nroduit/Weasis/releases/download/v${finalAttrs.version}/weasis-native.zip";
    hash = "sha256-aOjYD+74yYp0+lIZpekToc6IvygJVAPyJmUsESl3gkI=";
    stripRoot = false;
  };

  postPatch = ''
    patchShebangs ./build/script/package-weasis.sh
  '';

  nativeBuildInputs = [
    copyDesktopItems
    makeBinaryWrapper
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin unzip;

  buildPhase = ''
    runHook preBuild

    ./build/script/package-weasis.sh --no-installer --jdk ${jdk25}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    mkdir -p $out/{bin,opt/Weasis,share/{applications,icons/hicolor/64x64/apps}}

    mv weasis-${platform}-jdk${lib.versions.major jdk25.version}-${finalAttrs.version}/Weasis/* $out/opt/Weasis
    mv $out/opt/Weasis/lib/*.png $out/share/icons/hicolor/64x64/apps

    for bin in $out/opt/Weasis/bin/*; do
      makeWrapper $bin $out/bin/$(basename $bin) \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeDeps}
    done
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    mv weasis-${platform}-jdk${lib.versions.major jdk25.version}-${finalAttrs.version}/Weasis.app $out/Applications/
  ''
  + ''
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      comment = "Convert standard images into DICOM";
      desktopName = "DICOMizer";
      exec = "Dicomizer";
      icon = "Dicomizer";
      name = "DICOMizer";
    })
    (makeDesktopItem {
      comment = finalAttrs.meta.description;
      desktopName = "Weasis";
      exec = "Weasis";
      icon = "Weasis";
      name = "Weasis";
    })
  ];

  meta = {
    description = "Multipurpose standalone and web-based DICOM viewer with a highly modular architecture";
    homepage = "https://weasis.org";
    # Using changelog from releases as it is more accurate
    changelog = "https://github.com/nroduit/Weasis/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      asl20
      epl20
    ];

    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "Weasis";
  };
})
