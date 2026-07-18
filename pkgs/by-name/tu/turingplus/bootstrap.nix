{
  lib,
  stdenv,
  autoPatchelfHook,
  coreutils,
  fetchzip,
  libredirect,
  makeWrapper,
}:
let
  sources = {
    "x86_64-linux" = {
      sha256 = "sha256-FoOlOcRWpStg4aerjr+FmcXXnwYftrqG1j4iZJ+4AzE=";
      url = "https://github.com/CordyJ/Open-TuringPlus/releases/download/v6.2.1/opentplus-62-linux64.tar.gz";
    };
  };

  redirects = [
    # Turing+ library/includes
    "/usr/local/lib/tplus=${placeholder "out"}/lib"
    "/local/lib/tplus=${placeholder "out"}/lib"
    "/usr/local/include/tplus=${placeholder "out"}/include"
    "/local/include/tplus=${placeholder "out"}/include"
    # Turing+ binaries
    "/usr/local/bin=${placeholder "out"}/bin"
    # Other
    "/bin/rm=${coreutils}/bin/rm"
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "turingplus-bootstrap";
  version = "6.2.1";
  src = fetchzip sources."${stdenv.hostPlatform.system}";

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib,include}
    cp bin/* $out/bin/
    cp lib/* $out/lib/
    cp -r include/* $out/include/

    runHook postInstall
  '';

  # Wrap package and redirect FHS reads to the derivation output
  postInstall =
    let
      preloadVar = if stdenv.hostPlatform.isDarwin then "DYLD_INSERT_LIBRARIES" else "LD_PRELOAD";
      preloadLib = "${libredirect}/lib/libredirect" + stdenv.hostPlatform.extensions.sharedLibrary;
    in
    ''
      wrapProgram $out/bin/tpc \
        --set ${preloadVar} ${preloadLib} \
        --set NIX_REDIRECTS ${builtins.concatStringsSep ":" redirects} \
        --set NIX_ENFORCE_PURITY 0

      wrapProgram $out/bin/tssl \
        --set ${preloadVar} ${preloadLib} \
        --set NIX_REDIRECTS ${builtins.concatStringsSep ":" redirects} \
        --set NIX_ENFORCE_PURITY 0
    '';

  dontBuild = true;

  meta = {
    description = "Extended version of the Turing programming language with concurrency and systems programming features";
    homepage = "https://github.com/CordyJ/Open-TuringPlus";
    changelog = "https://github.com/CordyJ/Open-TuringPlus/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ MysteryBlokHed ];

    platforms = [
      "x86_64-linux"
    ];

    mainProgram = "tpc";
    downloadPage = "https://github.com/CordyJ/Open-TuringPlus/releases";
  };
})
