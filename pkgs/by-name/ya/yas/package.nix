{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "yas";
  version = "7.1.0";

  src = fetchFromGitHub {
    owner = "niXman";
    repo = "yas";
    rev = version;
    hash = "sha256-2+CpftWOEnntYBCc1IoR5eySbmhrMVunpUTZRdQ5I+A=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/include/yas
    cp -r include/yas/* $out/include/yas
    runHook postInstall
  '';

  meta = {
    description = "Yet Another Serialization";
    homepage = "https://github.com/niXman/yas";
    license = lib.licenses.boost;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
