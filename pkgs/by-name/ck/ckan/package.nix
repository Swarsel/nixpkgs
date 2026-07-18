{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  curl,
  gtk2,
  imagemagick,
  makeDesktopItem,
  makeWrapper,
  mono,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "ckan";
  version = "1.36.4";

  src = fetchurl {
    url = "https://github.com/KSP-CKAN/CKAN/releases/download/v${version}/ckan.exe";
    hash = "sha256-d0gILN/PLbtfUCJhsYr8hQAxk4lMYEJ9BLCseo3+994=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
    makeWrapper
  ];

  buildInputs = [ mono ];

  installPhase = ''
    runHook preInstall
    for size in 16 24 48 64 96 128 256; do
      mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
      magick -background none ${icon} -resize "$size"x"$size" $out/share/icons/hicolor/"$size"x"$size"/apps/${pname}.png
    done
    install -m 644 -D $src $out/bin/ckan.exe
    makeWrapper ${mono}/bin/mono $out/bin/ckan \
      --add-flags $out/bin/ckan.exe \
      --set LD_LIBRARY_PATH $libraries
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "PackageManager"
      ];

      comment = "The Comprehensive Kerbal Archive Network Client";
      desktopName = "CKAN";
      exec = "ckan";
      extraConfig.X-GNOME-SingleWindow = "true";
      icon = "ckan";

      keywords = [
        "Kerbal Space Program"
        "KSP"
        "Mod"
      ];

      name = "ckan";
    })
  ];

  dontBuild = true;
  dontUnpack = true;

  icon = fetchurl {
    hash = "sha256-BJvuOz8NWmzpYzzhveeq6rcuqXIxQqxtBIcRvobx+TY=";
    url = "https://raw.githubusercontent.com/KSP-CKAN/CKAN/450e2f960e1a3fee4ab7cf74ad56bddc5296fc7e/assets/ckan-256.png";
  };

  libraries = lib.makeLibraryPath [
    gtk2
    curl
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Mod manager for Kerbal Space Program";
    homepage = "https://github.com/KSP-CKAN/CKAN";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      Baughn
      nullcube
    ];

    platforms = lib.platforms.all;
    mainProgram = "ckan";
  };
}
