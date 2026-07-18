{
  lib,
  stdenv,
  fetchFromGitHub,
  cockpit,
  gettext,
  gitUpdater,
  nodejs,
  writeShellScriptBin,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cockpit-files";
  version = "42";

  src = fetchFromGitHub {
    owner = "cockpit-project";
    repo = "cockpit-files";
    tag = finalAttrs.version;
    hash = "sha256-NfI6y60O5ctsPbwPcXgkwxpNYuZkF/2YXZOIcRZUc5c=";
    fetchSubmodules = true;
    postFetch = "cp $out/node_modules/.package-lock.json $out/package-lock.json";
  };

  postPatch = ''
    mkdir -p pkg; cp -r $cockpitSrc/pkg/lib pkg
    mkdir -p test; cp -r $cockpitSrc/test/common test

    substituteInPlace Makefile \
      --replace-fail '$(MAKE) package-lock.json' 'true' \
      --replace-fail '$(COCKPIT_REPO_FILES) | tar x' "" \
      --replace-fail '/usr/local' "$out"

    patchShebangs build.js
  '';

  buildInputs = [
    nodejs
    gettext
    (writeShellScriptBin "git" "true")
  ];

  cockpitSrc = cockpit.src;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Featureful file browser for Cockpit";
    homepage = "https://github.com/cockpit-project/cockpit-files";
    changelog = "https://github.com/cockpit-project/cockpit-files/releases/tag/${finalAttrs.version}";
    license = [ lib.licenses.lgpl21 ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cockpit ];
  };
})
