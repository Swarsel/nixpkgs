{
  lib,
  stdenv,
  base16-schemes,
}:
stdenv.mkDerivation {
  inherit (base16-schemes) version src;
  pname = "base24-schemes";
  strictDeps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/themes
    install base24/*.yaml $out/share/themes/

    runHook postInstall
  '';

  __structuredAttrs = true;
  dontBuild = true;

  meta = base16-schemes.meta // {
    description = "Base24 color schemes from Tinted Theming";
    maintainers = with lib.maintainers; [ nyxar77 ];
  };
}
