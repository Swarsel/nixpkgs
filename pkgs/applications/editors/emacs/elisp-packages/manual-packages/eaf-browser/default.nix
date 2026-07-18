{
  # Basic
  lib,
  fetchFromGitHub,
  # Dependencies
  aria2,
  fetchNpmDeps,
  melpaBuild,
  # Updater
  nix-update-script,
  # JavaScript dependency
  nodejs,
  npmHooks,
}:

melpaBuild (finalAttrs: {

  pname = "eaf-browser";
  version = "0-unstable-2025-06-14";

  src = fetchFromGitHub {
    owner = "emacs-eaf";
    repo = "eaf-browser";
    rev = "120967319132f361a2b27f89ee54d1984aa23eaf";
    hash = "sha256-DsPrctB1bSGBPQLI2LsnSUtqnzWpZRrWrVZM8lS9fms=";
  };

  postPatch = ''
    substituteInPlace buffer.py \
      --replace-fail "aria2_args = [\"aria2c\"]" \
                     "aria2_args = [\"${lib.getExe aria2}\"]"
  '';

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  env.npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-UfQL7rN47nI1FyhgBlzH4QtyVCn0wGV3Rv5Y+aidRNE=";
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
     "easylist.txt"
     "aria2-ng")
  '';

  passthru = {
    eafPythonDeps =
      ps: with ps; [
        pysocks
        pycookiecheat
      ];

    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "Modern browser in Emacs";
    homepage = "https://github.com/emacs-eaf/eaf-browser";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      thattemperature
    ];
  };

})
