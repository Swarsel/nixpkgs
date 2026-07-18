{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildNpmPackage,
  git,
  jq,
  moreutils,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "opengist";
  version = "1.13.1";

  src = fetchFromGitHub {
    owner = "thomiceli";
    repo = "opengist";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jMB6TudICAjX0DGw62qP8X39q3OOT2Bvg70LJbFWqkE=";
  };

  postPatch = ''
    mkdir -p public/.vite
    cp ${finalAttrs.frontend}/public/.vite/manifest.json public/.vite/manifest.json
    cp -R ${finalAttrs.frontend}/public/assets public/
  '';

  vendorHash = "sha256-MRY677UiZg7j5HTFejvuzIJwEMczbhi6sIbGYjRnWeM=";
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    git
    writableTmpDirAsHomeHook
  ];

  checkPhase = ''
    runHook preCheck

    make test

    runHook postCheck
  '';

  frontend = buildNpmPackage {
    inherit (finalAttrs) version src;
    pname = "opengist-frontend";

    # npm complains of "invalid package". shrug. we can give it a version.
    postPatch = ''
      ${lib.getExe jq} '.version = "${finalAttrs.version}"' package.json | ${lib.getExe' moreutils "sponge"} package.json
    '';

    npmDepsHash = "sha256-Ci25S0kgT5C46xTzNTs0kn8QEvYqJuj/yU33Ymfci68=";

    installPhase = ''
      mkdir -p $out
      cp -R public $out
    '';
  };

  ldflags = [
    "-s"
    "-X github.com/thomiceli/opengist/internal/config.OpengistVersion=v${finalAttrs.version}"
  ];

  tags = [ "fs_embed" ];

  passthru = {
    inherit (finalAttrs) frontend;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Self-hosted pastebin powered by Git";
    homepage = "https://github.com/thomiceli/opengist";
    changelog = "https://github.com/thomiceli/opengist/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ phanirithvij ];
    platforms = lib.platforms.unix;
    mainProgram = "opengist";
  };
})
