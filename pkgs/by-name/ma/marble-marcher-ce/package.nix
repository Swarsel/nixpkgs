{
  lib,
  stdenv,
  fetchFromGitHub,
  # buildInputs
  anttweakbar,
  # nativeBuildInputs
  cmake,
  copyDesktopItems,
  eigen,
  glew,
  glm,
  makeDesktopItem,
  makeWrapper,
  sfml_2,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "marble-marcher-ce";
  version = "1.4.6";

  src = fetchFromGitHub {
    owner = "WAUthethird";
    repo = "Marble-Marcher-Community-Edition";
    tag = finalAttrs.version;
    hash = "sha256-xzmbC0CnhHaUJ9UHvLDLJsABD/TaJAl+SLVRQRbD9P8=";
  };

  postPatch =
    # the path /home/MMCE is always added to DESTDIR
    # we change this to a more sensible path
    # see https://github.com/WAUthethird/Marble-Marcher-Community-Edition/issues/23
    ''
      substituteInPlace CMakeLists.txt \
        --replace-fail '/home/MMCE' '/share/MMCE'
    '';

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    anttweakbar
    eigen
    glew
    glm
    sfml_2
  ];

  postInstall = ''
    mkdir $out/bin
    mkdir -p $out/share/icons/
    # The executable has to be run from the same directory the assets are in
    makeWrapper $out/share/MMCE/MarbleMarcher $out/bin/marble-marcher-ce --chdir $out/share/MMCE
    ln -s $out/share/MMCE/images/MarbleMarcher.png $out/share/icons/marble-marcher-ce.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = finalAttrs.meta.description;
      desktopName = "marble-marcher-ce";
      exec = "marble-marcher-ce";
      icon = "marble-marcher-ce";
      name = "marble-marcher-ce";
    })
  ];

  installFlags = [ "DESTDIR=$(out)" ];

  meta = {
    description = "Community-developed version of the original Marble Marcher - a fractal physics game";
    homepage = "https://michaelmoroz.itch.io/mmce";

    license = with lib.licenses; [
      gpl2Plus # Code
      cc-by-30 # Assets
      ofl # Fonts
    ];

    maintainers = with lib.maintainers; [ rampoina ];
    platforms = lib.platforms.linux;
    mainProgram = "marble-marcher-ce";
  };
})
