{
  lib,
  fetchzip,
  stdenvNoCC,
}:

let
  colors = [
    {
      hash = "sha256-pb2U9j1m8uJaILxUxKqp8q9FGuwzZsQvhPP3bfGZL5I=";
      name = "Black";
    }
    {
      hash = "sha256-PmJeGShQLIC7ceRwQvSbphqz19fKptksZeHKi9QSL5Y=";
      name = "Blue";
    }
    {
      hash = "sha256-/X81jLoWaw4UMoDRf1f6oaKKRWexQc4PAACy3doV4Kc=";
      name = "Red";
    }
    {
      hash = "sha256-eT/Zy6O6TBD6G8q/dg+9rNYDHutLLxEY1lvLDP90b+g=";
      name = "White";
    }
  ];
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "google-cursor";
  version = "2.0.0";

  postInstall = ''
    mkdir -p $out/share/icons
    cp -r GoogleDot-* $out/share/icons
  '';

  sourceRoot = ".";

  srcs = map (
    color:
    (fetchzip {
      hash = color.hash;
      name = "GoogleDot-${color.name}";
      url = "https://github.com/ful1e5/Google_Cursor/releases/download/v${finalAttrs.version}/GoogleDot-${color.name}.tar.gz";
    })
  ) colors;

  meta = {
    description = "Opensource cursor theme inspired by Google";
    homepage = "https://github.com/ful1e5/Google_Cursor";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ quadradical ];
    platforms = lib.platforms.all;
  };
})
