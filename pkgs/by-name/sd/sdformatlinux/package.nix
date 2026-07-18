{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  util-linuxMinimal,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sdformatlinux";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "profi200";
    repo = "sdFormatLinux";
    rev = "v${finalAttrs.version}";
    hash = "sha256-AoAhP1dr+hQSnOpZC0oHt0j3fUVNVhD+3jWm6iMfskk=";
  };

  patches = [ ./remove-hardcoded-lsblk-path.diff ];
  strictDeps = true;
  nativeBuildInputs = [ installShellFiles ];

  makeFlags = [
    "TARGET=${finalAttrs.pname}"
    "LSBLK_PATH=${lib.getExe' util-linuxMinimal "lsblk"}"
  ];

  installPhase = ''
    runHook preInstall

    installBin ${finalAttrs.pname}

    runHook postInstall
  '';

  __structuredAttrs = true;

  meta = {
    description = "Format your SD card the way the SD Association intended";
    homepage = "https://github.com/profi200/sdFormatLinux";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ thiagokokada ];
    platforms = lib.platforms.linux;
    mainProgram = finalAttrs.pname;
  };
})
