{
  lib,
  stdenv,
  buildNpmPackage,
  clang_20,
  libsecret,
  pkg-config,
  pname,
  python3,
  src,
  version,
}:
buildNpmPackage {
  inherit version src;
  pname = "${pname}-node-deps";

  nativeBuildInputs = [
    python3
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ clang_20 ]; # clang_21 breaks keytar

  buildInputs = [ libsecret ];
  npmDepsHash = "sha256-TCeIBrlsNuphW2gVsX97+Wu1lOG5gDwS7559YA1d10M=";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp -r node_modules $out/lib

    runHook postInstall
  '';

  dontNpmBuild = true;
}
