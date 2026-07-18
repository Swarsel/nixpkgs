{
  lib,
  stdenv,
  fetchFromGitHub,
  discord,
  discord-canary,
  discord-development,
  discord-ptb,
  fetchPnpmDeps,
  git,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  buildWebExtension ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "equicord";
  # Upstream discourages inferring the package version from the package.json found in
  # the Equicord repository. Dates as tags (and automatic releases) were the compromise
  # we came to with upstream. Please do not change the version schema (e.g., to semver)
  # unless upstream changes the tag schema from dates.
  version = "2026-05-26";

  src = fetchFromGitHub {
    owner = "Equicord";
    repo = "Equicord";
    tag = finalAttrs.version;
    hash = "sha256-m/BdSErumQrWCSyejRFm5HcSR4FwDS2JkAXvy9PejmI=";
  };

  nativeBuildInputs = [
    git
    nodejs
    pnpmConfigHook
    pnpm_10
  ];

  env = {
    EQUICORD_HASH = "${finalAttrs.src.tag}";
    EQUICORD_REMOTE = "${finalAttrs.src.owner}/${finalAttrs.src.repo}";
  };

  buildPhase = ''
    runHook preBuild

    pnpm run ${if buildWebExtension then "buildWeb" else "build"} \
      -- --standalone --disable-updater

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r dist/${lib.optionalString buildWebExtension "chromium-unpacked/"} $out

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-RwppRWrEzIKZDb3QLVAMd1bHXyFwiatYNiNccVgrcWA=";
    pnpm = pnpm_10;
  };

  passthru = {
    tests = lib.genAttrs' [ discord discord-ptb discord-canary discord-development ] (
      p: lib.nameValuePair p.pname p.tests.withEquicord
    );

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "^(\\d{4}-\\d{2}-\\d{2})$"
      ];
    };
  };

  meta = {
    description = "Other cutest Discord client mod";
    homepage = "https://github.com/Equicord/Equicord";
    license = lib.licenses.gpl3Only;

    maintainers = [
      lib.maintainers.NotAShelf
    ];

    platforms = lib.platforms.unix;
  };
})
