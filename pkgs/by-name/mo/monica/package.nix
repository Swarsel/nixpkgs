{
  lib,
  stdenv,
  fetchurl,
  nixosTests,
  dataDir ? "/var/lib/monica",
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "monica";
  version = "4.1.2";

  src = fetchurl {
    url = "https://github.com/monicahq/monica/releases/download/v${finalAttrs.version}/monica-v${finalAttrs.version}.tar.bz2";
    hash = "sha256-7ZdOSI/gldSWub5FIyYQw3gpLe+PRAnq03u6DXdZ2YE=";
  };

  installPhase = ''
    mkdir $out
    cp -R * $out/
    rm -rf $out/storage
    ln -s ${dataDir}/.env $out/.env
    ln -s ${dataDir}/storage $out/storage
  '';

  dontBuild = true;
  passthru.tests.monica = nixosTests.monica;

  meta = {
    description = "Personal CRM";

    longDescription = ''
      Remember everything about your friends, family and business
      relationships.
    '';

    homepage = "https://www.monicahq.com/";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.all;
  };
})
