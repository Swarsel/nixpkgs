{
  cmdparse = {
    version = "3.0.7";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0f87jny4zk21iyrkyyw4kpnq8ymrwjay02ipagwapimy237cmigp";
      type = "gem";
    };
  };

  geom2d = {
    version = "0.4.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nafcfznjqycxd062cais64ydgl99xddh4zy4hp7bwn4j3m9h2ga";
      type = "gem";
    };
  };

  hexapdf = {
    version = "1.0.2";

    dependencies = [
      "cmdparse"
      "geom2d"
      "openssl"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13dbscnf7c3jlghlkgl01b7hzgx2ps26m57qmhyv5g626n342i4c";
      type = "gem";
    };
  };

  openssl = {
    version = "3.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "054d6ybgjdzxw567m7rbnd46yp6gkdbc5ihr536vxd3p15vbhjrw";
      type = "gem";
    };
  };
}
