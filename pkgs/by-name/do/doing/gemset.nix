{
  base64 = {
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01qml0yilb9basf7is2614skjp8384h2pycfx86cr8023arfj98g";
      type = "gem";
    };
  };

  chronic = {
    version = "0.10.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hrdkn4g8x7dlzxwb1rfgr8kw3bp4ywg5l4y4i9c2g5cwv62yvvn";
      type = "gem";
    };
  };

  csv = {
    version = "3.3.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kmx36jjh2sahd989vcvw74lrlv07dqc3rnxchc5sj2ywqsw3w3g";
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

  doing = {
    version = "2.1.88";

    dependencies = [
      "base64"
      "chronic"
      "csv"
      "deep_merge"
      "gli"
      "haml"
      "logger"
      "ostruct"
      "parslet"
      "plist"
      "reline"
      "safe_yaml"
      "tty-link"
      "tty-markdown"
      "tty-progressbar"
      "tty-reader"
      "tty-screen"
      "tty-which"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ssnswvwyhszc63b7mkrb7scjlh4j96z101ln1qwjlljic0h0yjp";
      type = "gem";
    };
  };

  gli = {
    version = "2.22.2";
    dependencies = [ "ostruct" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1c2x5wh3d3mz8vg5bs7c5is0zvc56j6a2b4biv5z1w5hi1n8s3jq";
      type = "gem";
    };
  };

  haml = {
    version = "5.0.4";

    dependencies = [
      "temple"
      "tilt"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1q0a9fvqh8kn6wm97fcks6qzbjd400bv8bx748w8v87m7p4klhac";
      type = "gem";
    };
  };

  io-console = {
    version = "0.8.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18pgvl7lfjpichdfh1g50rpz0zpaqrpr52ybn9liv1v9pjn9ysnd";
      type = "gem";
    };
  };

  kramdown = {
    version = "2.5.1";
    dependencies = [ "rexml" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "131nwypz8b4pq1hxs6gsz3k00i9b75y3cgpkq57vxknkv6mvdfw7";
      type = "gem";
    };
  };

  logger = {
    version = "1.6.6";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05s008w9vy7is3njblmavrbdzyrwwc1fsziffdr58w9pwqj8sqfx";
      type = "gem";
    };
  };

  ostruct = {
    version = "0.6.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05xqijcf80sza5pnlp1c8whdaay8x5dc13214ngh790zrizgp8q9";
      type = "gem";
    };
  };

  parslet = {
    version = "2.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01pnw6ymz6nynklqvqxs4bcai25kcvnd5x4id9z3vd1rbmlk0lfl";
      type = "gem";
    };
  };

  pastel = {
    version = "0.8.0";
    dependencies = [ "tty-color" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xash2gj08dfjvq4hy6l1z22s5v30fhizwgs10d6nviggpxsj7a8";
      type = "gem";
    };
  };

  plist = {
    version = "3.7.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hlaf4b3d8grxm9fqbnam5gwd55wvghl0jyzjd1hc5hirhklaynk";
      type = "gem";
    };
  };

  reline = {
    version = "0.6.0";
    dependencies = [ "io-console" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lirwlw59apc8m1wjk85y2xidiv0fkxjn6f7p84yqmmyvish6qjp";
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

  rouge = {
    version = "4.5.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pchwrkr0994v7mh054lcp0na3bk3mj2sk0dc33bn6bhxrnirj1a";
      type = "gem";
    };
  };

  safe_yaml = {
    version = "1.0.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0j7qv63p0vqcd838i2iy2f76c3dgwzkiz1d1xkg7n0pbnxj2vb56";
      type = "gem";
    };
  };

  strings = {
    version = "0.2.1";

    dependencies = [
      "strings-ansi"
      "unicode-display_width"
      "unicode_utils"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yynb0qhhhplmpzavfrrlwdnd1rh7rkwzcs4xf0mpy2wr6rr6clk";
      type = "gem";
    };
  };

  strings-ansi = {
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "120wa6yjc63b84lprglc52f40hx3fx920n4dmv14rad41rv2s9lh";
      type = "gem";
    };
  };

  temple = {
    version = "0.10.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fwia5hvc1xz9w7vprzjnsym3v9j5l9ggdvy70jixbvpcpz4acfz";
      type = "gem";
    };
  };

  tilt = {
    version = "2.6.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0szpapi229v3scrvw1pgy0vpjm7z3qlf58m1198kxn70cs278g96";
      type = "gem";
    };
  };

  tty-color = {
    version = "0.6.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0aik4kmhwwrmkysha7qibi2nyzb4c8kp42bd5vxnf8sf7b53g73g";
      type = "gem";
    };
  };

  tty-cursor = {
    version = "0.7.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0j5zw041jgkmn605ya1zc151bxgxl6v192v2i26qhxx7ws2l2lvr";
      type = "gem";
    };
  };

  tty-link = {
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rdzvkyn6z2a9fnb6glw09y4c5qp94nhzvzy20z0q98cj6235yl2";
      type = "gem";
    };
  };

  tty-markdown = {
    version = "0.7.2";

    dependencies = [
      "kramdown"
      "pastel"
      "rouge"
      "strings"
      "tty-color"
      "tty-screen"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04f599zn5rfndq4d9l0acllfpc041bzdkkz2h6x0dl18f2wivn0y";
      type = "gem";
    };
  };

  tty-progressbar = {
    version = "0.18.3";

    dependencies = [
      "strings-ansi"
      "tty-cursor"
      "tty-screen"
      "unicode-display_width"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xm5sk1sqp7v16akqpxza672qza6dbml68ah1lcajx2ywmh45fvc";
      type = "gem";
    };
  };

  tty-reader = {
    version = "0.9.0";

    dependencies = [
      "tty-cursor"
      "tty-screen"
      "wisper"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cf2k7w7d84hshg4kzrjvk9pkyc2g1m3nx2n1rpmdcf0hp4p4af6";
      type = "gem";
    };
  };

  tty-screen = {
    version = "0.8.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l4vh6g333jxm9lakilkva2gn17j6gb052626r1pdbmy2lhnb460";
      type = "gem";
    };
  };

  tty-which = {
    version = "0.5.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rpljdwlfm4qgps2xvq6306w86fm057m89j4gizcji371mgha92q";
      type = "gem";
    };
  };

  unicode-display_width = {
    version = "2.6.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nkz7fadlrdbkf37m0x7sw8bnz8r355q3vwcfb9f9md6pds9h9qj";
      type = "gem";
    };
  };

  unicode_utils = {
    version = "1.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0h1a5yvrxzlf0lxxa1ya31jcizslf774arnsd89vgdhk4g7x08mr";
      type = "gem";
    };
  };

  wisper = {
    version = "2.0.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rpsi0ziy78cj82sbyyywby4d0aw0a5q84v65qd28vqn79fbq5yf";
      type = "gem";
    };
  };
}
