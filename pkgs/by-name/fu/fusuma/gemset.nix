{
  fusuma = {
    version = "3.9.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13kkqwd268haxap05282cizqrc7py4cn5r5mxk3z88qz950c8n02";
      type = "gem";
    };
  };

  fusuma-plugin-appmatcher = {
    version = "0.8.0";

    dependencies = [
      "fusuma"
      "rexml"
      "ruby-dbus"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "120imyw1ir7c94g4j16anfv4c61y4qmy9xj5rg75mypz97nq8xp7";
      type = "gem";
    };
  };

  fusuma-plugin-keypress = {
    version = "0.11.0";
    dependencies = [ "fusuma" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16csdj695y9b8bvl65cby57fsyfr30pb9qq6h0wyqrxily6cn6il";
      type = "gem";
    };
  };

  fusuma-plugin-sendkey = {
    version = "0.14.0";

    dependencies = [
      "fusuma"
      "revdev"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gy0gz2kyavfvq4sfqvybzaah8hiajfzi2mlcizv2n834vy9lwhj";
      type = "gem";
    };
  };

  fusuma-plugin-wmctrl = {
    version = "1.4.2";
    dependencies = [ "fusuma" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v2g5a6qpzn7w2g0812qi3pxm0ilpb5wj00ivxfnflh74yyf69wi";
      type = "gem";
    };
  };

  logger = {
    version = "1.7.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00q2zznygpbls8asz5knjvvj2brr3ghmqxgr83xnrdj4rk3xwvhr";
      type = "gem";
    };
  };

  revdev = {
    version = "0.2.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1b6zg6vqlaik13fqxxcxhd4qnkfgdjnl4wy3a1q67281bl0qpsz9";
      type = "gem";
    };
  };

  rexml = {
    version = "3.4.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jmbf6lf7pcyacpb939xjjpn1f84c3nw83dy3p1lwjx0l2ljfif7";
      type = "gem";
    };
  };

  ruby-dbus = {
    version = "0.25.0";

    dependencies = [
      "logger"
      "rexml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0528x9jm3frq3r10ilf1fkhsy3m5w2gkr93pa5xcixv1daliqhzy";
      type = "gem";
    };
  };
}
