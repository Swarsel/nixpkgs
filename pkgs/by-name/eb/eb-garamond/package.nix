{
  lib,
  fetchFromGitHub,
  installFonts,
  python3,
  stdenvNoCC,
  ttfautohint-nox,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "eb-garamond";
  version = "0.016";

  src = fetchFromGitHub {
    owner = "georgd";
    repo = "EB-Garamond";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ajieKhTeH6yv2qiE2xqnHFoMS65//4ZKiccAlC2PXGQ=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "@\$(SFNTTOOL) -w \$< \$@"   "@fontforge -lang=ff -c 'Open(\$\$1); Generate(\$\$2)' \$< \$@"
  '';

  nativeBuildInputs = [
    installFonts
    (python3.withPackages (p: [ p.fontforge ]))
    ttfautohint-nox
  ];

  buildPhase = ''
    runHook preBuild
    make WEB=build EOT="" all
    runHook postBuild
  '';

  # installFonts adds a hook to `postInstall` that installs fonts
  # into the correct directories
  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';

  meta = {
    description = "Digitization of the Garamond shown on the Egenolff-Berner specimen";
    homepage = "http://www.georgduffner.at/ebgaramond/";
    license = lib.licenses.ofl;

    maintainers = with lib.maintainers; [
      bengsparks
      relrod
      rycee
    ];

    platforms = lib.platforms.all;
  };
})
