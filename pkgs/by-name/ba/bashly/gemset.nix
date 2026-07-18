{
  bashly = {
    version = "1.2.10";

    dependencies = [
      "colsole"
      "completely"
      "filewatcher"
      "gtx"
      "logger"
      "lp"
      "mister_bin"
      "ostruct"
      "requires"
      "tty-markdown"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1dzvgrk5vqncvwi1dn7kk5gzfjcr58jmqb6cyqcspwj6mr6zp7sw";
      type = "gem";
    };
  };

  cgi = {
    version = "0.4.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rj7agrnd1a4282vg13qkpwky0379svdb2z2lc0wl8588q6ikjx3";
      type = "gem";
    };
  };

  colsole = {
    version = "1.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fvf6dz2wsvjk7q24z0dm8lajq3p2l6i5ywf3mxj683rmhwq49bg";
      type = "gem";
    };
  };

  completely = {
    version = "0.7.0";

    dependencies = [
      "colsole"
      "mister_bin"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1j3kpgmcvvs257m2zqhc3jlyrflhphcmy19lwgamv9p6xg100ak1";
      type = "gem";
    };
  };

  docopt_ng = {
    version = "0.7.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rsnl5s7k2s1gl4n4dg68ssg577kf11sl4a4l2lb2fpswj718950";
      type = "gem";
    };
  };

  erb = {
    version = "4.0.4";
    dependencies = [ "cgi" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05wpc7pn1k6jik7i57vfrj6k5lda39hrny0q3706pi05c886w4fy";
      type = "gem";
    };
  };

  filewatcher = {
    version = "2.1.0";
    dependencies = [ "module_methods" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03f9v57c5zag09mi10yjhdx7y0vv2w5wrnwzbij9hhkwh43rk077";
      type = "gem";
    };
  };

  gtx = {
    version = "0.1.1";
    dependencies = [ "erb" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1w0hbr9i6jpn9spbb13ipg2fajkwa51y56jw21ziwsddmv997274";
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

  lp = {
    version = "0.2.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ns1aza32n929w7smg1dsn4g6qlfi7k1jrvssyn35cicmwn0gyyr";
      type = "gem";
    };
  };

  mister_bin = {
    version = "0.8.1";

    dependencies = [
      "colsole"
      "docopt_ng"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zz3vpy6xrgzln2dpxgcnrq1bpzz0syl60whqc9zf8j29mayw1fy";
      type = "gem";
    };
  };

  module_methods = {
    version = "0.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1886wjscfripgzlmyvcd0jmlzwr6hxvklm2a5rm32dw5bf7bvjki";
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

  requires = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dlibxp6jfdl4favj2pgsm2pw84hhr2cdiizfs51ldkpddm50njp";
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
}
