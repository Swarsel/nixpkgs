{
  activesupport = {
    version = "8.1.3";

    dependencies = [
      "base64"
      "bigdecimal"
      "concurrent-ruby"
      "connection_pool"
      "drb"
      "i18n"
      "json"
      "logger"
      "minitest"
      "securerandom"
      "tzinfo"
      "uri"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03m2vjhq3nmc8c3hpivxhvkjd8igg16nmv0p2fgdsgacppgy1991";
      type = "gem";
    };
  };

  addressable = {
    version = "2.9.0";
    dependencies = [ "public_suffix" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1by7h2lwziiblizpd5yx87jsq8ppdhzvwf08ga34wzqgcv1nmpvz";
      type = "gem";
    };
  };

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

  bigdecimal = {
    version = "4.1.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1g9zi8c4i7g8zz0c3hxrw6mblrjvgn7akys60clb9si7c1k1gljk";
      type = "gem";
    };
  };

  concurrent-ruby = {
    version = "1.3.6";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1aymcakhzl83k77g2f2krz07bg1cbafbcd2ghvwr4lky3rz86mkb";
      type = "gem";
    };
  };

  connection_pool = {
    version = "3.0.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02ifws3c4x7b54fv17sm4cca18d2pfw1saxpdji2lbd1f6xgbzrk";
      type = "gem";
    };
  };

  drb = {
    version = "2.2.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wrkl7yiix268s2md1h6wh91311w95ikd8fy8m5gx589npyxc00b";
      type = "gem";
    };
  };

  ethon = {
    version = "0.18.0";

    dependencies = [
      "ffi"
      "logger"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cpwds6mpija1bwh8p89fqa993llssvi81w5ic3cnj04yg4sz65m";
      type = "gem";
    };
  };

  ferrum = {
    version = "0.17.2";

    dependencies = [
      "addressable"
      "base64"
      "concurrent-ruby"
      "webrick"
      "websocket-driver"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vp62wy85hr5fa0d29y3wh3zaj10sszj3pl19mps84dja2l4099c";
      type = "gem";
    };
  };

  ffi = {
    version = "1.17.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kqasqvy8d7r09ri4n6bkdwbk63j7afd9ilsw34nzlgh0qp69ldw";
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

  get_process_mem = {
    version = "1.0.0";

    dependencies = [
      "bigdecimal"
      "ffi"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1amlw0v8mal01k0c8n6i5x7a8fxw44myqm81dr6nlxxzpkrj8h6m";
      type = "gem";
    };
  };

  i18n = {
    version = "1.14.8";
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1994i044vdmzzkyr76g8rpl1fq1532wf0sb21xg5r1ilj5iphmr8";
      type = "gem";
    };
  };

  json = {
    version = "2.19.8";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1anz6a6n33x4s3906s0bz6x161kk1ns3h7xxsn3rpxkfsw7k2m33";
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

  mini_portile2 = {
    version = "2.8.9";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12f2830x7pq3kj0v8nz0zjvaw02sv01bqs1zwdrc04704kwcgmqc";
      type = "gem";
    };
  };

  minitest = {
    version = "6.0.6";

    dependencies = [
      "drb"
      "prism"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wfnqyfayx9n9j7x871v2ars4hjhfisi1dl24fa64ylq3mns6ghm";
      type = "gem";
    };
  };

  nokogiri = {
    version = "1.19.3";

    dependencies = [
      "mini_portile2"
      "racc"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1s30b7h7qpyim30m8060xs415mbr3ci7i5hdg09chh1aqfx2qcbq";
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

  prism = {
    version = "1.9.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11ggfikcs1lv17nhmhqyyp6z8nq5pkfcj6a904047hljkxm0qlvv";
      type = "gem";
    };
  };

  public_suffix = {
    version = "7.0.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08znfv30pxmdkjyihvbjqbvv874dj3nybmmyscl958dy3f7v12qs";
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

  rexml = {
    version = "3.4.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hninnbvqd2pn40h863lbrn9p11gvdxp928izkag5ysx8b1s5q0r";
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

  securerandom = {
    version = "0.4.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cd0iriqfsf1z91qg271sm88xjnfd92b832z49p1nd542ka96lfc";
      type = "gem";
    };
  };

  sys-proctable = {
    version = "1.3.0";
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0m3fj6j1qpfszqnsvr6wpak0d9vw5ggylaqkalhl3m50kbbimxii";
      type = "gem";
    };
  };

  typhoeus = {
    version = "1.6.0";
    dependencies = [ "ethon" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "079k9j2alxxqn8r3vfm1anwp16v9s5f27p01k3i4g59p7v143k5s";
      type = "gem";
    };
  };

  tzinfo = {
    version = "2.0.6";
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16w2g84dzaf3z13gxyzlzbf748kylk5bdgg3n1ipvkvvqy685bwd";
      type = "gem";
    };
  };

  uri = {
    version = "1.1.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ijpbj7mdrq7rhpq2kb51yykhrs2s54wfs6sm9z3icgz4y6sb7rp";
      type = "gem";
    };
  };

  webrick = {
    version = "1.9.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ca1hr2rxrfw7s613rp4r4bxb454i3ylzniv9b9gxpklqigs3d5y";
      type = "gem";
    };
  };

  websocket-driver = {
    version = "0.8.1";

    dependencies = [
      "base64"
      "websocket-extensions"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15idgibqpdaj97f734drx8a7k1jcc8wvxlk2nbafac72ihikicjs";
      type = "gem";
    };
  };

  websocket-extensions = {
    version = "0.1.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hc2g9qps8lmhibl5baa91b4qx8wqw872rgwagml78ydj8qacsqw";
      type = "gem";
    };
  };

  wpscan = {
    version = "4.0.0";

    dependencies = [
      "activesupport"
      "addressable"
      "ethon"
      "ferrum"
      "fiddle"
      "get_process_mem"
      "nokogiri"
      "ostruct"
      "public_suffix"
      "ruby-progressbar"
      "sys-proctable"
      "typhoeus"
      "xmlrpc"
      "yajl-ruby"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17i50avb4qa4dsvbd53mdp2mklbkhirvqczvrzz17zdswm2gfy39";
      type = "gem";
    };
  };

  xmlrpc = {
    version = "0.3.4";

    dependencies = [
      "rexml"
      "webrick"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hjlvq952c80khrj084a3csawrwlshd1v3n8abv5hbpqry6y18jk";
      type = "gem";
    };
  };

  yajl-ruby = {
    version = "1.4.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lni4jbyrlph7sz8y49q84pb0sbj82lgwvnjnsiv01xf26f4v5wc";
      type = "gem";
    };
  };
}
