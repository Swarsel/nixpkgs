{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  makeWrapper,
  smartmontools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "snapraid";
  version = "14.7";

  src = fetchFromGitHub {
    owner = "amadvance";
    repo = "snapraid";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+h4kEvNtNEe7u0N1UWmZF3bH7em+Y2/XUyAdyDliV1g=";
  };

  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
  ];

  env.VERSION = finalAttrs.version;
  doCheck = true;

  # SMART is only supported on Linux and requires the smartmontools package
  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/snapraid \
     --prefix PATH : ${lib.makeBinPath [ smartmontools ]}
  '';

  meta = {
    description = "Backup program for disk arrays";
    homepage = "http://www.snapraid.it/";
    changelog = "https://github.com/amadvance/snapraid/blob/v${finalAttrs.version}/HISTORY";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.makefu ];
    platforms = lib.platforms.unix;
    mainProgram = "snapraid";
    downloadPage = "https://github.com/amadvance/snapraid/releases";
  };
})
