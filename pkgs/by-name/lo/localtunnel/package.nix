{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nix-update-script,
  nodejs,
  yarnConfigHook,
  yarnInstallHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "localtunnel";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "localtunnel";
    repo = "localtunnel";
    rev = "v${finalAttrs.version}";
    hash = "sha256-6gEK1VjF25Kbe2drxbxUKDNJGqZ+OXgkulPkAkMR2+k=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnInstallHook
    nodejs
  ];

  yarnOfflineCache = fetchYarnDeps {
    inherit (finalAttrs) src;
    hash = "sha256-zq9ygsKDU4lIsNxc6ovW+IXVztQoEaJAekzBrwCK7ik=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI for localtunnel";
    homepage = "https://localtunnel.me";
    changelog = "https://github.com/localtunnel/localtunnel/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "lt";
  };
})
