{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "nika-fonts";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "font-store";
    repo = "NikaFont";
    rev = "v${version}";
    hash = "sha256-jDemm8IyjhoCOg4Bfsp0tzUR7m+JaswL5d7Kug+asJk=";
  };

  installPhase = ''
    runHook preInstall

    find . -name '*.ttf' -exec install -m444 -Dt $out/share/fonts/nika-fonts {} \;

    runHook postInstall
  '';

  meta = {
    description = "Persian/Arabic Open Source Font";
    homepage = "https://github.com/font-store/NikaFont/";
    license = lib.licenses.ofl;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
