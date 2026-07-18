{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  callPackage,
  fetchpatch2,
  nix-update-script,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "x16-emulator";
  version = "48";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "X16Community";
    repo = "x16-emulator";
    tag = "r${finalAttrs.version}";
    hash = "sha256-E4TosRoORCWLotOIXROP9oqwqo1IRSa6X13GnmuxE9A=";
  };

  # Fix build on GCC 14
  # TODO: Remove for next release as it should already be included in upstream
  patches = [
    (fetchpatch2 {
      hash = "sha256-DZItqq7B1lXZ6VFsQUdQKn0wt1HaX4ymq2pI2DamY3w=";
      url = "https://github.com/X16Community/x16-emulator/commit/3da83c93d46a99635cf73a6f9fdcf1bd4a4ae04f.patch";
    })
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail '/bin/echo' 'echo'
  '';

  buildInputs = [
    SDL2
    zlib
  ];

  installPhase = ''
    runHook preInstall

    install -Dm 755 -t $out/bin/ x16emu
    install -Dm 444 -t $out/share/doc/x16-emulator/ README.md

    runHook postInstall
  '';

  dontConfigure = true;

  passthru = {
    # upstream project recommends emulator and rom to be synchronized; passing
    # through the version is useful to ensure this
    inherit (finalAttrs) version;
    emulator = finalAttrs.finalPackage;
    rom = callPackage ./rom.nix { };

    run = (callPackage ./run.nix { }) {
      inherit (finalAttrs.finalPackage) emulator rom;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    inherit (SDL2.meta) platforms;
    description = "Official emulator of CommanderX16 8-bit computer";
    homepage = "https://cx16forum.com/";
    changelog = "https://github.com/X16Community/x16-emulator/blob/${finalAttrs.src.rev}/RELEASES.md";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ pluiedev ];
    mainProgram = "x16emu";
    broken = stdenv.hostPlatform.isAarch64; # ofborg fails to compile it
  };
})
