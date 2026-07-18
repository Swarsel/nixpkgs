{
  lib,
  autoPatchelfHook,
  fetchzip,
  installShellFiles,
  makeWrapper,
  stdenvNoCC,
  testers,
  zlib,
}:
let
  platform =
    {
      aarch64-darwin = "arm64-apple-darwin";
      x86_64-linux = "x86_64-pc-linux";
    }
    ."${stdenvNoCC.system}" or (throw "unsupported system ${stdenvNoCC.hostPlatform.system}");
  hash =
    {
      aarch64-darwin = "sha256-qL0hjEdfkN62NDvhlzVgW4TYWv0IReo2Fo5eVhUaOrI=";
      x86_64-linux = "sha256-SGV0fEuwmGwpqmD42a+x0fIK50RWSHEYDesH4obgRhg=";
    }
    ."${stdenvNoCC.system}" or (throw "unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "bleep";
  version = "0.0.13";

  src = fetchzip {
    url = "https://github.com/oyvindberg/bleep/releases/download/v${finalAttrs.version}/bleep-${platform}.tar.gz";
    hash = hash;
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ]
  ++ lib.optional stdenvNoCC.hostPlatform.isLinux autoPatchelfHook;

  buildInputs = [ zlib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 bleep -t $out/bin/
    runHook postInstall
  '';

  postFixup =
    lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
      autoPatchelf $out
    ''
    + lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
      export PATH=$PATH:$out/bin
      installShellCompletion --cmd bleep \
        --bash <(bleep install-tab-completions-bash --stdout) \
        --zsh <(bleep install-tab-completions-zsh --stdout)
    '';

  dontAutoPatchelf = true;

  passthru.tests.version = testers.testVersion {
    command = "bleep --help | sed -n '/Bleeping/s/[^0-9.]//gp'";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Bleeping fast scala build tool";
    homepage = "https://bleep.build/";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ kristianan ];

    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "bleep";
  };
})
