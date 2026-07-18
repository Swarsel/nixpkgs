{
  lib,
  stdenv,
  fetchFromGitHub,
  giflib,
  imlib2Full,
  libexif,
  libxft,
  conf ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sxiv";
  version = "26";

  src = fetchFromGitHub {
    owner = "muennich";
    repo = "sxiv";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jrCEx1o7Go0jgwQ3YJ0L97Q5BCHvVTTqOWId3xzlSnU=";
  };

  strictDeps = true;

  buildInputs = [
    libxft
    imlib2Full
    giflib
    libexif
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  preBuild = lib.optionalString (conf != null) "cp ${finalAttrs.configFile} config.def.h";

  postInstall = ''
    install -Dt $out/share/applications sxiv.desktop
  '';

  __structuredAttrs = true;
  configFile = lib.optionalString (conf != null) (builtins.toFile "config.def.h" conf);

  meta = {
    description = "Simple X Image Viewer";
    homepage = "https://github.com/muennich/sxiv";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ h7x4 ];
    platforms = lib.platforms.linux;
    mainProgram = "sxiv";
  };
})
