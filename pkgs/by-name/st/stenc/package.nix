{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  installShellFiles,
  nix-update-script,
  pandoc,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "stenc";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "scsitape";
    repo = "stenc";
    tag = finalAttrs.version;
    sha256 = "sha256-M7b+T0mm2QTP1LqqjdKV/NWZ60DrueFEnN1unwCOeH4=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    pandoc
    installShellFiles
  ];

  doCheck = true;

  postInstall = ''
    installShellCompletion --bash bash-completion/stenc
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "SCSI Tape Encryption Manager";
    homepage = "https://github.com/scsitape/stenc";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ woffs ];
    platforms = lib.platforms.linux;
    mainProgram = "stenc";
  };
})
