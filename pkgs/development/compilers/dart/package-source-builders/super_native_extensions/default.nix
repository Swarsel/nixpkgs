{
  lib,
  stdenv,
  at-spi2-atk,
  cairo,
  gdk-pixbuf,
  gtk3,
  pkg-config,
  rustPlatform,
  writeText,
}:

{ src, version, ... }:

let
  rustDep = rustPlatform.buildRustPackage {
    inherit version src;
    pname = "super_native_extensions-rs";
    nativeBuildInputs = [ pkg-config ];

    buildInputs = [
      at-spi2-atk
      gdk-pixbuf
      cairo
      gtk3
    ];

    cargoHash =
      rec {
        _0_8_17 = _0_8_22;
        _0_8_18 = _0_8_22;
        _0_8_19 = _0_8_22;
        _0_8_20 = _0_8_22;
        _0_8_21 = _0_8_22;
        _0_8_22 = "sha256-gYYoC3bGJrYY1uUHfqMv6pp4SK+P9fRoBsLtf34rsCg=";
        _0_8_24 = _0_8_22;
        _0_9_0-dev_3 = _0_8_22;
        _0_9_0-dev_5 = _0_8_22;
        _0_9_0-dev_6 = "sha256-1yJIbBxScmkCwy/e+/z2cYA8qQBfT0yoIBmOSPVd4h4=";
        _0_9_1 = _0_9_0-dev_6;
      }
      .${"_" + (lib.replaceStrings [ "." ] [ "_" ] version)} or (throw ''
        Unsupported version of pub 'super_native_extensions': '${version}'
        Please add cargoHash to here. If the cargoHash
        is the same with existing versions, add an alias here.
      '');

    sourceRoot = "${src.name}/rust";

    unpackPhase = ''
      runHook preUnpack

      if [ -d $src/super_native_extensions ]; then
        cp -r $src/super_native_extensions ${src.name}
      else
        cp -r $src ${src.name}
      fi
      chmod -R u+w -- "$sourceRoot"

      runHook postUnpack
    '';

    passthru.libraryPath = "lib/libsuper_native_extensions.so";
  };

  fakeCargokitCmake = writeText "FakeCargokit.cmake" ''
    function(apply_cargokit target manifest_dir lib_name any_symbol_name)
      target_link_libraries("''${target}" PRIVATE ${rustDep}/${rustDep.passthru.libraryPath})
      set("''${target}_cargokit_lib" ${rustDep}/${rustDep.passthru.libraryPath} PARENT_SCOPE)
    endfunction()
  '';

in
stdenv.mkDerivation {
  inherit version src;
  inherit (src) passthru;
  pname = "super_native_extensions";

  installPhase = ''
    runHook preInstall

    cp -r "$src" "$out"
    if [ -d $out/super_native_extensions ]; then
      pushd $out/super_native_extensions
    else
      pushd $out
    fi
    chmod +rwx cargokit/cmake/cargokit.cmake
    cp ${fakeCargokitCmake} cargokit/cmake/cargokit.cmake
    popd

    runHook postInstall
  '';
}
