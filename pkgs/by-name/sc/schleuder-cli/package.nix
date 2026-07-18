{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  ruby,
}:

bundlerApp {
  inherit ruby;
  pname = "schleuder-cli";

  exes = [
    "schleuder-cli"
  ];

  gemdir = ./.;
  installManpages = false;
  passthru.updateScript = bundlerUpdateScript "schleuder-cli";

  meta = {
    description = "Command line tool to create and manage schleuder-lists";

    longDescription = ''
      Schleuder-cli enables creating, configuring, and deleting lists,
      subscriptions, keys, etc. It uses the Schleuder API, provided by
      schleuder-api-daemon (part of Schleuder).
    '';

    homepage = "https://schleuder.org";
    changelog = "https://0xacab.org/schleuder/schleuder-cli/-/blob/main/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
  };
}
