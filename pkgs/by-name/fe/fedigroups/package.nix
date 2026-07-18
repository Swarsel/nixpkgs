{
  lib,
  fetchFromGitea,
  git,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fedigroups";
  version = "0.4.6";

  src = fetchFromGitea {
    owner = "MightyPork";
    repo = "group-actor";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Sq22CwLLR10yrN3+dR2KDoS8r99+LWOH7+l+D3RWlKw=";
    domain = "git.ondrovo.com";
    forceFetchGit = true; # Archive generation is disabled on this gitea instance
    leaveDotGit = true; # git command in build.rs
  };

  nativeBuildInputs = [
    pkg-config
    git
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-6UijHshvKANtMMfNADWDViDrh6bGlPvFz4xqJeWdqB0=";

  meta = {
    description = "Approximation of groups usable with Fediverse software that implements the Mastodon client API";
    homepage = "https://git.ondrovo.com/MightyPork/group-actor#fedi-groups";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.all;
    mainProgram = "fedigroups";
    downloadPage = "https://git.ondrovo.com/MightyPork/group-actor/releases";
  };
})
