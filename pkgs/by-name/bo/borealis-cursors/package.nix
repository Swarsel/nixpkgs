{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "borealis-cursors";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "alvatip";
    repo = "Borealis-cursors";
    rev = finalAttrs.version;
    hash = "sha256-1qgyU0Npbx/AgqGbmF/BWtlVC0KsKtgC48SL/HtkDrk=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons
    cp -a Borealis-cursors $out/share/icons
    runHook postInstall
  '';

  dontBuild = true;

  meta = {
    description = "Cursor theme using a custom color palette inspired by boreal colors";
    homepage = "https://www.gnome-look.org/s/Gnome/p/1717914";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ argrat ];
    platforms = lib.platforms.linux;
  };
})
