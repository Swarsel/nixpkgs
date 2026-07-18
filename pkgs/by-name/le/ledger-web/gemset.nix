{
  activemodel = {
    version = "8.1.3";
    dependencies = [ "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06c23jww82grgvxw19g4bi9c957aj5hh24wzyyw4jdpg9jz5rh4h";
      type = "gem";
    };
  };

  activerecord = {
    version = "8.1.3";

    dependencies = [
      "activemodel"
      "activesupport"
      "timeout"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1avhmih54xqyj14zrv6ciw2ndpb11bmkwq0fcwm0mfk64ixvw0w0";
      type = "gem";
    };
  };

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

  csv = {
    version = "3.3.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gz7r2kazwwwyrwi95hbnhy54kwkfac5swh2gy5p5vw36fn38lbf";
      type = "gem";
    };
  };

  database_cleaner = {
    version = "2.1.0";
    dependencies = [ "database_cleaner-active_record" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kc9bp3415p1m94d54y2pjjlsx546q0w3fn65xlxlxhm7dpa5jqx";
      type = "gem";
    };
  };

  database_cleaner-active_record = {
    version = "2.2.2";

    dependencies = [
      "activerecord"
      "database_cleaner-core"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1203q6zdw14vwmnr2hw0d6b1rdz4d07w3kjg1my1zhw862gnnac8";
      type = "gem";
    };
  };

  database_cleaner-core = {
    version = "2.0.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v44bn386ipjjh4m2kl53dal8g4d41xajn2jggnmjbhn6965fil6";
      type = "gem";
    };
  };

  diff-lcs = {
    version = "1.6.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qlrj2qyysc9avzlr4zs1py3x684hqm61n4czrsk1pyllz5x5q4s";
      type = "gem";
    };
  };

  directory_watcher = {
    version = "1.5.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fwc2shba7vks262ind74y3g76qp7znjq5q8b2dvza0yidgywhcq";
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
    version = "2.19.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0n9ch455pnvl9vxs2f3j77bpdmxg5g3mn3vyr9wxa0a87raii2i1";
      type = "gem";
    };
  };

  ledger_web = {
    version = "1.5.2";

    dependencies = [
      "database_cleaner"
      "directory_watcher"
      "pg"
      "rack"
      "rspec"
      "sequel"
      "sinatra"
      "sinatra-contrib"
      "sinatra-session"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0i4vagaiyayymlr41rsy4lg2cl1r011ib0ql9dgjadfy6imb4kqh";
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

  multi_json = {
    version = "1.21.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1040lr5y2phn7avdyam6zw6ikprlmk77biw3yhclsfwfh0qnl4p6";
      type = "gem";
    };
  };

  mustermann = {
    version = "3.1.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "163i29mdcr1h0nximk3d51a1fgp7vz3sfasn8p1rjm2d4g3p0qac";
      type = "gem";
    };
  };

  pg = {
    version = "1.6.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16caca7lcz5pwl82snarqrayjj9j7abmxqw92267blhk7rbd120k";
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

  rack = {
    version = "3.2.6";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hhjy9gcp52dzij05gmidqac8g28ski5xm67prwmdqmjfcgqxmsy";
      type = "gem";
    };
  };

  rack-protection = {
    version = "4.2.1";

    dependencies = [
      "base64"
      "logger"
      "rack"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1b4bamcbpk29i7jvly3i7ayfj69yc1g03gm4s7jgamccvx12hvng";
      type = "gem";
    };
  };

  rack-session = {
    version = "2.1.2";

    dependencies = [
      "base64"
      "rack"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1s7zcxlmg88a6dam4aqbgk9xkpy6dkdfqmmcszkkliy3q3w38m2r";
      type = "gem";
    };
  };

  rspec = {
    version = "3.13.2";

    dependencies = [
      "rspec-core"
      "rspec-expectations"
      "rspec-mocks"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11q5hagj6vr694innqj4r45jrm8qcwvkxjnphqgyd66piah88qi0";
      type = "gem";
    };
  };

  rspec-core = {
    version = "3.13.6";
    dependencies = [ "rspec-support" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bcbh9yv6cs6pv299zs4bvalr8yxa51kcdd1pjl60yv625j3r0m8";
      type = "gem";
    };
  };

  rspec-expectations = {
    version = "3.13.5";

    dependencies = [
      "diff-lcs"
      "rspec-support"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dl8npj0jfpy31bxi6syc7jymyd861q277sfr6jawq2hv6hx791k";
      type = "gem";
    };
  };

  rspec-mocks = {
    version = "3.13.8";

    dependencies = [
      "diff-lcs"
      "rspec-support"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0iqxmw0knjiz5nf6pgr8ihs6cjzh89f0ppj3fqiz8cvms79x6sh8";
      type = "gem";
    };
  };

  rspec-support = {
    version = "3.13.7";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z64h5rznm2zv21vjdjshz4v0h7bxvg02yc6g7yzxakj11byah06";
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

  sequel = {
    version = "5.104.0";
    dependencies = [ "bigdecimal" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gph3g9nj4cff57z6w925nlgd8wvc0mbp7xj4mf7zah4jadq288m";
      type = "gem";
    };
  };

  sinatra = {
    version = "4.2.1";

    dependencies = [
      "logger"
      "mustermann"
      "rack"
      "rack-protection"
      "rack-session"
      "tilt"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "103h6wjpcqp3i034hi44za2v365yz7qk9s5df8lmasq43nqvkbmp";
      type = "gem";
    };
  };

  sinatra-contrib = {
    version = "4.2.1";

    dependencies = [
      "multi_json"
      "mustermann"
      "rack-protection"
      "sinatra"
      "tilt"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jkbsaika8pr9bc90ag3wqrhbgiy7h5a93k11j8sls6j8k4r3l0h";
      type = "gem";
    };
  };

  sinatra-session = {
    version = "1.0.0";
    dependencies = [ "sinatra" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "183xl8i4d2hc03afd1i52gwn2xi3vzrv02g22llhfy5wkmm44gmq";
      type = "gem";
    };
  };

  tilt = {
    version = "2.7.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cvaikq1dcbfl008i16c1pi1gmdax7vfkvmhch64jdkakyk9nnqd";
      type = "gem";
    };
  };

  timeout = {
    version = "0.6.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jxcji88mh6xsqz0mfzwnxczpg7cyniph7wpavnavfz7lxl77xbq";
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
}
