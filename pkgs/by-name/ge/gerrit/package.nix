{
  lib,
  fetchurl,
  gitUpdater,
  nixosTests,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gerrit";
  version = "3.13.6";

  src = fetchurl {
    url = "https://gerrit-releases.storage.googleapis.com/gerrit-${finalAttrs.version}.war";
    hash = "sha256-nGKl5KNundR+FkiQ5CO/qBezOSNAHDHcPsssm1lZAhk=";
  };

  buildCommand = ''
    mkdir -p "$out"/webapps/
    ln -s ${finalAttrs.src} "$out"/webapps/gerrit-${finalAttrs.version}.war
  '';

  passthru = {
    # A list of plugins that are part of the gerrit.war file.
    # Use `java -jar gerrit.war ls | grep plugins/` to generate that list.
    plugins = [
      "codemirror-editor"
      "commit-message-length-validator"
      "delete-project"
      "download-commands"
      "gitiles"
      "hooks"
      "plugin-manager"
      "replication"
      "reviewnotes"
      "singleusergroup"
      "webhooks"
    ];

    tests = {
      inherit (nixosTests) gerrit;
    };

    updateScript = gitUpdater {
      allowedVersions = "^[0-9\\.]+$";
      rev-prefix = "v";
      url = "https://gerrit.googlesource.com/gerrit";
    };
  };

  meta = {
    description = "Web based code review and repository management for the git version control system";
    homepage = "https://www.gerritcodereview.com/index.md";
    changelog = "https://www.gerritcodereview.com/${lib.versions.majorMinor finalAttrs.version}.html";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      flokli
      zimbatm
      felixsinger
    ];

    platforms = lib.platforms.unix;
  };
})
