{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  cmake,
  openssl,
  pkg-config,
  python3,
  runCommand,
  rustPlatform,
}:

let
  openjtalk-src = fetchFromGitHub {
    hash = "sha256-SBLdQ8D62QgktI8eI6eSNzdYt5PmGo6ZUCKxd01Z8UE=";
    owner = "VOICEVOX";
    repo = "open_jtalk";
    rev = "1.11"; # this is actually a branch. why?
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "voicevox-core";
  # Update only together with voicevox and voicevox-engine
  # nixpkgs-update: no auto update
  version = "0.16.2";

  src = fetchFromGitHub {
    owner = "VOICEVOX";
    repo = "voicevox_core";
    tag = finalAttrs.version;
    hash = "sha256-aRy9x6IzFDwL4HjhCW705LpkZ13/SJ25h45XbbXciy0=";
  };

  postPatch = ''
    cp -r --no-preserve=all ${openjtalk-src} ./openjtalk
    substitute ${./openjtalk.patch} ./openjtalk.patch \
      --replace-fail "@openjtalk_src@" "$(pwd)/openjtalk"
    patch -d $cargoDepsCopy/*/open_jtalk-sys-* -p1 < ./openjtalk.patch
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [ openssl ];
  cargoHash = "sha256-8udiXUZGn3ZT7RvmZd/F5tLsCKi5QLPG3pzv7LFyLvQ=";
  # setting this to anything disables trying to download onnxruntime
  env.ORT_LIB_LOCATION = "dummy";
  doCheck = false;
  # don't link onnxruntime directly
  buildFeatures = [ "load-onnxruntime" ];
  cargoBuildFlags = [ "-p voicevox_core_c_api" ];
  passthru.modelVersion = "0.16.4";

  passthru.models = stdenv.mkDerivation {
    pname = "voicevox-models";
    version = finalAttrs.passthru.modelVersion;

    src = fetchFromGitHub {
      owner = "VOICEVOX";
      repo = "voicevox_vvm";
      tag = finalAttrs.passthru.modelVersion;
      hash = "sha256-/NU9CZcb+gHXHeno3NLF0EgPLw+6f8XyiAE2b9XJmuE=";
    };

    nativeBuildInputs = [ python3 ];

    installPhase = ''
      runHook preInstall

      # convert multipart zip archive into single file
      python scripts/merge_vvm.py

      # Exclude VOICEVOX Nemo models similar to upstream's CI, as voicevox-engine doesn't use them
      rm vvms/n*

      mkdir -p "$out"
      cp vvms/* "$out"

      runHook postInstall
    '';
  };

  passthru.voicevox-onnxruntime = callPackage ./onnxruntime.nix { };

  passthru.wrapped = runCommand "voicevox-core-${finalAttrs.version}-wrapped" { } (
    ''
      mkdir -p "$out"/lib
      cp ${finalAttrs.finalPackage}/lib/* "$out"/lib
      chmod -R +w "$out/lib"
      ln -s ${finalAttrs.passthru.voicevox-onnxruntime}/lib/* "$out"/lib
      ln -s ${finalAttrs.passthru.models} "$out"/lib/model
    ''
    # allow loading sibling onnxruntime library
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      patchelf --add-rpath '$ORIGIN' "$out"/lib/libvoicevox_core*
    ''
  );

  meta = {
    description = "Core library for the VOICEVOX speech synthesis software";
    homepage = "https://github.com/VOICEVOX/voicevox_core";
    changelog = "https://github.com/VOICEVOX/voicevox_core/releases/tag/${finalAttrs.version}";
    license = with lib.licenses; [ mit ];

    maintainers = with lib.maintainers; [
      tomasajt
      eljamm
    ];
  };
})
