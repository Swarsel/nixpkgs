{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nix-update-script,
  nodejs,
  yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "diff2html-cli";
  version = "5.2.15";

  src = fetchFromGitHub {
    owner = "rtfpessoa";
    repo = "diff2html-cli";
    rev = finalAttrs.version;
    hash = "sha256-aQoWn5n+xpYjhDQjw9v5HzWf/Hhmm6AK22OG4Ugq6Gk=";
  };

  postPatch = ''
    substituteInPlace package.json \
      --replace-fail "4.2.1" "${finalAttrs.version}";
  '';

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  yarnOfflineCache = fetchYarnDeps {
    inherit (finalAttrs) src;
    hash = "sha256-9JkzWhsXUrjnMcDDJfqm+tZ+WV5j3CHJbpn9j7v/KLg=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Generate pretty HTML diffs from unified and git diff output in your terminal";
    homepage = "https://diff2html.xyz#cli";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "diff2html";
  };
})
