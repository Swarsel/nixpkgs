{
  lib,
  buildNimPackage,
  fetchFromCodeberg,
}:

buildNimPackage (finalAttrs: {
  pname = "snekim";
  version = "1.2.0";

  src = fetchFromCodeberg {
    owner = "annaaurora";
    repo = "snekim";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Qgvq4CkGvNppYFpITCCifOHtVQYRQJPEK3rTJXQkTvI=";
  };

  postInstall = ''
    install -D snekim.desktop -t $out/share/applications
    install -D icons/hicolor/48x48/snekim.svg -t $out/share/icons/hicolor/48x48/apps
  '';

  lockFile = ./lock.json;
  nimFlags = [ "-d:nimraylib_now_shared" ];

  meta = {
    description = "Simple implementation of the classic snake game";
    homepage = "https://codeberg.org/annaaurora/snekim";
    license = lib.licenses.lgpl3Only;
    maintainers = [ lib.maintainers.annaaurora ];
    mainProgram = "snekim";
  };
})
