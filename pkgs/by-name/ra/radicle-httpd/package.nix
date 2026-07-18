{
  lib,
  stdenv,
  asciidoctor,
  fetchFromRadicle,
  git,
  installShellFiles,
  makeWrapper,
  man-db,
  nixosTests,
  rustPlatform,
  versionCheckHook,
  xdg-utils,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "radicle-httpd";
  version = "0.25.0";

  # You must update the radicle-explorer source hash when changing this.
  src = fetchFromRadicle {
    repo = "z4V1sjrXqjvFdnCUbxPFqd5p4DtH5";
    tag = "releases/${finalAttrs.version}";
    hash = "sha256-gejNiCQ511OGGItmqXoyB+TmsUw+ozoEmOWooBXBkQ8=";
    seed = "seed.radicle.dev";
    sparseCheckout = [ "radicle-httpd" ];
  };

  nativeBuildInputs = [
    asciidoctor
    installShellFiles
    makeWrapper
  ];

  cargoHash = "sha256-Oawin/2R5dZ46pf3SarwNgILF9dXSkw02Z4gYQ4HtzE=";
  env.RADICLE_VERSION = finalAttrs.version;
  doCheck = stdenv.hostPlatform.isLinux;
  nativeCheckInputs = [ git ];

  postInstall = ''
    for page in $(find -name '*.adoc'); do
      asciidoctor -d manpage -b manpage $page
      installManPage ''${page::-5}
    done
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postFixup = ''
    for program in $out/bin/* ;
    do
      wrapProgram "$program" \
        --prefix PATH : "${
          lib.makeBinPath [
            git
            man-db
            xdg-utils
          ]
        }"
    done
  '';

  sourceRoot = "${finalAttrs.src.name}/radicle-httpd";
  versionCheckProgramArg = "--version";

  passthru = {
    tests = { inherit (nixosTests) radicle; };
    updateScript = ./update.sh;
  };

  meta = {
    description = "Radicle JSON HTTP API Daemon";

    longDescription = ''
      A Radicle HTTP daemon exposing a JSON HTTP API that allows someone to browse local
      repositories on a Radicle node via their web browser.
    '';

    homepage = "https://radicle.dev";
    changelog = "https://radicle.network/nodes/seed.radicle.dev/rad:z4V1sjrXqjvFdnCUbxPFqd5p4DtH5/tree/radicle-httpd/CHANGELOG.md";

    # cargo.toml says MIT and asl20, LICENSE file says GPL3
    license = with lib.licenses; [
      gpl3Only
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ gador ];
    platforms = lib.platforms.unix;
    mainProgram = "radicle-httpd";
    teams = [ lib.teams.radicle ];
  };
})
