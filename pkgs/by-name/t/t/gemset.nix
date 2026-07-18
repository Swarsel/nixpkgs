{
  addressable = {
    version = "2.6.0";
    dependencies = [ "public_suffix" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bcm2hchn897xjhqj9zzsxf3n9xhddymj4lsclz508f4vw3av46l";
      type = "gem";
    };
  };

  buftok = {
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rzsy1vy50v55x9z0nivf23y0r9jkmq6i130xa75pq9i8qrn1mxs";
      type = "gem";
    };
  };

  domain_name = {
    version = "0.5.20180417";
    dependencies = [ "unf" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0abdlwb64ns7ssmiqhdwgl27ly40x2l27l8hs8hn0z4kb3zd2x3v";
      type = "gem";
    };
  };

  equalizer = {
    version = "0.0.11";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kjmx3fygx8njxfrwcmn7clfhjhb6bvv3scy2lyyi0wqyi3brra4";
      type = "gem";
    };
  };

  faraday = {
    version = "0.11.0";
    dependencies = [ "multipart-post" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18p1csdivgwmshfw3mb698a3bn0yrykg30khk5qxjf6n168g91jr";
      type = "gem";
    };
  };

  geokit = {
    version = "1.13.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mvdpbx88wflqqrcrfa54a5sckvj2sqzm304p7ji3c06frbhmxw8";
      type = "gem";
    };
  };

  htmlentities = {
    version = "4.3.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nkklqsn8ir8wizzlakncfv42i32wc0w9hxp00hvdlgjr7376nhj";
      type = "gem";
    };
  };

  http = {
    version = "2.2.2";

    dependencies = [
      "addressable"
      "http-cookie"
      "http-form_data"
      "http_parser.rb"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kcd9qp8vm1rkyp7gfh8j0dbl3zpi97vz2vbhpbcsdsa7l21a59r";
      type = "gem";
    };
  };

  http-cookie = {
    version = "1.0.3";
    dependencies = [ "domain_name" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "004cgs4xg5n6byjs7qld0xhsjq3n6ydfh897myr2mibvh6fjc49g";
      type = "gem";
    };
  };

  http-form_data = {
    version = "1.0.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0j8dwwbfpf8kc0lcsqcgy29lflszd1x4d7kc0f7227892m7r6y0m";
      type = "gem";
    };
  };

  "http_parser.rb" = {
    version = "0.6.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15nidriy0v5yqfjsgsra51wmknxci2n2grliz78sf9pga3n0l7gi";
      type = "gem";
    };
  };

  launchy = {
    version = "2.4.3";
    dependencies = [ "addressable" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "190lfbiy1vwxhbgn4nl4dcbzxvm049jwc158r2x7kq3g5khjrxa2";
      type = "gem";
    };
  };

  memoizable = {
    version = "0.4.2";
    dependencies = [ "thread_safe" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v42bvghsvfpzybfazl14qhkrjvx0xlmxz0wwqc960ga1wld5x5c";
      type = "gem";
    };
  };

  multipart-post = {
    version = "2.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09k0b3cybqilk1gwrwwain95rdypixb2q9w65gd44gfzsd84xi1x";
      type = "gem";
    };
  };

  naught = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wwjx35zgbc0nplp8a866iafk4zsrbhwwz4pav5gydr2wm26nksg";
      type = "gem";
    };
  };

  oauth = {
    version = "0.5.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zszdg8q1b135z7l7crjj234k4j0m347hywp5kj6zsq7q78pw09y";
      type = "gem";
    };
  };

  public_suffix = {
    version = "3.0.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08q64b5br692dd3v0a9wq9q5dvycc6kmiqmjbdxkxbfizggsvx6l";
      type = "gem";
    };
  };

  retryable = {
    version = "2.0.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pxv5xgr08s9gv5npj7h3raxibywznrv2wcrb85ibhlhzgzcxggf";
      type = "gem";
    };
  };

  simple_oauth = {
    version = "0.3.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dw9ii6m7wckml100xhjc6vxpjcry174lbi9jz5v7ibjr3i94y8l";
      type = "gem";
    };
  };

  t = {
    version = "3.1.0";

    dependencies = [
      "geokit"
      "htmlentities"
      "launchy"
      "oauth"
      "retryable"
      "thor"
      "twitter"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qj5zqc819yiscqbyb93alxillyli5ajvrr4gzq52clgkvyap7bd";
      type = "gem";
    };
  };

  thor = {
    version = "0.20.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yhrnp9x8qcy5vc7g438amd5j9sw83ih7c30dr6g6slgw9zj3g29";
      type = "gem";
    };
  };

  thread_safe = {
    version = "0.3.6";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nmhcgq6cgz44srylra07bmaw99f5271l0dpsvl5f75m44l0gmwy";
      type = "gem";
    };
  };

  twitter = {
    version = "6.1.0";

    dependencies = [
      "addressable"
      "buftok"
      "equalizer"
      "faraday"
      "http"
      "http_parser.rb"
      "memoizable"
      "naught"
      "simple_oauth"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1l9zv0pg0q4mgcxyhzk2fj57bcs907mbargdr9l0ccnp6xi5sp8v";
      type = "gem";
    };
  };

  unf = {
    version = "0.1.4";
    dependencies = [ "unf_ext" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bh2cf73i2ffh4fcpdn9ir4mhq8zi50ik0zqa1braahzadx536a9";
      type = "gem";
    };
  };

  unf_ext = {
    version = "0.0.7.6";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ll6w64ibh81qwvjx19h8nj7mngxgffg7aigjx11klvf5k2g4nxf";
      type = "gem";
    };
  };
}
