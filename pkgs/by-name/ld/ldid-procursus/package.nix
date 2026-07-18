{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  installShellFiles,
  libplist,
  openssl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ldid-procursus";
  version = "2.1.5-procursus7";

  src = fetchFromGitHub {
    owner = "ProcursusTeam";
    repo = "ldid";
    rev = "v${finalAttrs.version}";
    hash = "sha256-QnSmWY9zCOPYAn2VHc5H+VQXjTCyr0EuosxvKGGpDtQ=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-D5o/E2tCbuNOv2D9UVaLEx8ZiwSB/wT0hf7XaTGzxE0=";
      name = "fix-memory-issues-with-various-entitlements.patch";
      url = "https://github.com/ProcursusTeam/ldid/commit/f38a095aa0cc721c40050cb074116c153608a11b.patch";
    })
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "pkg-config" "$PKG_CONFIG"
  '';

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    libplist
    openssl
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  postInstall = ''
    installShellCompletion --cmd ldid --zsh _ldid
  '';

  dontConfigure = true;
  stripDebugFlags = [ "--strip-unneeded" ];

  meta = {
    description = "Put real or fake signatures in a Mach-O binary";
    homepage = "https://github.com/ProcursusTeam/ldid";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ keto ];
    platforms = lib.platforms.unix;
    mainProgram = "ldid";
  };
})
