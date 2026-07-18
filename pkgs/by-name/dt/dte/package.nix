{
  lib,
  stdenv,
  fetchFromGitLab,
  nix-update-script,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dte";
  version = "1.11.1";

  src = fetchFromGitLab {
    owner = "craigbarnes";
    repo = "dte";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PG9yfRzJKXVKAg8ubIvX2Rj4nLO3dki7shP+zAa7nxo=";
  };

  postInstall = ''
    mv $out/usr/local/* $out
    rm -rf $out/usr
  '';

  installFlags = [ "DESTDIR=${placeholder "out"}" ];

  passthru = {
    tests.version = testers.testVersion {
      command = "dte -V";
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Small, configurable terminal text editor";
    homepage = "https://gitlab.com/craigbarnes/dte";
    changelog = "https://gitlab.com/craigbarnes/dte/-/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ yiyu ];
    platforms = lib.platforms.all;
    mainProgram = "dte";
  };
})
