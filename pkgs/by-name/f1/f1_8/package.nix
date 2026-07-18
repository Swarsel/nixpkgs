{
  lib,
  fetchzip,
  stdenvNoCC,
}:

let
  majorVersion = "1";
  minorVersion = "101";
in
stdenvNoCC.mkDerivation {
  pname = "f1_8";
  version = "${majorVersion}.${minorVersion}";

  src = fetchzip {
    url = "https://note.com/api/v2/attachments/download/d83b2c4ec63d7826acaa76725d261ff4";
    hash = "sha256-pe1G8WeFAo+KYjjsNwn0JmtXFn9QugE1SeGwaqnl1F0=";
    extension = "zip";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install -D -m444 -t $out/share/fonts/opentype $src/*.otf

    runHook postInstall
  '';

  meta = {
    description = "Weighted decorative font";
    homepage = "https://dotcolon.net/font/f1_8/";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ minijackson ];
    platforms = lib.platforms.all;
  };
}
