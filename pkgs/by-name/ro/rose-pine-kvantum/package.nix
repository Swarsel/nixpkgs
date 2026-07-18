{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rose-pine-kvantum";
  version = "0-unstable-2025-04-16";

  src = fetchFromGitHub {
    owner = "rose-pine";
    repo = "kvantum";
    rev = "48edf9e2d772b166ed50af3e182a19196e5d3fe6";
    hash = "sha256-0xSMYYPsW7Rw5O8FL0iAt63Hya8GkI2VuOZf64PewyQ=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/Kvantum/themes
    for i in $(find . -iname "*.tar.gz"); do
        tar -xf $i -C $out/share/Kvantum/themes
    done

    runHook postInstall
  '';

  dontBuild = true;

  meta = {
    description = "Kvantum-themes based on Rose Pine";
    homepage = "https://github.com/rose-pine/kvantum";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ amadaluzia ];
    platforms = lib.platforms.linux;
  };
})
