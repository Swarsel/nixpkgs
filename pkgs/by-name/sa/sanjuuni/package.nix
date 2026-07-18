{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  ffmpeg,
  gitUpdater,
  ocl-icd,
  opencl-clhpp,
  pkg-config,
  poco,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sanjuuni";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "MCJack123";
    repo = "sanjuuni";
    rev = finalAttrs.version;
    hash = "sha256-wJRPD4OWOTPiyDr9dYseRA7BI942HPfHONVJGTc/+wU=";
  };

  postPatch = ''
    # TODO: Remove when https://github.com/MCJack123/sanjuuni/commit/778644b164c8877e56f9f5512480dde857133815 is released
    substituteInPlace configure \
      --replace-fail "swr_alloc_set_opts" "swr_alloc_set_opts2"
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    ffmpeg
    poco
    ocl-icd
    opencl-clhpp
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 sanjuuni $out/bin/sanjuuni

    runHook postInstall
  '';

  passthru = {
    tests = {
      run-on-nixos-artwork = callPackage ./tests/run-on-nixos-artwork.nix { };
    };

    updateScript = gitUpdater { };
  };

  meta = {
    description = "Command-line tool that converts images and videos into a format that can be displayed in ComputerCraft";
    homepage = "https://github.com/MCJack123/sanjuuni";
    changelog = "https://github.com/MCJack123/sanjuuni/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.tomodachi94 ];
    mainProgram = "sanjuuni";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
