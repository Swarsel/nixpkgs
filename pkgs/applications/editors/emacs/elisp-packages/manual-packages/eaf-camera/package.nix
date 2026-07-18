{
  # Basic
  lib,
  fetchFromGitHub,
  fetchNpmDeps,
  melpaBuild,
  # Updater
  nix-update-script,
  # JavaScript dependency
  nodejs,
  npmHooks,
}:

melpaBuild (finalAttrs: {

  pname = "eaf-camera";
  version = "0-unstable-2025-03-09";

  src = fetchFromGitHub {
    owner = "emacs-eaf";
    repo = "eaf-camera";
    rev = "264e34489c175d25a9611446ad82a1d1adbfb896";
    hash = "sha256-tw4OA1Sbvj3eqm3B4Ou6Gxk3wegmS7wMy2/U+UGTCcY=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  env.npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-MmNg4Qf1UhtUIpHjCcwk9MB59XGRhW9SzhO4yUcW1Ik=";
    name = "${finalAttrs.pname}-npm-deps";
  };

  postBuild = ''
    npm run build
  '';

  postInstall = ''
    LISPDIR=$out/share/emacs/site-lisp/elpa/${finalAttrs.ename}-${finalAttrs.melpaVersion}
    touch node_modules/.nosearch
    cp -r node_modules $LISPDIR/
    cp -r dist $LISPDIR/
  '';

  files = ''
    ("*.el"
     "*.py"
     "*.js"
     "src")
  '';

  passthru = {
    eafPythonDeps = ps: [ ];
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "Camera application for the EAF";
    homepage = "https://github.com/emacs-eaf/eaf-camera";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      thattemperature
    ];
  };

})
