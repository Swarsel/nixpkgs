{
  lib,
  stdenv,
  fetchFromGitHub,
  cc65,
  lzsa,
  nix-update-script,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "x16-rom";
  version = "48";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "X16Community";
    repo = "x16-rom";
    rev = "r${finalAttrs.version}";
    hash = "sha256-MXt839wpPdGVFgf1CAqfmWEP2Ws+5uUFOI14vAdUTvk=";
  };

  postPatch = ''
    patchShebangs findsymbols scripts/
    substituteInPlace Makefile \
      --replace-fail '/bin/echo' 'echo'
  '';

  nativeBuildInputs = [
    cc65
    lzsa
    python3
  ];

  makeFlags = [ "PRERELEASE_VERSION=${finalAttrs.version}" ];

  installPhase = ''
    runHook preInstall

    install -Dm 444 -t $out/share/x16-rom/ build/x16/rom.bin
    install -Dm 444 -t $out/share/doc/x16-rom/ README.md

    runHook postInstall
  '';

  dontConfigure = true;

  passthru = {
    # upstream project recommends emulator and rom to be synchronized; passing
    # through the version is useful to ensure this
    inherit (finalAttrs) version;
    updateScript = nix-update-script { };
  };

  meta = {
    inherit (cc65.meta) platforms;
    description = "ROM file for CommanderX16 8-bit computer";
    homepage = "https://github.com/X16Community/x16-rom";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ pluiedev ];
    broken = stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64;
  };
})
