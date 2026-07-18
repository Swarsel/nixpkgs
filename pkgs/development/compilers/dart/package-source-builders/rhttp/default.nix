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
    pname = "rhttp-rs";

    cargoHash =
      {
        _0_10_0 = "sha256-2SpAj53XvZXKRpMzFXJGcx7E2TlMUD+ooHkFwg/9fe4=";
        _0_11_0 = "sha256-sngh5k9GoCZhnIFTpnAVHZjxTcOv+Ui6pJ2cFyriL84=";
        _0_12_0 = "sha256-W2DcBy1n73nR2oZIQcFt6A+NElQWtfEtKB1YIweQUVo=";
        _0_15_1 = "sha256-Dsw5KbOLkmaOq8ESk1NzprMT/PTWLnHTQVii5gpNVPc=";
        _0_9_1 = "sha256-ZVl1nesepZnmOWeJPOgE6IDCokQm5FedbA5MBvr5S8c=";
        _0_9_6 = "sha256-vvzb+jNN5lmRrKJ3zqvORvdduqEHRmbp85L/9Zegh/E=";
        _0_9_8 = "sha256-cwb1wYVXOE5YABlMxUDt+OMlDpIlipqeNI7ZFAGHCqo=";
      }
      .${"_" + (lib.replaceStrings [ "." ] [ "_" ] version)} or (throw ''
        Unsupported version of pub 'rhttp': '${version}'
        Please add cargoHash here. If the cargoHash
        is the same with existing versions, add an alias here.
      '');

    env.RUSTFLAGS = "--cfg reqwest_unstable";
    sourceRoot = "${src.name}/rust";

    unpackPhase = ''
      runHook preUnpack

      if [ -d $src/rhttp ]; then
        cp -r $src/rhttp ${src.name}
      else
        cp -r $src ${src.name}
      fi
      chmod -R u+w -- "$sourceRoot"

      runHook postUnpack
    '';

    passthru.libraryPath = "lib/librhttp.so";
  };

in
stdenv.mkDerivation {
  inherit version src;
  inherit (src) passthru;
  pname = "rhttp";

  patches = [
    (replaceVars ./cargokit.patch {
      output_lib = "${rustDep}/${rustDep.passthru.libraryPath}";
    })
  ];

  postPatch = ''
    popd || true
  '';

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  prePatch = ''
    if [ -d rhttp ]; then pushd rhttp; fi
  '';
}
