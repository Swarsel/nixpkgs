{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  versionCheckHook,
}:
let
  platformName = if stdenv.hostPlatform.isLinux then "linux" else "macos";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "zsign";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "zhlynn";
    repo = "zsign";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NuwV8s+rzsXBha/vqnemvUo6Etm70ZVYL/CZKBJ1szA=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  makeFlags = [
    "BINDIR=bin/"
    "CXX=${stdenv.cc.targetPrefix}c++"
    "VERSION=${finalAttrs.version}"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin/
    cp bin/zsign $out/bin/

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  enableParallelBuilding = true;
  sourceRoot = "${finalAttrs.src.name}/build/${platformName}";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross-platform codesign alternative for iOS 12+";
    homepage = "https://github.com/zhlynn/zsign";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pascalj ];
    platforms = with lib.platforms; darwin ++ linux;
    mainProgram = "zsign";
  };
})
