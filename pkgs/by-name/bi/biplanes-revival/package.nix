{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  cmake,
  makeWrapper,
  ninja,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "biplanes-revival";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "regular-dev";
    repo = "biplanes-revival";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rdPcI4j84fVKNwv2OQ9gwC0X2CHlObYfSYkCMlcm4sM=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    makeWrapper
    ninja
  ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
  ];

  env.NIX_CFLAGS_COMPILE = "-I ../deps/TimeUtils/include";

  postInstall = ''
    id="org.regular_dev.biplanes_revival"
    install -Dm644 $src/flatpak-data/$id.desktop -t $out/share/applications
    install -Dm644 $src/flatpak-data/$id.metainfo.xml -t $out/share/metainfo
    install -Dm644 $src/flatpak-data/$id.svg -t $out/share/icons/hicolor/scalable/apps

    # Move assets directory into the preferred location.
    mkdir -p $out/share/biplanes-revival
    mv $out/bin/assets $out/share/biplanes-revival

    # Remove TimeUtils headers.
    rm -rf $out/include
  '';

  postFixup = ''
    # Set assets root, the default is the current working directory.
    # The game automatically appends "/assets" to the variable.
    wrapProgram $out/bin/BiplanesRevival \
      --set BIPLANES_ASSETS_ROOT "$out/share/biplanes-revival";
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Old cellphone arcade recreated for PC";
    homepage = "https://regular-dev.org/biplanes-revival";
    changelog = "https://github.com/regular-dev/biplanes-revival/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "BiplanesRevival";
  };
})
