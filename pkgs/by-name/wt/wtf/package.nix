{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wtf";
  version = "0.5.7";

  src = fetchFromGitHub {
    owner = "0vercl0k";
    repo = "wtf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lfPx9RQEW457VQkDbvu/D9EFZrdNLz2ToQ9dfa7+tzY=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_BUILD_TYPE" "Release")
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 wtf $out/bin/wtf

    runHook postInstall
  '';

  sourceRoot = "source/src";

  meta = {
    description = "Cross-platform snapshot-based fuzzer";
    homepage = "https://github.com/0vercl0k/wtf";
    changelog = "https://github.com/0vercl0k/wtf/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mikehorn ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "wtf";
  };
})
