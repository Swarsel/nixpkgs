{
  lib,
  stdenv,
  fetchFromGitHub,
  android-tools,
  fuse,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "adbfs-rootless";
  version = "0-unstable-2023-03-21";

  src = fetchFromGitHub {
    owner = "spion";
    repo = "adbfs-rootless";
    rev = "fd56381af4dc9ae2f09b904c295686871a46ed0f";
    sha256 = "atiVjRfqvhTlm8Q+3iTNNPQiNkLIaHDLg5HZDJvpl2Q=";
  };

  postPatch = ''
    # very ugly way of replacing the adb calls
    substituteInPlace adbfs.cpp \
      --replace-fail '"adb ' '"${android-tools}/bin/adb '
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ fuse ];

  installPhase = ''
    runHook preInstall
    install -D adbfs $out/bin/adbfs
    runHook postInstall
  '';

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Mount Android phones on Linux with adb, no root required";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
    mainProgram = "adbfs";
  };
})
