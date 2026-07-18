{
  lib,
  stdenv,
  fetchFromGitHub,
  libsForQt5,
  libvorbis,
  nix-update-script,
  pkg-config,
  rtmidi,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ptcollab";
  version = "0.6.4.11";

  src = fetchFromGitHub {
    owner = "yuxshao";
    repo = "ptcollab";
    rev = "v${finalAttrs.version}";
    hash = "sha256-tjsSaKUvswp+/gyJeIJ/cnBrerNMAguzv2mFFLDPaoI=";
  };

  nativeBuildInputs = [
    pkg-config
  ]
  ++ (with libsForQt5; [
    qmake
    qttools
    wrapQtAppsHook
  ]);

  buildInputs = [
    libvorbis
    rtmidi
  ]
  ++ (with libsForQt5; [
    qtbase
    qtmultimedia
  ]);

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Move appbundles to Applications before wrapping happens
    mkdir $out/Applications
    mv $out/{bin,Applications}/ptcollab.app
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Link to now-wrapped binary inside appbundle
    ln -s $out/{Applications/ptcollab.app/Contents/MacOS,bin}/ptcollab
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Experimental pxtone editor where you can collaborate with friends";
    homepage = "https://yuxshao.github.io/ptcollab/";
    changelog = "https://github.com/yuxshao/ptcollab/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ OPNA2608 ];
    platforms = lib.platforms.all;
    mainProgram = "ptcollab";
  };
})
