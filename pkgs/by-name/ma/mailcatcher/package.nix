{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  nixosTests,
  ruby,
}:

bundlerApp {
  pname = "mailcatcher";

  exes = [
    "mailcatcher"
    "catchmail"
  ];

  gemdir = ./.;
  passthru.tests = { inherit (nixosTests) mailcatcher; };
  passthru.updateScript = bundlerUpdateScript "mailcatcher";

  meta = {
    description = "SMTP server and web interface to locally test outbound emails";
    homepage = "https://mailcatcher.me/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      zarelit
      nicknovitski
    ];

    platforms = lib.platforms.unix;
  };
}
