{
  lib,
  fetchFromGitLab,
  gnumake,
  python3Packages,
  stdenvNoCC,
  truetype ? false,
}:

stdenvNoCC.mkDerivation rec {
  pname = "chilanka";
  version = "1.7";

  src = fetchFromGitLab {
    owner = "fonts";
    repo = "chilanka";
    rev = "Version${version}";
    hash = "sha256-VvotRUQks8vUqJOcYHqy6cuwaAKYg4OqtiAjaBIdBRk=";
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

    install -Dm444 -t $out/etc/fonts/conf.d *.conf

    install -Dm644 -t $out/share/doc/${pname}-${version} OFL.txt FONTLOG.md

    runHook postInstall
  '';

  meta = {
    description = "Chilanka Malayalam Typeface";
    homepage = "https://smc.org.in/fonts/chilanka";
    license = lib.licenses.ofl;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
