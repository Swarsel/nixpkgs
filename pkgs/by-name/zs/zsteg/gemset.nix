{
  forwardable = {
    version = "1.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0f78rjpnhm4lgp1qzadnr6kr02b6afh1lvy7w607k4qjk3641kgi";
      type = "gem";
    };
  };

  iostruct = {
    version = "0.7.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1774p81hdx9wd678g4mnaffdhs1340zvvq7h8l80x6mplgz2ygz9";
      type = "gem";
    };
  };

  prime = {
    version = "0.1.4";

    dependencies = [
      "forwardable"
      "singleton"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pi2g9sd9ssyrpvbybh4skrgzqrv0rrd1q7ylgrsd519gjzmwxad";
      type = "gem";
    };
  };

  rainbow = {
    version = "3.1.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0smwg4mii0fm38pyb5fddbmrdpifwv22zv3d3px2xx497am93503";
      type = "gem";
    };
  };

  singleton = {
    version = "0.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0y2pc7lr979pab5n5lvk3jhsi99fhskl5f2s6004v8sabz51psl3";
      type = "gem";
    };
  };

  zpng = {
    version = "0.4.6";

    dependencies = [
      "iostruct"
      "rainbow"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vi4chg2k17ha6ax6wg2fa7bri0c85xzxkd55xk68j5cgngn5x20";
      type = "gem";
    };
  };

  zsteg = {
    version = "0.2.14";

    dependencies = [
      "iostruct"
      "prime"
      "zpng"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vqg35sbicpb93zcwcjyvlqapijh64dfv1v1jh30cqqjhmdf67kn";
      type = "gem";
    };
  };
}
