{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  SDL2,
  cmake,
  copyDesktopItems,
  faudio,
  imagemagick,
  makeDesktopItem,
  makeWrapper,
  physfs,
  tinyxml-2,
  makeAndPlay ? false,
}:

stdenv.mkDerivation rec {
  pname = "vvvvvv";
  version = "2.4.3";

  src = fetchFromGitHub {
    owner = "TerryCavanagh";
    repo = "VVVVVV";
    rev = version;
    hash = "sha256-IEspPNsKGWgukqmnb6nDORRetQp9jvUzJ/mSOTLGdmQ=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    makeWrapper
    copyDesktopItems
    imagemagick
  ];

  buildInputs = [
    faudio
    physfs
    SDL2
    tinyxml-2
  ];

  cmakeFlags = [
    "-DBUNDLE_DEPENDENCIES=OFF"
  ]
  ++ lib.optional makeAndPlay "-DMAKEANDPLAY=ON";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons/hicolor/32x32/apps
    install -Dm755 VVVVVV $out/bin/vvvvvv
    # There's only one icon in the ico anyway
    magick "$src/desktop_version/icon.ico[-1]" "$out/share/icons/hicolor/32x32/apps/VVVVVV.png"
    cp -r "$src/desktop_version/fonts/" "$out/share/"
    cp -r "$src/desktop_version/lang/" "$out/share/"

    wrapProgram $out/bin/vvvvvv \
      --add-flags "-assets ${dataZip}" \
      --add-flags "-langdir $out/share/lang" \
      --add-flags "-fontsdir $out/share/fonts"

    runHook postInstall
  '';

  cmakeDir = "../desktop_version";

  dataZip = fetchurl {
    hash = "sha256-x2eAlZT2Ry2p9WE252ZX44ZA1YQWSkYRIlCsYpPswOo=";
    name = "data.zip";
    url = "https://thelettervsixtim.es/makeandplay/data.zip";
    meta.license = lib.licenses.unfree;
  };

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = meta.description;
      desktopName = "VVVVVV";
      exec = "vvvvvv";
      icon = "VVVVVV";
      name = "VVVVVV";
      terminal = false;
      type = "Application";
    })
  ];

  meta = {
    description =
      "A retro-styled platform game"
      + lib.optionalString makeAndPlay " (redistributable, without original levels)";

    longDescription = ''
      VVVVVV is a platform game all about exploring one simple mechanical
      idea - what if you reversed gravity instead of jumping?
    ''
    + lib.optionalString makeAndPlay ''
      (Redistributable version, doesn't include the original levels.)
    '';

    homepage = "https://thelettervsixtim.es";
    changelog = "https://github.com/TerryCavanagh/VVVVVV/releases/tag/${src.rev}";
    license = lib.licenses.unfree;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
