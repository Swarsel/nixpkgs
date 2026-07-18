{
  lib,
  fetchFromGitHub,
  nixosTests,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "icingaweb2-thirdparty";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "Icinga";
    repo = "icinga-php-thirdparty";
    rev = "v${version}";
    sha256 = "sha256-vPr6rh/X5G///rqmgIdCYKDLeZMQVNK7FoINONO7Cw8=";
  };

  installPhase = ''
    mkdir -p "$out"
    cp -r * "$out"
  '';

  passthru.tests = { inherit (nixosTests) icingaweb2; };

  meta = {
    description = "Third party dependencies for Icingaweb 2";
    homepage = "https://github.com/Icinga/icinga-php-thirdparty";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      das_j
      helsinki-Jo
    ];

    platforms = lib.platforms.all;
  };
}
