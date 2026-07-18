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

  pname = "eaf-map";
  version = "0-unstable-2025-07-04";

  src = fetchFromGitHub {
    owner = "emacs-eaf";
    repo = "eaf-map";
    rev = "667865a9422ec71e3518833e1a13806d4f03adfb";
    hash = "sha256-UgHIzYu/K1NzTDvUn2JkEmiyDEBT9JDmlvp6xG7Nv5k=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  env.npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-prxCFrKvC2dG9BgO3LIKDCFzjn9vFegpvuMy4Eg6Ghs=";
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
    eafPythonDeps =
      ps: with ps; [
        numpy
        pycurl
        python-tsp
      ];

    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "OpenStreetMap application for the EAF";
    homepage = "https://github.com/emacs-eaf/eaf-map";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      thattemperature
    ];
  };

})
