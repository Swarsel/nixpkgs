{
  lib,
  fetchurl,
  nixosTests,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "mediawiki";
  version = "1.45.3";

  src = fetchurl {
    url = "https://releases.wikimedia.org/mediawiki/${lib.versions.majorMinor version}/mediawiki-${version}.tar.gz";
    hash = "sha256-XqjB8yHJ+Nuk0aweTsoYJ/sTUZ1KIZDiOfUUMgWKQmk=";
  };

  postPatch = ''
    substituteInPlace includes/installer/CliInstaller.php \
      --replace-fail '$vars = Installer::getExistingLocalSettings();' '$vars = null;'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mediawiki
    cp -r * $out/share/mediawiki
    echo "<?php
      return require(getenv('MEDIAWIKI_CONFIG'));
    ?>" > $out/share/mediawiki/LocalSettings.php

    runHook postInstall
  '';

  passthru.tests = {
    inherit (nixosTests.mediawiki) mysql postgresql;
  };

  meta = {
    description = "Collaborative editing software that runs Wikipedia";
    homepage = "https://www.mediawiki.org/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      # for the C3D2
      SuperSandro2000
    ];

    platforms = lib.platforms.all;
  };
}
