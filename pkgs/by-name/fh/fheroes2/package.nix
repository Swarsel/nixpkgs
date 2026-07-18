{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  SDL2_ttf,
  gettext,
  gitUpdater,
  glibcLocalesUtf8,
  imagemagick,
  libiconv,
  libpng,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fheroes2";
  version = "1.1.16";

  src = fetchFromGitHub {
    owner = "ihhub";
    repo = "fheroes2";
    rev = finalAttrs.version;
    hash = "sha256-B4gs+uDS9dCkrS1OLn4dUfWTSKKsUrdQJxAAAJCH7Nw=";
  };

  nativeBuildInputs = [ imagemagick ];

  buildInputs = [
    gettext
    glibcLocalesUtf8
    libpng
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    zlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];

  makeFlags = [
    "FHEROES2_DATA=\"${placeholder "out"}/share/fheroes2\""
  ];

  postBuild = ''
    # Pick guaranteed to be present UTF-8 locale.
    # Otherwise `iconv` calls fail to produce valid translations.
    LANG=en_US.UTF_8 make -C files/lang
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 $PWD/src/dist/fheroes2/fheroes2 $out/bin/fheroes2

    install -Dm644 -t $out/share/fheroes2/files/lang $PWD/files/lang/*.mo
    install -Dm644 -t $out/share/fheroes2/files/data $PWD/files/data/resurrection.h2d

    install -Dm644 -t $out/share/applications $PWD/script/packaging/common/fheroes2.desktop

    for size in 16 24 32 48 64 128; do
      mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
      convert -resize "$size"x"$size" $PWD/src/resources/fheroes2.png $out/share/icons/hicolor/"$size"x"$size"/apps/fheroes2.png
    done;

    runHook postInstall
  '';

  enableParallelBuilding = true;

  passthru = {
    updateScript = gitUpdater {
      url = "https://github.com/ihhub/fheroes2.git";
    };
  };

  meta = {
    description = "Free implementation of Heroes of Might and Magic II game engine";

    longDescription = ''
      In order to play this game, an original game data is required.
      Please refer to README of the project for instructions.
      On linux, the data can be placed in ~/.local/share/fheroes2 folder.
    '';

    homepage = "https://github.com/ihhub/fheroes2";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "fheroes2";
  };
})
