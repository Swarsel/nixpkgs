{
  lib,
  stdenv,
  Dispatch,
  Foundation,
  callPackage,
  installShellFiles,
  swift,
  swiftpm,
  swiftpm2nix,
}:
let
  sources = callPackage ../sources.nix { };
  generated = swiftpm2nix.helpers ./generated;
in
stdenv.mkDerivation {
  inherit (sources) version;
  pname = "swift-format";
  src = sources.swift-format;

  nativeBuildInputs = [
    swift
    swiftpm
    installShellFiles
  ];

  buildInputs = [ Foundation ];

  env.LD_LIBRARY_PATH = lib.optionalString stdenv.hostPlatform.isLinux (
    lib.makeLibraryPath [ Dispatch ]
  );

  installPhase = ''
    binPath="$(swiftpmBinPath)"
    mkdir -p $out/bin
    cp $binPath/swift-format $out/bin/

    # Generate shell completions
    for shell in bash zsh fish; do
      $out/bin/swift-format --generate-completion-script $shell > swift-format.$shell
    done

    installShellCompletion --cmd swift-format \
      --bash swift-format.bash \
      --zsh swift-format.zsh \
      --fish swift-format.fish
  '';

  configurePhase = generated.configure;
  # We only install the swift-format binary, so don't need the other products.
  swiftpmFlags = [ "--product swift-format" ];

  meta = {
    description = "Formatting technology for Swift source code";
    homepage = "https://github.com/apple/swift-format";
    license = lib.licenses.asl20;
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "swift-format";
    teams = [ lib.teams.swift ];
  };
}
