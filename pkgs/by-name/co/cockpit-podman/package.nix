{
  lib,
  stdenv,
  fetchFromGitHub,
  cockpit,
  gettext,
  gitUpdater,
  nodejs,
  podman,
  writeShellScriptBin,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cockpit-podman";
  version = "128";

  src = fetchFromGitHub {
    owner = "cockpit-project";
    repo = "cockpit-podman";
    tag = finalAttrs.version;
    hash = "sha256-GlnIZGV5nk7o28EUs4H/IdZkgtHG0a9uwCTCS4rCP6c=";
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

    substituteInPlace src/manifest.json \
      --replace-fail '"/lib/systemd' '"/run/current-system/sw/lib/systemd'

    patchShebangs build.js
  '';

  buildInputs = [
    nodejs
    gettext
    (writeShellScriptBin "git" "true")
  ];

  cockpitSrc = cockpit.src;

  passthru = {
    cockpitPath = [ podman ];
    updateScript = gitUpdater { };
  };

  meta = {
    description = "Cockpit UI for podman containers";
    homepage = "https://github.com/cockpit-project/cockpit-podman";
    changelog = "https://github.com/cockpit-project/cockpit-podman/releases/tag/${finalAttrs.version}";
    license = [ lib.licenses.lgpl21 ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cockpit ];
  };
})
