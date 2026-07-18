{
  lib,
  stdenv,
  fetchFromGitLab,
  SDL2,
  SDL2_image,
  SDL2_ttf,
  dejavu_fonts,
  installShellFiles,
  makeDesktopItem,
  rustPlatform,
}:
let
  pname = "freenukum";
  description = "Clone of the original Duke Nukum 1 Jump'n Run game";

  desktopItem = makeDesktopItem {
    categories = [
      "Game"
      "ArcadeGame"
      "ActionGame"
    ];

    comment = description;
    desktopName = pname;
    exec = pname;
    genericName = pname;
    icon = pname;
    name = pname;
  };

in
rustPlatform.buildRustPackage rec {
  inherit pname;
  version = "0.4.0";

  src = fetchFromGitLab {
    owner = "silwol";
    repo = "freenukum";
    rev = "v${version}";
    hash = "sha256-Tk9n2gPwyPin6JZ4RSO8d/+xVpEz4rF8C2eGKwrAXU0=";
    domain = "salsa.debian.org";
  };

  postPatch = ''
    substituteInPlace src/graphics.rs \
      --replace /usr $out
  '';

  nativeBuildInputs = [
    installShellFiles
  ];

  buildInputs = [
    SDL2
    SDL2_ttf
    SDL2_image
  ];

  cargoHash = "sha256-lQZ9Z/1tbL7BeLmGxJXNUvrXsOGtgzGXNt6WYGezxi0=";

  postInstall = ''
    mkdir -p $out/share/fonts/truetype/dejavu
    ln -sf \
      ${dejavu_fonts}/share/fonts/truetype/DejaVuSans.ttf \
      $out/share/fonts/truetype/dejavu/DejaVuSans.ttf
    mkdir -p $out/share/doc/freenukum
    install -Dm644 README.md CHANGELOG.md $out/share/doc/freenukum/
    installManPage doc/freenukum.6
    install -Dm644 "${desktopItem}/share/applications/"* -t $out/share/applications/
  '';

  meta = {
    description = "Clone of the original Duke Nukum 1 Jump'n Run game";
    homepage = "https://salsa.debian.org/silwol/freenukum";
    changelog = "https://salsa.debian.org/silwol/freenukum/-/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ _0x4A6F ];
    broken = stdenv.hostPlatform.isDarwin;
  };
}
