{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  pkg-config,
  vips,
}:

buildNpmPackage (finalAttrs: {
  pname = "psitransfer";
  version = "2.4.4";

  src = fetchFromGitHub {
    owner = "psi-4ward";
    repo = "psitransfer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-A26Mse69+ChyqUKhx5TlIdZYVC5e5bOPQ4DX8eVKcHw=";
  };

  postPatch = ''
    rm -r public/app
    cp -r ${finalAttrs.app} public/app
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    vips # for 'sharp' dependency
  ];

  npmDepsHash = "sha256-IgPqX6nxxTWA6gLr2NP42vnGS+e98mWUWBIMSsIriRY=";

  app = buildNpmPackage {
    inherit (finalAttrs) version src;
    pname = "psitransfer-app";

    postPatch = ''
      # https://github.com/psi-4ward/psitransfer/pull/284
      touch public/app/.npmignore
      cd app
    '';

    npmDepsHash = "sha256-PpUO1u7TcH8ZcTekLcGOn07EnCHqUlbEMS/YzMLSMAs=";

    installPhase = ''
      cp -r ../public/app $out
    '';
  };

  dontBuild = true;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Simple open source self-hosted file sharing solution";
    homepage = "https://github.com/psi-4ward/psitransfer";
    changelog = "https://github.com/psi-4ward/psitransfer/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    mainProgram = "psitransfer";
  };
})
