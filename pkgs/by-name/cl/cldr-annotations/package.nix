{
  lib,
  fetchzip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "cldr-annotations";
  version = "48.2";

  src = fetchzip {
    url = "https://unicode.org/Public/cldr/${version}/cldr-common-${version}.zip";
    hash = "sha256-fFSLvhND8lg9gQFsrP3XScpSsGwCWWjuLhN22gQSVNs=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/unicode/cldr/common
    mv common/annotations{,Derived} -t $out/share/unicode/cldr/common

    runHook postInstall
  '';

  meta = {
    description = "Names and keywords for Unicode characters from the Common Locale Data Repository";
    homepage = "https://cldr.unicode.org";
    license = lib.licenses.unicode-30;
    maintainers = with lib.maintainers; [ DeeUnderscore ];
    platforms = lib.platforms.all;
  };
}
