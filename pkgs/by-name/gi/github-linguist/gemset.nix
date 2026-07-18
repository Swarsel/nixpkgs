{
  addressable = {
    version = "2.8.9";
    dependencies = [ "public_suffix" ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11ali533wx91fh93xlk88gjqq8w0p7kxw09nlh41hwc9wv5ly5fc";
      type = "gem";
    };
  };

  byebug = {
    version = "13.0.0";
    dependencies = [ "reline" ];
    groups = [ "debug" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pg05blj56sxdxq9d54386y9rlvj36vl95x21x9clh8rfpz3w9nj";
      type = "gem";
    };
  };

  cgi = {
    version = "0.5.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1s8qdw1nfh3njd47q154njlfyc2llcgi4ik13vz39adqd7yclgz9";
      type = "gem";
    };
  };

  charlock_holmes = {
    version = "0.7.9";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1c1dws56r7p8y363dhyikg7205z59a3bn4amnv2y488rrq8qm7ml";
      type = "gem";
    };
  };

  coderay = {
    version = "1.1.3";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jvxqxzply1lwp7ysn94zjhh57vc14mcshw1ygw14ib8lhc00lyw";
      type = "gem";
    };
  };

  csv = {
    version = "3.3.5";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gz7r2kazwwwyrwi95hbnhy54kwkfac5swh2gy5p5vw36fn38lbf";
      type = "gem";
    };
  };

  dotenv = {
    version = "3.2.0";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17b1zr9kih0i3wb7h4yq9i8vi6hjfq07857j437a8z7a44qvhxg3";
      type = "gem";
    };
  };

  faraday = {
    version = "2.14.1";

    dependencies = [
      "faraday-net_http"
      "json"
      "logger"
    ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "077n5ss3z3ds4vj54w201kd12smai853dp9c9n7ii7g3q7nwwg54";
      type = "gem";
    };
  };

  faraday-net_http = {
    version = "3.4.2";
    dependencies = [ "net-http" ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v4hfmc7d4lrqqj2wl366rm9551gd08zkv2ppwwnjlnkc217aizi";
      type = "gem";
    };
  };

  github-linguist = {
    version = "9.5.0";

    dependencies = [
      "cgi"
      "charlock_holmes"
      "mini_mime"
      "rugged"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      path = ./.;
      type = "path";
    };
  };

  io-console = {
    version = "0.8.2";

    groups = [
      "debug"
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k0lk3pwadm2myvpg893n8jshmrf2sigrd4ki15lymy7gixaxqyn";
      type = "gem";
    };
  };

  json = {
    version = "2.19.2";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kw39sqnr0lprwsd2h0zx1ic96skhqf88i14xv7c8drcicqvvqg7";
      type = "gem";
    };
  };

  licensed = {
    version = "5.0.6";

    dependencies = [
      "csv"
      "json"
      "licensee"
      "ostruct"
      "parallel"
      "pathname-common_prefix"
      "reverse_markdown"
      "ruby-xxHash"
      "thor"
      "tomlrb"
    ];

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vz2xz4md69wn9l2073ln68mpjxycqqivkqg8bsr3i1d3q7lv4zs";
      type = "gem";
    };
  };

  licensee = {
    version = "9.18.0";

    dependencies = [
      "dotenv"
      "octokit"
      "reverse_markdown"
      "rugged"
      "thor"
    ];

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xyzk7gzi91l6xlwfvf2z0963jwd2csf987yk0ffbr5p9ycdp0ry";
      type = "gem";
    };
  };

  logger = {
    version = "1.7.0";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00q2zznygpbls8asz5knjvvj2brr3ghmqxgr83xnrdj4rk3xwvhr";
      type = "gem";
    };
  };

  method_source = {
    version = "1.1.0";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1igmc3sq9ay90f8xjvfnswd1dybj1s3fi0dwd53inwsvqk4h24qq";
      type = "gem";
    };
  };

  mini_mime = {
    version = "1.1.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vycif7pjzkr29mfk4dlqv3disc5dn0va04lkwajlpr1wkibg0c6";
      type = "gem";
    };
  };

  mini_portile2 = {
    version = "2.8.9";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12f2830x7pq3kj0v8nz0zjvaw02sv01bqs1zwdrc04704kwcgmqc";
      type = "gem";
    };
  };

  minitest = {
    version = "5.27.0";
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mbpz92ml19rcxxfjrj91gmkif9khb1xpzyw38f81rvglgw1ffrd";
      type = "gem";
    };
  };

  mocha = {
    version = "2.8.2";
    dependencies = [ "ruby2_keywords" ];
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vjfizp8yq0319dkc8yzzxr2bv5f1ki1qiknyx72prs7vclyfxqz";
      type = "gem";
    };
  };

  net-http = {
    version = "0.9.1";
    dependencies = [ "uri" ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15k96fj6qwbaiv6g52l538ass95ds1qwgynqdridz29yqrkhpfi5";
      type = "gem";
    };
  };

  nokogiri = {
    version = "1.19.2";

    dependencies = [
      "mini_portile2"
      "racc"
    ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mhp90nf3g3yy5vgjnwd34czi6rbi0p7057vgngfmmdkknsxiz9q";
      type = "gem";
    };
  };

  octokit = {
    version = "9.2.0";

    dependencies = [
      "faraday"
      "sawyer"
    ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05j3gz79gxkid3lc2balyllqik4v4swnm0rcvxz14m76bkrpz92g";
      type = "gem";
    };
  };

  ostruct = {
    version = "0.6.3";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04nrir9wdpc4izqwqbysxyly8y7hsfr4fsv69rw91lfi9d5fv8lm";
      type = "gem";
    };
  };

  parallel = {
    version = "1.27.0";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0c719bfgcszqvk9z47w2p8j2wkz5y35k48ywwas5yxbbh3hm3haa";
      type = "gem";
    };
  };

  pathname-common_prefix = {
    version = "0.0.2";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "034gjbcqrf940199k28kfqbs4dwwf4slah7l9qj0n9wk4vj8bjfk";
      type = "gem";
    };
  };

  plist = {
    version = "3.7.2";
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hlaf4b3d8grxm9fqbnam5gwd55wvghl0jyzjd1hc5hirhklaynk";
      type = "gem";
    };
  };

  pry = {
    version = "0.16.0";

    dependencies = [
      "coderay"
      "method_source"
      "reline"
    ];

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kh5nv8v74k1ccy6gc7nd04aaf1cjkbk7g8pwy2izvcqaq36jv6p";
      type = "gem";
    };
  };

  public_suffix = {
    version = "7.0.5";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08znfv30pxmdkjyihvbjqbvv874dj3nybmmyscl958dy3f7v12qs";
      type = "gem";
    };
  };

  racc = {
    version = "1.8.1";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0byn0c9nkahsl93y9ln5bysq4j31q8xkf2ws42swighxd4lnjzsa";
      type = "gem";
    };
  };

  rake = {
    version = "13.3.1";
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "175iisqb211n0qbfyqd8jz2g01q6xj038zjf4q0nm8k6kz88k7lc";
      type = "gem";
    };
  };

  rake-compiler = {
    version = "0.9.9";
    dependencies = [ "rake" ];
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1j166viy5491wawqn49fdaazwwrmkrr85c90qq92z3sdyzn8y9sa";
      type = "gem";
    };
  };

  reline = {
    version = "0.6.3";
    dependencies = [ "io-console" ];

    groups = [
      "debug"
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d8q5c4nh2g9pp758kizh8sfrvngynrjlm0i1zn3cnsnfd4v160i";
      type = "gem";
    };
  };

  reverse_markdown = {
    version = "3.0.2";
    dependencies = [ "nokogiri" ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bxqlpwnixn8x4bnna958w6m6qkdkbnd23b9j6ib3nrrrs9bp3l1";
      type = "gem";
    };
  };

  ruby-xxHash = {
    version = "0.4.0.2";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1106y8dvfsrvg7ph4kagbzsd2pbm4fsggv7amcrbrl0vxh2q6790";
      type = "gem";
    };
  };

  ruby2_keywords = {
    version = "0.0.5";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vz322p8n39hz3b4a9gkmz9y7a5jaz41zrm2ywf31dvkqm03glgz";
      type = "gem";
    };
  };

  rugged = {
    version = "1.9.0";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1b7gcf6pxg4x607bica68dbz22b4kch33yi0ils6x3c8ql9akakz";
      type = "gem";
    };
  };

  sawyer = {
    version = "0.9.3";

    dependencies = [
      "addressable"
      "faraday"
    ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hayryyz46nlkcb6j0ij0kxq6i3ryiigwfc6ccvp0108hhlij3qd";
      type = "gem";
    };
  };

  thor = {
    version = "1.5.0";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wsy88vg2mazl039392hqrcwvs5nb9kq8jhhrrclir2px1gybag3";
      type = "gem";
    };
  };

  tomlrb = {
    version = "2.0.4";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "168v339gqaly00i4zqg2ag2h10r3rl7999d0cqrrpb63gaa7fbr6";
      type = "gem";
    };
  };

  uri = {
    version = "1.1.1";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ijpbj7mdrq7rhpq2kb51yykhrs2s54wfs6sm9z3icgz4y6sb7rp";
      type = "gem";
    };
  };

  yajl-ruby = {
    version = "1.4.3";
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lni4jbyrlph7sz8y49q84pb0sbj82lgwvnjnsiv01xf26f4v5wc";
      type = "gem";
    };
  };
}
