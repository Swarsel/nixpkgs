{
  # Basic
  lib,
  fetchFromGitHub,
  # Dependencies
  fd,
  fetchNpmDeps,
  melpaBuild,
  # Updater
  nix-update-script,
  # JavaScript dependency
  nodejs,
  npmHooks,
}:

melpaBuild (finalAttrs: {

  pname = "eaf-file-manager";
  version = "0-unstable-2025-03-23";

  src = fetchFromGitHub {
    owner = "emacs-eaf";
    repo = "eaf-file-manager";
    rev = "57f2e8a7f6282fbb4689b3fc8b99458ed3667dc6";
    hash = "sha256-IET9b3nS/Z4dxqFVyNITVoMDo6E/+sm3E7cfO7pozRo=";
  };

  postPatch = ''
    substituteInPlace buffer.py \
      --replace-fail "shutil.which(\"fd\")" \
                     "shutil.which(\"${lib.getExe fd}\")" \
      --replace-fail "return \"fd\"" \
                     "return \"${lib.getExe fd}\""
  '';

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  env.npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-dzfw+CgoM1CulPoa0KEzUX9dlBiquX4BkYNwU3vMb+Q=";
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
        pypinyin
        pygments
        exif
      ];

    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "File manager application for the EAF";
    homepage = "https://github.com/emacs-eaf/eaf-file-manager";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      thattemperature
    ];
  };

})
