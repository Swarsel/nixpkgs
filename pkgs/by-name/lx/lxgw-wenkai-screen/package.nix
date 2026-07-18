{
  lib,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lxgw-wenkai-screen";
  version = "1.522";

  src = fetchurl {
    url = "https://github.com/lxgw/LxgwWenKai-Screen/releases/download/v${finalAttrs.version}/LXGWWenKaiScreen.ttf";
    hash = "sha256-zRpvo5xOpC/Y9OKJlFeJsOUQz3AWQ1ZA+Ik82tmyIPM=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 "$src" "$out/share/fonts/truetype/LXGWWenKaiScreen.ttf"
    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "LXGW WenKai font optimized for screen reading";
    homepage = "https://github.com/lxgw/LxgwWenKai-Screen";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ lebensterben ];
    platforms = lib.platforms.all;
  };
})
