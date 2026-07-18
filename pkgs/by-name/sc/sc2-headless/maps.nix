{
  fetchzip,
  licenseAccepted,
}:
let
  fetchzip' =
    if !licenseAccepted then
      throw ''
        You must accept the Blizzard® Starcraft® II AI and Machine Learning License at
        https://blzdistsc2-a.akamaihd.net/AI_AND_MACHINE_LEARNING_LICENSE.html
        by setting nixpkgs config option 'sc2-headless.accept_license = true;'
      ''
    else
      assert licenseAccepted;
      args:
      (fetchzip args).overrideAttrs (old: {
        UNZIP = "-j -P iagreetotheeula";
      });
in
{
  ladder2017season1 = fetchzip' {
    sha256 = "0ngg4g74s2ryhylny93fm8yq9rlrhphwnjg2s6f3qr85a2b3zdpd";
    stripRoot = false;
    url = "http://blzdistsc2-a.akamaihd.net/MapPacks/Ladder2017Season1.zip";
  };

  ladder2017season2 = fetchzip' {
    sha256 = "01kycnvqagql9pkjkcgngfcnry2pc4kcygdkk511m0qr34909za5";
    stripRoot = false;
    url = "http://blzdistsc2-a.akamaihd.net/MapPacks/Ladder2017Season2.zip";
  };

  ladder2017season3 = fetchzip' {
    sha256 = "0wix3lwmbyxfgh8ldg0n66i21p0dbavk2dxjngz79rx708m8qvld";
    stripRoot = false;
    url = "http://blzdistsc2-a.akamaihd.net/MapPacks/Ladder2017Season3_Updated.zip";
  };

  ladder2017season4 = fetchzip' {
    sha256 = "1sidnmk2rc9j5fd3a4623pvaika1mm1rwhznb2qklsqsq1x2qckp";
    stripRoot = false;
    url = "http://blzdistsc2-a.akamaihd.net/MapPacks/Ladder2017Season4.zip";
  };

  ladder2018season1 = fetchzip' {
    sha256 = "0mp0ilcq0gmd7ahahc5i8c7bdr3ivk6skx0b2cgb1z89l5d76irq";
    stripRoot = false;
    url = "http://blzdistsc2-a.akamaihd.net/MapPacks/Ladder2018Season1.zip";
  };

  ladder2018season2 = fetchzip' {
    sha256 = "176rs848cx5src7qbr6dnn81bv1i86i381fidk3v81q9bxlmc2rv";
    stripRoot = false;
    url = "http://blzdistsc2-a.akamaihd.net/MapPacks/Ladder2018Season2_Updated.zip";
  };

  ladder2018season3 = fetchzip' {
    sha256 = "1r3wv4w53g9zq6073ajgv74prbdsd1x3zfpyhv1kpxbffyr0x0zp";
    stripRoot = false;
    url = "http://blzdistsc2-a.akamaihd.net/MapPacks/Ladder2018Season3.zip";
  };

  ladder2018season4 = fetchzip' {
    sha256 = "0k47rr6pzxbanlqnhliwywkvf0w04c8hxmbanksbz6aj5wpkcn1s";
    stripRoot = false;
    url = "http://blzdistsc2-a.akamaihd.net/MapPacks/Ladder2018Season4.zip";
  };

  ladder2019season1 = fetchzip' {
    sha256 = "1dlk9zza8h70lbjvg2ykc5wr9vsvvdk02szwrkgdw26mkssl2rg9";
    stripRoot = false;
    url = "http://blzdistsc2-a.akamaihd.net/MapPacks/Ladder2019Season1.zip";
  };

  melee = fetchzip' {
    sha256 = "0z44pgy10jklsvgpr0kcn4c2mz3hw7nlcmvsy6a6lzpi3dvzf33i";
    stripRoot = false;
    url = "http://blzdistsc2-a.akamaihd.net/MapPacks/Melee.zip";
  };

  minigames = fetchzip {
    sha256 = "19f873ilcdsf50g2v0s2zzmxil1bqncsk8nq99bzy87h0i7khkla";
    stripRoot = false;
    url = "https://github.com/deepmind/pysc2/releases/download/v1.2/mini_games.zip";
  };
}
