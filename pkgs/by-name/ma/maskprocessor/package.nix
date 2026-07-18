{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "maskprocessor";
  version = "0.73";

  src = fetchFromGitHub {
    owner = "hashcat";
    repo = "maskprocessor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LVtMz5y0PbKKuc92W5xW0C84avigR7vS1XL/aXkUYe8=";
  };

  # upstream Makefile is terrible, this simplifies everything.
  buildPhase = ''
    runHook preBuild

    $CC -o maskprocessor src/mp.c -W -Wall -std=c99 -O2 -s -DLINUX

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm544 -t $out/bin maskprocessor

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "High-Performance word generator with a per-position configureable charset";
    homepage = "https://github.com/hashcat/maskprocessor";
    changelog = "https://github.com/hashcat/maskprocessor/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.unix;
    mainProgram = "maskprocessor";
  };
})
