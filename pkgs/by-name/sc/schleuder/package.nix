{
  lib,
  stdenv,
  bundlerApp,
  bundlerUpdateScript,
  nixosTests,
  ruby,
}:

bundlerApp {
  inherit ruby;
  pname = "schleuder";

  exes = [
    "schleuder"
    "schleuder-api-daemon"
  ];

  gemdir = ./.;

  passthru.tests = {
    inherit (nixosTests) schleuder;
  };

  passthru.updateScript = bundlerUpdateScript "schleuder";

  meta = {
    description = "Encrypting mailing list manager with remailing-capabilities";

    longDescription = ''
      Schleuder is a group's email-gateway: subscribers can exchange
      encrypted emails among themselves, receive emails from
      non-subscribers and send emails to non-subscribers via the list.
    '';

    homepage = "https://schleuder.org";
    changelog = "https://0xacab.org/schleuder/schleuder/blob/main/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    broken = stdenv.hostPlatform.isDarwin;
  };
}
