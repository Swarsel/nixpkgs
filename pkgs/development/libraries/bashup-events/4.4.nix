{ fetchFromGitHub, callPackage }:

callPackage ./generic.nix {
  version = "2020-04-04";

  src = fetchFromGitHub {
    owner = "bashup";
    repo = "events";
    rev = "e97654f5602fc4e31083b27afa18dcc89b3e8296";
    hash = "sha256-51OSIod3mEg3MKs4rrMgRcOimDGC+3UIr4Bl/cTRyGM=";
  };

  branch = "bash44";

  keep = {
    # allow vars executed as commands
    "$f" = true;
    "$n" = true;

    # allow vars in eval
    eval = [
      "e"
      "bashup_ev"
      "n"
    ];
  };

  variant = "4.4";
}
