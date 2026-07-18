{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  copyDesktopItems,
  makeDesktopItem,
  ncurses,
  graphics ? true,
  terminal ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "brogue-ce";
  version = "1.15.1";

  src = fetchFromGitHub {
    owner = "tmewett";
    repo = "BrogueCE";
    rev = "v${finalAttrs.version}";
    hash = "sha256-a+gzaBhQq9xgEVM20X+pbu7xzUcKzylxYk9qu9GQOAw=";
  };

  postPatch = ''
    substituteInPlace linux/brogue-multiuser.sh \
      --replace broguedir= "broguedir=$out/opt/brogue-ce #"
  '';

  nativeBuildInputs = [
    copyDesktopItems
  ];

  buildInputs =
    (lib.optionals graphics [
      SDL2
      SDL2_image
    ])
    ++ (lib.optionals terminal [
      ncurses
    ]);

  makeFlags = [
    "DATADIR=$(out)/opt/brogue-ce"
    "TERMINAL=${if terminal then "YES" else "NO"}"
    "GRAPHICS=${if graphics then "YES" else "NO"}"
    "MAC_APP=${if stdenv.hostPlatform.isDarwin then "YES" else "NO"}"
  ];

  postBuild = lib.optionalString (stdenv.hostPlatform.isDarwin && graphics) ''
    make Brogue.app $makeFlags
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/opt
    cp -r bin $out/opt/brogue-ce
    install -Dm755 linux/brogue-multiuser.sh $out/bin/brogue-ce
    install -Dm 644 bin/assets/icon.png $out/share/icons/hicolor/256x256/apps/brogue-ce.png
    runHook postInstall
  '';

  postInstall = lib.optionalString (stdenv.hostPlatform.isDarwin && graphics) ''
    mkdir -p $out/Applications
    mv Brogue.app "$out/Applications/Brogue CE.app"
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "AdventureGame"
      ];

      comment = "Brave the Dungeons of Doom!";
      desktopName = "Brogue CE";
      exec = "brogue-ce";
      genericName = "Roguelike";
      icon = "brogue-ce";
      name = "brogue-ce";
    })
  ];

  meta = {
    description = "Community-lead fork of the minimalist roguelike game Brogue";
    homepage = "https://github.com/tmewett/BrogueCE";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      fgaz
    ];

    platforms = lib.platforms.all;
    mainProgram = "brogue-ce";
  };
})
