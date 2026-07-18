{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  callPackage,
  coreutils,
  installShellFiles,
  jre,
  makeWrapper,
  scala-cli,
  testers,
  zlib,
}:

let
  pname = "scala-cli";
  sources = lib.importJSON ./sources.json;
  inherit (sources) version assets;

  platforms = builtins.attrNames assets;
in
stdenv.mkDerivation {
  inherit pname version;

  src =
    let
      asset =
        assets."${stdenv.hostPlatform.system}"
          or (throw "Unsupported platform ${stdenv.hostPlatform.system}");
    in
    fetchurl {
      url = "https://github.com/Virtuslab/scala-cli/releases/download/v${version}/${asset.asset}";
      sha256 = asset.sha256;
    };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;

  buildInputs =
    assert lib.assertMsg (lib.versionAtLeast jre.version "17.0.0") ''
      scala-cli requires Java 17 or newer, but ${jre.name} is ${jre.version}
    '';
    [
      coreutils
      zlib
      stdenv.cc.cc
    ];

  installPhase = ''
    runHook preInstall
    install -Dm755 scala-cli $out/bin/.scala-cli-wrapped
    makeWrapper $out/bin/.scala-cli-wrapped $out/bin/scala-cli \
      --set JAVA_HOME ${jre.home} \
      --argv0 "$out/bin/scala-cli"
    runHook postInstall
  '';

  postFixup =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      autoPatchelf $out
    ''
    + ''
      # hack to ensure the completion function looks right
      # as $0 is used to generate the compdef directive
      mkdir temp
      cp $out/bin/.scala-cli-wrapped temp/scala-cli
      PATH="./temp:$PATH"

      installShellCompletion --cmd scala-cli \
        --bash <(scala-cli completions bash) \
        --zsh <(scala-cli completions zsh)
    '';

  # We need to call autopatchelf before generating completions
  dontAutoPatchelf = true;

  unpackPhase = ''
    runHook preUnpack
    gzip -d < $src > scala-cli
    runHook postUnpack
  '';

  passthru.tests.version = testers.testVersion {
    command = "scala-cli version --offline";
    package = scala-cli;
  };

  passthru.updateScript = callPackage ./update.nix { } { inherit platforms pname version; };

  meta = {
    inherit platforms;
    description = "Command-line tool to interact with the Scala language";
    homepage = "https://scala-cli.virtuslab.org";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      kubukoz
      agilesteel
    ];

    mainProgram = "scala-cli";
    downloadPage = "https://github.com/VirtusLab/scala-cli/releases/v${version}";
  };
}
