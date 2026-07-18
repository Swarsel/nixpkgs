{
  lib,
  fetchFromGitHub,
  alsa-lib,
  buildDotnetModule,
  copyDesktopItems,
  dotnetCorePackages,
  fetchpatch,
  glfw,
  imagemagick,
  libbass,
  libbass_fx,
  makeDesktopItem,
  nix-update-script,
}:

let
  version = "0.7.28.2";
in
buildDotnetModule {
  inherit version;
  pname = "interlude";

  src = fetchFromGitHub {
    owner = "YAVSRG";
    repo = "YAVSRG";
    tag = "interlude-v${version}";
    hash = "sha256-39GhnQcp5yaHC2fGnXkjny7e7QphBYih+PUuj3GR6qA=";
    fetchSubmodules = true;
  };

  patches = [
    # Fallback game dir when the executable dir is not writable
    # https://github.com/YAVSRG/YAVSRG/pull/65
    (fetchpatch {
      hash = "sha256-eyvq2GIAZuHYhtAdYLe0csJxHZCrw9soXmRl2eJA7Bg=";
      name = "log-path.patch";
      url = "https://github.com/YAVSRG/YAVSRG/commit/6e56a3d78caf4cbc8e17190fea3adb4d061d5284.patch";
    })

    # Looking for bass and bass_fx in LD_LIBRARY_PATH
    # https://github.com/YAVSRG/YAVSRG/pull/66
    (fetchpatch {
      hash = "sha256-WUbI38EMGvlVl8h7YLJLPsGczhX5PWMLTmy94IRxaBM=";
      name = "library-path.patch";
      url = "https://github.com/YAVSRG/YAVSRG/commit/911a8b7f3931823d9fee99f0cb679a3c03298286.patch";
    })
  ];

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
  ];

  postInstall = ''
    # The icon is pixel art, so it may be converted to a scalable SVG.
    mkdir -p $out/share/icons/hicolor/scalable/apps
    magick site/files/favicon.png -alpha on -sample 20x20! txt:- | \
      sed '1d; s/[():,]/ /g' | \
      awk '{if ($6>0) printf "<rect x=\"%d\" y=\"%d\" width=\"4\" height=\"4\" fill=\"rgb(%d,%d,%d)\" />\n",$1*4,$2*4,$3,$4,$5}' | \
      (echo '<svg width="80" height="80" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges">'; cat; echo '</svg>') \
      > $out/share/icons/hicolor/scalable/apps/interlude.svg
  '';

  preFixup = ''
    # Remove bundled GLFW and use the one from nixpkgs instead.
    rm $out/lib/interlude/libglfw* || true
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "Music"
      ];

      comment = "A keyboard rhythm game, built for fun";
      desktopName = "Interlude";
      exec = "Interlude %U";
      genericName = "Interlude";
      icon = "interlude";
      name = "Interlude";
    })
  ];

  dotnet-runtime = dotnetCorePackages.runtime_9_0;
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  executables = [ "Interlude" ];
  nugetDeps = ./deps.json;
  projectFile = "interlude/src/Interlude.fsproj";

  runtimeDeps = [
    # replaced bundled ones in engine/lib/linux-x64
    libbass
    libbass_fx
    # replace the bundled one by OpenTK
    glfw
    # not sure why this is needed but no audio devices can be found by libbass without this
    alsa-lib
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Keyboard rhythm game built for fun, part of the YAVSRG project";
    homepage = "https://www.yavsrg.net";
    changelog = "https://www.yavsrg.net/interlude/changelog.html";

    license = with lib.licenses; [
      gpl3Only
      mit
    ];

    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.linux;
    mainProgram = "Interlude";
  };
}
