{
  lib,
  stdenv,
  replaceVars,
  rustPlatform,
}:

{ src, version, ... }:

let
  rustDep = rustPlatform.buildRustPackage {
    inherit version src;
    pname = "flutter_discord_rpc-rs";

    cargoHash =
      {
        _1_0_0 = "sha256-C9WDE9+6V59yNCNVeMUY5lRpMJ+8XWpHpxzdTmz+/Yw=";
        _1_1_0 = "sha256-Kztnt30EcqjXUNEAJW65P6yLjdnyW4Q+lHe6qlCe3xM=";
      }
      .${"_" + (lib.replaceStrings [ "." ] [ "_" ] version)} or (throw ''
        Unsupported version of pub 'flutter_discord_rpc': '${version}'
        Please add cargoHash here. If the cargoHash
        is the same with existing versions, add an alias here.
      '');

    buildAndTestSubdir = "rust";
    passthru.libraryPath = "lib/libflutter_discord_rpc.so";
  };
in
stdenv.mkDerivation {
  inherit version src;
  inherit (src) passthru;
  pname = "flutter_discord_rpc";

  patches = [
    (replaceVars ./cargokit.patch {
      output_lib = "${rustDep}/${rustDep.passthru.libraryPath}";
    })
  ];

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';
}
