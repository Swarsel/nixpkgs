{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  testers,
  # Optional Dependencies
  alsa-lib ? null,
  celt_0_7 ? null,
  db ? null,
  libffado ? null,
  libuuid ? null,
}:

let
  shouldUsePkg =
    pkg: if pkg != null && lib.meta.availableOn stdenv.hostPlatform pkg then pkg else null;

  optAlsaLib = shouldUsePkg alsa-lib;
  optDb = shouldUsePkg db;
  optLibuuid = shouldUsePkg libuuid;
  optLibffado = shouldUsePkg libffado;
  optCelt = shouldUsePkg celt_0_7;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "jack1";
  version = "0.126.0";

  src = fetchurl {
    url = "https://github.com/jackaudio/jack1/releases/download/${finalAttrs.version}/jack1-${finalAttrs.version}.tar.gz";
    hash = "sha256-eykOnce5JirDKNQe74DBBTyXAT76y++jBHfLmypUReo=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    optAlsaLib
    optDb
    optLibffado
    optCelt
  ];

  propagatedBuildInputs = [ optLibuuid ];

  configureFlags = [
    (lib.enableFeature (optLibffado != null) "firewire")
  ];

  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "JACK audio connection kit";
    homepage = "https://jackaudio.org";

    license = with lib.licenses; [
      gpl2Plus
      lgpl21
    ];

    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
    pkgConfigModules = [ "jack" ];
  };
})
