{
  lib,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "mro-unicode";
  version = "unstable-2013-05-25";

  src = fetchurl {
    url = "https://github.com/phjamr/MroUnicode/raw/f297de070f7eba721a47c850e08efc119d3bfbe8/MroUnicode-Regular.ttf";
    hash = "sha256-hcQmTuRWxaU5KEMXg/O0b1olE8YxXWz0PAlqAJknR/0=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/share/fonts/truetype/MroUnicode-Regular.ttf

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "Unicode-compliant Mro font";
    homepage = "https://github.com/phjamr/MroUnicode";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ mathnerd314 ];
    platforms = lib.platforms.all;
  };
}
