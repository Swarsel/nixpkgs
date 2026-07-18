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

  pname = "eaf-image-viewer";
  version = "0-unstable-2023-06-30";

  src = fetchFromGitHub {
    owner = "emacs-eaf";
    repo = "eaf-image-viewer";
    rev = "154685532ff42bd7ff4fe5a80e96e0d3d56b4ee0";
    hash = "sha256-5MJibLr4UJOKl79PsDmXEZR+XFBx1xvcoykX4z/XbrI=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  env.npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-d1DVOAhYtXEzRQcUWFJE0gbHnqPRCUGibSqc/Nf3dVE=";
    name = "${finalAttrs.pname}-npm-deps";
  };

  postInstall = ''
    LISPDIR=$out/share/emacs/site-lisp/elpa/${finalAttrs.ename}-${finalAttrs.melpaVersion}
    touch node_modules/.nosearch
    cp -r node_modules $LISPDIR/
  '';

  files = ''
    ("*.el"
     "*.py"
     "*.html")
  '';

  passthru = {
    eafPythonDeps = ps: [ ];
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "Image viewer application for the EAF";
    homepage = "https://github.com/emacs-eaf/eaf-image-viewer";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      thattemperature
    ];
  };

})
