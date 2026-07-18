{
  ast = {
    version = "2.4.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10yknjyn0728gjn6b5syynvrvrwm66bhssbxq8mkhshxghaiailm";
      type = "gem";
    };
  };

  colorize = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dy8ryhcdzgmbvj7jpa1qq3bhhk1m7a2pz6ip0m6dxh30rzj7d9h";
      type = "gem";
    };
  };

  flatito = {
    version = "0.1.1";
    dependencies = [ "colorize" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      path = ./.;
      type = "path";
    };
  };

  json = {
    version = "2.10.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01lbdaizhkxmrw4y8j3wpvsryvnvzmg0pfs56c52laq2jgdfmq1l";
      type = "gem";
    };
  };

  language_server-protocol = {
    version = "3.17.0.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0scnz2fvdczdgadvjn0j9d49118aqm3hj66qh8sd2kv6g1j65164";
      type = "gem";
    };
  };

  lint_roller = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11yc0d84hsnlvx8cpk4cbj6a4dz9pk0r1k29p0n1fz9acddq831c";
      type = "gem";
    };
  };

  minitest = {
    version = "5.25.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mn7q9yzrwinvfvkyjiz548a4rmcwbmz2fn9nyzh4j1snin6q6rr";
      type = "gem";
    };
  };

  parallel = {
    version = "1.26.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vy7sjs2pgz4i96v5yk9b7aafbffnvq7nn419fgvw55qlavsnsyq";
      type = "gem";
    };
  };

  parser = {
    version = "3.3.7.2";

    dependencies = [
      "ast"
      "racc"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pxnbysqw7qx6wq48mibi6nflpjylxd1nn38l9cl9f70dc3yj7f7";
      type = "gem";
    };
  };

  racc = {
    version = "1.8.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0byn0c9nkahsl93y9ln5bysq4j31q8xkf2ws42swighxd4lnjzsa";
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

  rake = {
    version = "13.2.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17850wcwkgi30p7yqh60960ypn7yibacjjha0av78zaxwvd3ijs6";
      type = "gem";
    };
  };

  regexp_parser = {
    version = "2.10.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qccah61pjvzyyg6mrp27w27dlv6vxlbznzipxjcswl7x3fhsvyb";
      type = "gem";
    };
  };

  rubocop = {
    version = "1.74.0";

    dependencies = [
      "json"
      "language_server-protocol"
      "lint_roller"
      "parallel"
      "parser"
      "rainbow"
      "regexp_parser"
      "rubocop-ast"
      "ruby-progressbar"
      "unicode-display_width"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16rp45aygc0djhcsc982rc3r16g3anrlh0dwb8yrc76iswsql4q6";
      type = "gem";
    };
  };

  rubocop-ast = {
    version = "1.41.0";
    dependencies = [ "parser" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03bwgjbldrxgzcskv3lz7kv2ymccbz0wp1y6wcijix236ynzkvqf";
      type = "gem";
    };
  };

  rubocop-minitest = {
    version = "0.37.1";

    dependencies = [
      "lint_roller"
      "rubocop"
      "rubocop-ast"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dhd8s819wsd6wcq30qhcjgwjnprm9njjrxwa0z1jnd86p4c5p6w";
      type = "gem";
    };
  };

  rubocop-performance = {
    version = "1.24.0";

    dependencies = [
      "lint_roller"
      "rubocop"
      "rubocop-ast"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1da08idjsdclcm9cimjbvd1jz2gm6z62fsc8mywrb0rn7vzkkgg5";
      type = "gem";
    };
  };

  rubocop-rake = {
    version = "0.7.1";

    dependencies = [
      "lint_roller"
      "rubocop"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kdfrckz1v32dy7c7bdiksjysx9l9zsda9kc6zvrsghch6vg55rp";
      type = "gem";
    };
  };

  ruby-progressbar = {
    version = "1.13.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cwvyb7j47m7wihpfaq7rc47zwwx9k4v7iqd9s1xch5nm53rrz40";
      type = "gem";
    };
  };

  unicode-display_width = {
    version = "3.1.4";
    dependencies = [ "unicode-emoji" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1has87asspm6m9wgqas8ghhhwyf2i1yqrqgrkv47xw7jq3qjmbwc";
      type = "gem";
    };
  };

  unicode-emoji = {
    version = "4.0.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ajk6rngypm3chvl6r0vwv36q1931fjqaqhjjya81rakygvlwb1c";
      type = "gem";
    };
  };
}
