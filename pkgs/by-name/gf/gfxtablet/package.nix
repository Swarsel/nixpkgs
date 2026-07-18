{
  lib,
  stdenv,
  fetchFromGitHub,
  linuxHeaders,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gfxtablet-uinput-driver";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "rfc2822";
    repo = "GfxTablet";
    rev = "android-app-${finalAttrs.version}";
    sha256 = "1i2m98yypfa9phshlmvjlgw7axfisxmldzrvnbzm5spvv5s4kvvb";
  };

  buildInputs = [
    linuxHeaders
  ];

  preBuild = "cd driver-uinput";

  installPhase = ''
    mkdir -p "$out/bin"
    cp networktablet "$out/bin"
    mkdir -p "$out/share/doc/gfxtablet/"
    cp ../*.md "$out/share/doc/gfxtablet/"
  '';

  meta = {
    description = "Uinput driver for Android GfxTablet tablet-as-input-device app";
    homepage = "https://github.com/rfc2822/GfxTablet";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.linux;
    mainProgram = "networktablet";
  };
})
