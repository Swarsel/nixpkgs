{
  lib,
  fetchFromGitHub,
  buildGoModule,
  bzip2,
  callPackage,
  libunarr,
  mupdf-headless,
  nix-update-script,
  versionCheckHook,
  zlib,
}:

buildGoModule (finalAttrs: {
  pname = "cbconvert";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "gen2brain";
    repo = "cbconvert";
    rev = "v${finalAttrs.version}";
    hash = "sha256-C2Eox6fpKS0fPB7KFgBn62HKbWYacSVMJK0CkT6+FBU=";
  };

  buildInputs = [
    bzip2
    libunarr
    mupdf-headless
    zlib
  ];

  vendorHash = "sha256-uV8aIUKy9HQdZvR3k8CTTrHsh9TyBw21gFTdjR1XJlg=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X main.appVersion=${finalAttrs.version}"
  ];

  modRoot = "cmd/cbconvert";
  # The extlib tag forces the github.com/gen2brain/go-unarr module to use external libraries instead of bundled ones.
  tags = [ "extlib" ];
  versionCheckProgramArg = "version";

  passthru = {
    gui = callPackage ./gui.nix { };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Comic Book converter";
    homepage = "https://github.com/gen2brain/cbconvert";
    changelog = "https://github.com/gen2brain/cbconvert/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ gpl3Only ];
    maintainers = with lib.maintainers; [ jwillikers ];
    platforms = lib.platforms.linux;
    mainProgram = "cbconvert";
  };
})
