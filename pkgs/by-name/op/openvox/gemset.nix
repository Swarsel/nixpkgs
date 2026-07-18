{
  base64 = {
    version = "0.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yx9yn47a8lkfcjmigk79fykxvr80r4m1i35q82sxzynpbm7lcr7";
      type = "gem";
    };
  };

  benchmark = {
    version = "0.4.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kicilpma5l0lwayqjb5577bm0hbjndj2gh150xz09xsgc1l1vyl";
      type = "gem";
    };
  };

  concurrent-ruby = {
    version = "1.3.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ipbrgvf0pp6zxdk5ascp6i29aybz2bx9wdrlchjmpx6mhvkwfw1";
      type = "gem";
    };
  };

  deep_merge = {
    version = "1.2.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fjn4civid68a3zxnbgyjj6krs3l30dy8b4djpg6fpzrsyix7kl3";
      type = "gem";
    };
  };

  fast_gettext = {
    version = "3.1.0";
    dependencies = [ "prime" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1i9anyxdsz3lxlg9cg2dcad1fwykz4lr45v2q3nwjp477b1q8k4w";
      type = "gem";
    };
  };

  fiddle = {
    version = "1.1.8";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vifygrkw22gcd4wzh8gc4pv6h1zpk6kll6mmprrf5174wvfxa3z";
      type = "gem";
    };
  };

  forwardable = {
    version = "1.3.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1b5g1i3xdvmxxpq4qp0z4v78ivqnazz26w110fh4cvzsdayz8zgi";
      type = "gem";
    };
  };

  getoptlong = {
    version = "0.2.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "198vy9dxyzibqdbw9jg8p2ljj9iknkyiqlyl229vz55rjxrz08zx";
      type = "gem";
    };
  };

  hocon = {
    version = "1.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "106dmzsl1bxkqw5xaif012nwwfr3k9wff32cqc77ibjngknj6477";
      type = "gem";
    };
  };

  locale = {
    version = "2.1.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "107pm4ccmla23z963kyjldgngfigvchnv85wr6m69viyxxrrjbsj";
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

  openfact = {
    version = "5.5.0";

    dependencies = [
      "base64"
      "benchmark"
      "hocon"
      "logger"
      "ostruct"
      "thor"
      "tsort"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pjghgn87hfarldbv6104n1yydlq3fsxy05rx34nrpi3z7qiwqi0";
      type = "gem";
    };
  };

  openvox = {
    version = "8.26.2";

    dependencies = [
      "base64"
      "benchmark"
      "concurrent-ruby"
      "deep_merge"
      "fast_gettext"
      "fiddle"
      "getoptlong"
      "locale"
      "openfact"
      "ostruct"
      "puppet-resource_api"
      "racc"
      "scanf"
      "semantic_puppet"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14c6bqfmmqp43z4jpv21g1m5amn3m0anyz3w6zz3v3ci0ma32b7h";
      type = "gem";
    };
  };

  ostruct = {
    version = "0.6.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04nrir9wdpc4izqwqbysxyly8y7hsfr4fsv69rw91lfi9d5fv8lm";
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

  puppet-resource_api = {
    version = "2.0.0";
    dependencies = [ "hocon" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1i6rdwkc75h4py7cx66gkc42mdg5bfwhdxw713dcpy75snszqja6";
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

  scanf = {
    version = "1.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "000vxsci3zq8m1wl7mmppj7sarznrqlm6v2x2hdfmbxcwpvvfgak";
      type = "gem";
    };
  };

  semantic_puppet = {
    version = "1.1.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15ksbizvakfx0zfdgjbh34hqnrnkjj47m4kbnsg58mpqsx45pzqm";
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

  syslog = {
    version = "0.3.0";
    dependencies = [ "logger" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "023lbh48fcn72gwyh1x52ycs1wx1bnhdajmv0qvkidmdsmxnxzjd";
      type = "gem";
    };
  };

  thor = {
    version = "1.2.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0k7j2wn14h1pl4smibasw0bp66kg626drxb59z7rzflch99cd4rg";
      type = "gem";
    };
  };

  tsort = {
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17q8h020dw73wjmql50lqw5ddsngg67jfw8ncjv476l5ys9sfl4n";
      type = "gem";
    };
  };
}
