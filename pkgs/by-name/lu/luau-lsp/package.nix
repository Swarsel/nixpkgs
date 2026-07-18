{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "luau-lsp";
  version = "1.68.1";

  src = fetchFromGitHub {
    owner = "JohnnyMorganz";
    repo = "luau-lsp";
    tag = finalAttrs.version;
    hash = "sha256-XxXAK/BaJcgel1vOATVbQVBxsxEYv9vr0w4JjmU64fM=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    (lib.cmakeFeature "CMAKE_OSX_ARCHITECTURES" stdenv.hostPlatform.darwinArch)
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error";

  buildPhase = ''
    runHook preBuild

    cmake --build . --target Luau.LanguageServer.CLI --config Release

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D luau-lsp $out/bin/luau-lsp

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Language Server Implementation for Luau";
    homepage = "https://github.com/JohnnyMorganz/luau-lsp";
    changelog = "https://github.com/JohnnyMorganz/luau-lsp/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ HeitorAugustoLN ];
    platforms = lib.platforms.all;
    mainProgram = "luau-lsp";
    downloadPage = "https://github.com/JohnnyMorganz/luau-lsp/releases/tag/${finalAttrs.version}";
  };
})
