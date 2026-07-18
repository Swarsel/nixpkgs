{
  lib,
  fetchFromGitHub,
  installFonts,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "material-design-icons";
  version = "7.4.47";

  src = fetchFromGitHub {
    owner = "Templarian";
    repo = "MaterialDesign-Webfont";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7t3i3nPJZ/tRslLBfY+9kXH8TR145GC2hPFYJeMHRL8=";
    sparseCheckout = [ "fonts" ];
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "7000+ Material Design Icons from the Community";

    longDescription = ''
      Material Design Icons' growing icon collection allows designers and
      developers targeting various platforms to download icons in the format,
      color and size they need for any project.
    '';

    homepage = "https://materialdesignicons.com";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      vlaci
      dixslyf
    ];

    platforms = lib.platforms.all;
  };
})
