{
  lib,
  buildNpmPackage,
  src,
  version,
}:

buildNpmPackage {
  inherit version;
  pname = "szurubooru-client";
  src = "${src}/client";
  npmDepsHash = "sha256-HtcitZl2idgVleB6c0KCTSNLxh7hP8/G/RGdMaQG3iI=";

  installPhase = ''
    runHook preInstall

    mkdir $out
    mv ./public/* $out

    runHook postInstall
  '';

  makeCacheWritable = true;

  npmBuildFlags = [
    "--gzip"
  ];

  meta = {
    description = "Client of szurubooru, an image board engine for small and medium communities";
    homepage = "https://github.com/rr-/szurubooru";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ratcornu ];
  };
}
