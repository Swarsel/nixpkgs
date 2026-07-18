{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "svg-text-to-path";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "paulzi";
    repo = "svg-text-to-path";
    tag = "v${finalAttrs.version}";
    hash = "sha256-B6/8BbJ75jeFpTFIzL6BtMNCRL9181KxrUkaP9u9odA=";
  };

  npmDepsHash = "sha256-x593WtqC9Y8AweL6LOr228p1eAc1rI4C+6Ev1K3pUJo=";
  dontNpmBuild = true;
  npmPackFlags = [ "--ignore-scripts" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Convert svg nodes to vector font-free elements";
    homepage = "https://github.com/paulzi/svg-text-to-path";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.unix;
    mainProgram = "svg-text-to-path";
  };
})
