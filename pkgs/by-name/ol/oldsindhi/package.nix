{
  lib,
  fetchurl,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "oldsindhi";
  version = "1.0";

  src = fetchurl {
    url = "https://github.com/MihailJP/oldsindhi/releases/download/v${finalAttrs.version}/OldSindhi-${finalAttrs.version}.tar.xz";
    hash = "sha256-jOcl+mo6CJ9Lnn3nAUiXXHCJssovVgLoPrbGxj4uzQs=";
  };

  nativeBuildInputs = [ installFonts ];

  postInstall = ''
    install -m444 -Dt $out/share/doc/${finalAttrs.pname}-${finalAttrs.version} README *.txt
  '';

  meta = {
    description = "Free Sindhi Khudabadi font";
    homepage = "https://github.com/MihailJP/oldsindhi";

    license = with lib.licenses; [
      mit
      ofl
    ];

    maintainers = with lib.maintainers; [ mathnerd314 ];
    platforms = lib.platforms.all;
  };
})
