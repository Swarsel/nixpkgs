{
  lib,
  fetchFromGitLab,
  gnumake,
  python3Packages,
  stdenvNoCC,
  truetype ? false,
}:

stdenvNoCC.mkDerivation rec {
  pname = "smc-manjari";
  version = "2.200";

  src = fetchFromGitLab {
    owner = "fonts";
    repo = "manjari";
    rev = "Version${version}";
    hash = "sha256-B3EI6rrZyhc3xJuVIDVIjLrjJmFoFzHIwVV/4EBQv1s=";
    group = "smc";
  };

  nativeBuildInputs = [
    gnumake
    python3Packages.fontmake
  ];

  buildFlags = [ "otf" ] ++ lib.optional truetype "ttf";

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/share/fonts/opentype build/*.otf
    ${lib.optionalString truetype "install -Dm444 -t $out/share/fonts/truetype build/*.ttf"}

    install -Dm644 -t $out/etc/fonts/conf.d *.conf

    install -Dm644 -t $out/share/doc/${pname}-${version} OFL.txt FONTLOG.md

    runHook postInstall
  '';

  meta = {
    description = "Manjari Malayalam Typeface";
    homepage = "https://smc.org.in/fonts/manjari";
    license = lib.licenses.ofl;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
