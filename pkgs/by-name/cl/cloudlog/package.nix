{
  lib,
  fetchFromGitHub,
  nix-update-script,
  nixosTests,
  php,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "cloudlog";
  version = "2.8.15";

  src = fetchFromGitHub {
    owner = "magicbug";
    repo = "Cloudlog";
    rev = version;
    hash = "sha256-WkOe1Y1pmyAqRfEy7PigiBGscfIJemqcEYTqvpNnwsc=";
  };

  postPatch = ''
    substituteInPlace index.php \
      --replace "define('ENVIRONMENT', 'development');" "define('ENVIRONMENT', 'production');"
  '';

  installPhase = ''
    mkdir $out/
    cp -R ./* $out
  '';

  passthru = {
    tests = {
      inherit (nixosTests) cloudlog;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Web based amateur radio logging application built using PHP & MySQL";
    homepage = "https://www.magicbug.co.uk/cloudlog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ haennetz ];
    platforms = php.meta.platforms;
  };
}
