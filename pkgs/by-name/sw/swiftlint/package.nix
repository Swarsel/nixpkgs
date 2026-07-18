{
  lib,
  fetchurl,
  installShellFiles,
  runCommand,
  stdenvNoCC,
  unzip,
  versionCheckHook,
}:
let
  sources = lib.importJSON ./sources.json;
  platform =
    sources.platforms.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported platform: ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (sources) version;
  pname = "swiftlint";

  src = fetchurl {
    inherit (platform) hash;
    url = "https://github.com/realm/SwiftLint/releases/download/${finalAttrs.version}/${platform.filename}";
  };

  nativeBuildInputs = [
    unzip
    installShellFiles
  ];

  installPhase =
    let
      binary = if stdenvNoCC.hostPlatform.isLinux then "swiftlint-static" else "swiftlint";
    in
    ''
      runHook preInstall
      install -Dm755 ${binary} $out/bin/swiftlint
      runHook postInstall
    '';

  postInstall = lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
    installShellCompletion --cmd swiftlint \
      --bash <($out/bin/swiftlint --generate-completion-script bash) \
      --fish <($out/bin/swiftlint --generate-completion-script fish) \
      --zsh <($out/bin/swiftlint --generate-completion-script zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  dontBuild = true;
  dontConfigure = true;
  dontPatch = true;
  sourceRoot = ".";

  passthru = {
    tests = {
      lint =
        runCommand "swiftlint-test-lint"
          {
            nativeBuildInputs = [ finalAttrs.finalPackage ];
          }
          ''
            printf "class test{}\n\nvar a = 1" > test.swift
            swiftlint lint ${lib.optionalString stdenvNoCC.hostPlatform.isDarwin "--disable-sourcekit"} test.swift > output.txt 2>&1 || true
            grep -q "identifier_name" output.txt
            grep -q "opening_brace" output.txt
            grep -q "trailing_newline" output.txt
            grep -q "type_name" output.txt
            touch $out
          '';
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Tool to enforce Swift style and conventions";
    homepage = "https://realm.github.io/SwiftLint/";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    maintainers = with lib.maintainers; [
      matteopacini
      DimitarNestorov
    ];

    platforms = lib.attrNames sources.platforms;
    mainProgram = "swiftlint";
  };
})
