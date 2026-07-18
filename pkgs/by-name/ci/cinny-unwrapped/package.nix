{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage (finalAttrs: {
  pname = "cinny-unwrapped";
  # Remember to update cinny-desktop when bumping this version.
  version = "4.12.3";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "cinnyapp";
    repo = "cinny";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RjPdq9xNvUbJESV7CqxmgfqAx+MoKZbhUtJNTcH9aUk=";
  };

  npmDepsHash = "sha256-CU8AVRuMFOGI0/LbN0LGysBk+qc2XQYxQGfrrH72stc=";

  installPhase = ''
    runHook preInstall

    cp -r dist $out

    runHook postInstall
  '';

  # Skip rebuilding native modules since they're not needed for the web app
  npmRebuildFlags = [
    "--ignore-scripts"
  ];

  meta = {
    description = "Yet another Matrix client for the web";
    homepage = "https://cinny.in/";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      abbe
      rebmit
      ryand56
    ];

    platforms = lib.platforms.all;
  };
})
