{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cppfront";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "hsutter";
    repo = "cppfront";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QYjon2EpNexYa2fl09AePkpq0LkRVBOQM++eldcVMvI=";
  };

  # Remove with next release
  postPatch = ''
    substituteInPlace source/version.info \
      --replace-fail "0.8.0" "0.8.1"
  '';

  nativeBuildInputs = [
    installShellFiles
  ];

  buildPhase = ''
    runHook preBuild

    $CXX source/cppfront.cpp -std=c++20 -o cppfront

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    installBin cppfront
    cp -r include $out/include

    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  dontConfigure = true;
  versionCheckProgramArg = "-version";

  passthru = {
    tests.hello-world = stdenv.mkDerivation (finalAttrs': {
      inherit (finalAttrs) version src;
      pname = "${finalAttrs.pname}-hello-world-test";

      nativeBuildInputs = [
        finalAttrs.finalPackage
        installShellFiles
      ];

      postBuild = ''
        cppfront pure2-hello.cpp2
        $CXX -std=c++20 -o pure2-hello{,.cpp}
      '';

      postInstall = ''
        installBin pure2-hello
      '';

      doInstallCheck = true;

      postInstallCheck = ''
        $out/bin/pure2-hello | grep '^Hello \[world\]$' > /dev/null
      '';

      sourceRoot = "${finalAttrs'.src.name}/regression-tests";

      meta = {
        inherit (finalAttrs.meta) maintainers platforms;
        mainProgram = "pure2-hello";
      };
    });

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Experimental compiler from a potential C++ 'syntax 2' (Cpp2) to today's 'syntax 1' (Cpp1)";
    homepage = "https://hsutter.github.io/cppfront/";
    changelog = "https://github.com/hsutter/cppfront/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      asl20
      llvm-exception
    ];

    maintainers = with lib.maintainers; [
      marcin-serwin
    ];

    platforms = lib.platforms.all;
    mainProgram = "cppfront";
  };
})
