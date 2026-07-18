{
  activesupport = {
    version = "8.0.2";

    dependencies = [
      "base64"
      "benchmark"
      "bigdecimal"
      "concurrent-ruby"
      "connection_pool"
      "drb"
      "i18n"
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
      sha256 = "0pm40y64wfc50a9sj87kxvil2102rmpdcbv82zf0r40vlgdwsrc5";
      type = "gem";
    };
  };

  addressable = {
    version = "2.8.7";
    dependencies = [ "public_suffix" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cl2qpvwiffym62z991ynks7imsm87qmgxf0yfsmlwzkgi9qcaa6";
      type = "gem";
    };
  };

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

  benchmark = {
    version = "0.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jl71qcgamm96dzyqk695j24qszhcc7liw74qc83fpjljp2gh4hg";
      type = "gem";
    };
  };

  bigdecimal = {
    version = "3.1.9";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k6qzammv9r6b2cw3siasaik18i6wjc5m0gw5nfdc6jj64h79z1g";
      type = "gem";
    };
  };

  classifier-reborn = {
    version = "2.3.0";

    dependencies = [
      "fast-stemmer"
      "matrix"
    ];

    groups = [ "default" ];

    platforms = [
      {
        engine = "maglev";
      }
      {
        engine = "mingw";
      }
      {
        engine = "mingw";
      }
      {
        engine = "mswin";
      }
      {
        engine = "rbx";
      }
      {
        engine = "ruby";
      }
    ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "077n3vs2sbl0nnvmi1mvlfpi1qkn1p5m3ac8bpacifa2vqi668z2";
      type = "gem";
    };
  };

  coderay = {
    version = "1.1.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jvxqxzply1lwp7ysn94zjhh57vc14mcshw1ygw14ib8lhc00lyw";
      type = "gem";
    };
  };

  coffee-script = {
    version = "2.4.1";

    dependencies = [
      "coffee-script-source"
      "execjs"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rc7scyk7mnpfxqv5yy4y5q1hx3i7q3ahplcp4bq2g5r24g2izl2";
      type = "gem";
    };
  };

  coffee-script-source = {
    version = "1.12.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1907v9q1zcqmmyqzhzych5l7qifgls2rlbnbhy5vzyr7i7yicaz1";
      type = "gem";
    };
  };

  colorator = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0f7wvpam948cglrciyqd798gdc6z3cfijciavd0dfixgaypmvy72";
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

  connection_pool = {
    version = "2.5.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nrhsk7b3sjqbyl1cah6ibf1kvi3v93a7wf4637d355hp614mmyg";
      type = "gem";
    };
  };

  csv = {
    version = "3.3.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kfqg0m6vqs6c67296f10cr07im5mffj90k2b5dsm51liidcsvp9";
      type = "gem";
    };
  };

  date = {
    version = "3.4.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kz6mc4b9m49iaans6cbx031j9y7ldghpi5fzsdh0n3ixwa8w9mz";
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

  em-websocket = {
    version = "0.5.3";

    dependencies = [
      "eventmachine"
      "http_parser.rb"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1a66b0kjk6jx7pai9gc7i27zd0a128gy73nmas98gjz6wjyr4spm";
      type = "gem";
    };
  };

  erb = {
    version = "5.0.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08rc8pzri3g7c85c76x84j05hkk12jvalrm2m3n97k1n7f03j13n";
      type = "gem";
    };
  };

  eventmachine = {
    version = "1.2.7";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wh9aqb0skz80fhfn66lbpr4f86ya2z5rx6gm5xlfhd05bj1ch4r";
      type = "gem";
    };
  };

  execjs = {
    version = "2.10.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03a590q16nhqvfms0lh42mp6a1i41w41qpdnf39zjbq5y3l8pjvb";
      type = "gem";
    };
  };

  faraday = {
    version = "2.13.1";

    dependencies = [
      "faraday-net_http"
      "json"
      "logger"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xbv450qj2bx0qz9l2pjrd3kc057y6bglc3na7a78zby8ssiwlyc";
      type = "gem";
    };
  };

  faraday-net_http = {
    version = "3.4.0";
    dependencies = [ "net-http" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jp5ci6g40d6i50bsywp35l97nc2fpi9a592r2cibwicdb6y9wd1";
      type = "gem";
    };
  };

  fast-stemmer = {
    version = "1.0.2";
    groups = [ "default" ];

    platforms = [
      {
        engine = "maglev";
      }
      {
        engine = "mingw";
      }
      {
        engine = "mingw";
      }
      {
        engine = "mswin";
      }
      {
        engine = "rbx";
      }
      {
        engine = "ruby";
      }
    ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0688clyk4xxh3kdb18vi089k90mca8ji5fwaknh3da5wrzcrzanh";
      type = "gem";
    };
  };

  ffi = {
    version = "1.17.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19kdyjg3kv7x0ad4xsd4swy5izsbb1vl1rpb6qqcqisr5s23awi9";
      type = "gem";
    };
  };

  forwardable-extended = {
    version = "2.6.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15zcqfxfvsnprwm8agia85x64vjzr2w0xn9vxfnxzgcv8s699v0v";
      type = "gem";
    };
  };

  gemoji = {
    version = "4.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06nw5mfscjmpap7f0bc9f2hj6zd4jy3pk1lhs6llx5my1h138i3k";
      type = "gem";
    };
  };

  google-protobuf = {
    version = "4.31.0";

    dependencies = [
      "bigdecimal"
      "rake"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14a8pv6npmv3ppp5097rladsynk8fs4w6chlcylkls6xj9ngxdjd";
      type = "gem";
    };
  };

  html-pipeline = {
    version = "2.14.3";

    dependencies = [
      "activesupport"
      "nokogiri"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "180kjksi0sdlqb0aq0bhal96ifwqm25hzb3w709ij55j51qls7ca";
      type = "gem";
    };
  };

  "http_parser.rb" = {
    version = "0.8.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gj4fmls0mf52dlr928gaq0c0cb0m3aqa9kaa6l0ikl2zbqk42as";
      type = "gem";
    };
  };

  i18n = {
    version = "1.14.7";
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03sx3ahz1v5kbqjwxj48msw3maplpp2iyzs22l4jrzrqh4zmgfnf";
      type = "gem";
    };
  };

  jekyll = {
    version = "4.4.1";

    dependencies = [
      "addressable"
      "base64"
      "colorator"
      "csv"
      "em-websocket"
      "i18n"
      "jekyll-sass-converter"
      "jekyll-watch"
      "json"
      "kramdown"
      "kramdown-parser-gfm"
      "liquid"
      "mercenary"
      "pathutil"
      "rouge"
      "safe_yaml"
      "terminal-table"
      "webrick"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1h8qpki1zcw4srnzmbba2gwajycm50w53kxq8l6vicm5azc484ac";
      type = "gem";
    };
  };

  jekyll-avatar = {
    version = "0.8.0";
    dependencies = [ "jekyll" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jzxmfcljfvjz21wls2w5mr2m5qp0mq9c80j009s4m6yq9vn4wza";
      type = "gem";
    };
  };

  jekyll-coffeescript = {
    version = "2.0.0";

    dependencies = [
      "coffee-script"
      "coffee-script-source"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17fjk0bfm0rs3myid24y2scsf5vzzza185bissjmcc44cbxp571j";
      type = "gem";
    };
  };

  jekyll-compose = {
    version = "0.12.0";
    dependencies = [ "jekyll" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ny8xps0mrmx2w0xxc9rwa15ch1wkxvdrzxiwnqramqwja566y04";
      type = "gem";
    };
  };

  jekyll-favicon = {
    version = "1.1.0";

    dependencies = [
      "jekyll"
      "mini_magick"
      "rexml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dyksm4i11n0qshd7wh6dvk8d0fc70dd32ir2dxs6igxq0gd6hi1";
      type = "gem";
    };
  };

  jekyll-feed = {
    version = "0.17.0";
    dependencies = [ "jekyll" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hzwmjrxi57x68i7jx5rxi8qlcbqcbg3di55wywrp53pr0bap6k8";
      type = "gem";
    };
  };

  jekyll-gist = {
    version = "1.5.0";
    dependencies = [ "octokit" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03wz9j6yq3552nzf4g71qrdm9pfdgbm68abml9sjjgiaan1n8ns9";
      type = "gem";
    };
  };

  jekyll-mentions = {
    version = "1.6.0";

    dependencies = [
      "html-pipeline"
      "jekyll"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1n8y67plydfmay3jn865igvgb3h6s2crk8kq7ydk3wmn9h103s1r";
      type = "gem";
    };
  };

  jekyll-paginate = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0r7bcs8fq98zldih4787zk5i9w24nz5wa26m84ssja95n3sas2l8";
      type = "gem";
    };
  };

  jekyll-polyglot = {
    version = "1.9.0";
    dependencies = [ "jekyll" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0g7z5psi72pclkq6z2spqlyabw9jj11w1al9fmb2005ik8yn0ryr";
      type = "gem";
    };
  };

  jekyll-redirect-from = {
    version = "0.16.0";
    dependencies = [ "jekyll" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nz6kd6qsa160lmjmls4zgx7fwcpp8ac07mpzy80z6zgd7jwldb6";
      type = "gem";
    };
  };

  jekyll-sass-converter = {
    version = "3.1.0";
    dependencies = [ "sass-embedded" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hr4hsir8lm8aw3yj9zi7hx2xs4k00xn9inh24642d6iy625v4l3";
      type = "gem";
    };
  };

  jekyll-seo-tag = {
    version = "2.8.0";
    dependencies = [ "jekyll" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0638mqhqynghnlnaz0xi1kvnv53wkggaq94flfzlxwandn8x2biz";
      type = "gem";
    };
  };

  jekyll-sitemap = {
    version = "1.4.0";
    dependencies = [ "jekyll" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0622rwsn5i0m5xcyzdn86l68wgydqwji03lqixdfm1f1xdfqrq0d";
      type = "gem";
    };
  };

  jekyll-watch = {
    version = "2.2.1";
    dependencies = [ "listen" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qd7hy1kl87fl7l0frw5qbn22x7ayfzlv9a5ca1m59g0ym1ysi5w";
      type = "gem";
    };
  };

  jemoji = {
    version = "0.13.0";

    dependencies = [
      "gemoji"
      "html-pipeline"
      "jekyll"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z4yabsvqdb8x1rr60yyzbaf950cyzv984n3jwwvgcmv5j73wk2x";
      type = "gem";
    };
  };

  json = {
    version = "2.12.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fr0dxwn5a7z5m3i16v66pc35wmwc6mgj9f8dg7ch2bwq42y73zw";
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

  kramdown-parser-gfm = {
    version = "1.1.0";
    dependencies = [ "kramdown" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0a8pb3v951f4x7h968rqfsa19c8arz21zw1vaj42jza22rap8fgv";
      type = "gem";
    };
  };

  kramdown-syntax-coderay = {
    version = "1.0.1";

    dependencies = [
      "coderay"
      "kramdown"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03vpfpmxcdbqyh6kxrjf5xa9qgvwqj0cfv2khz5h32fp5f5dmrda";
      type = "gem";
    };
  };

  liquid = {
    version = "4.0.4";
    groups = [ "default" ];

    platforms = [
      {
        engine = "maglev";
      }
      {
        engine = "mingw";
      }
      {
        engine = "mingw";
      }
      {
        engine = "mswin";
      }
      {
        engine = "rbx";
      }
      {
        engine = "ruby";
      }
    ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1czxv2i1gv3k7hxnrgfjb0z8khz74l4pmfwd70c7kr25l2qypksg";
      type = "gem";
    };
  };

  liquid-c = {
    version = "4.0.1";
    dependencies = [ "liquid" ];
    groups = [ "default" ];

    platforms = [
      {
        engine = "maglev";
      }
      {
        engine = "mingw";
      }
      {
        engine = "mingw";
      }
      {
        engine = "mswin";
      }
      {
        engine = "rbx";
      }
      {
        engine = "ruby";
      }
    ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07psn4z99738x2vqgl097pgdnanz0pilfp6nla405y1l802nfq7j";
      type = "gem";
    };
  };

  listen = {
    version = "3.9.0";

    dependencies = [
      "rb-fsevent"
      "rb-inotify"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rwwsmvq79qwzl6324yc53py02kbrcww35si720490z5w0j497nv";
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

  matrix = {
    version = "0.4.2";
    groups = [ "default" ];

    platforms = [
      {
        engine = "maglev";
      }
      {
        engine = "mingw";
      }
      {
        engine = "mingw";
      }
      {
        engine = "mswin";
      }
      {
        engine = "rbx";
      }
      {
        engine = "ruby";
      }
    ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1h2cgkpzkh3dd0flnnwfq6f3nl2b1zff9lvqz8xs853ssv5kq23i";
      type = "gem";
    };
  };

  mercenary = {
    version = "0.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0f2i827w4lmsizrxixsrv2ssa3gk1b7lmqh8brk8ijmdb551wnmj";
      type = "gem";
    };
  };

  mime-types = {
    version = "3.7.0";

    dependencies = [
      "logger"
      "mime-types-data"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mjyxl7c0xzyqdqa8r45hqg7jcw2prp3hkp39mdf223g4hfgdsyw";
      type = "gem";
    };
  };

  mime-types-data = {
    version = "3.2025.0520";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "042zxrr8xm9nijn7jp0qnrwns32sv5m814ifkbpil8a3kv47ixci";
      type = "gem";
    };
  };

  mini_magick = {
    version = "4.13.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nfxjpmka12ihbwd87d5k2hh7d2pv3aq95x0l2lh8gca1s72bmki";
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
    version = "5.25.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mn7q9yzrwinvfvkyjiz548a4rmcwbmz2fn9nyzh4j1snin6q6rr";
      type = "gem";
    };
  };

  net-http = {
    version = "0.6.0";
    dependencies = [ "uri" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ysrwaabhf0sn24jrp0nnp51cdv0jf688mh5i6fsz63q2c6b48cn";
      type = "gem";
    };
  };

  nokogiri = {
    version = "1.18.8";

    dependencies = [
      "mini_portile2"
      "racc"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rb306hbky6cxfyc8vrwpvl40fdapjvhsk62h08gg9wwbn3n8x4c";
      type = "gem";
    };
  };

  octokit = {
    version = "4.25.1";

    dependencies = [
      "faraday"
      "sawyer"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15lvy06h276jryxg19258b2yqaykf0567sp0n16yipywhbp94860";
      type = "gem";
    };
  };

  pathutil = {
    version = "0.16.2";
    dependencies = [ "forwardable-extended" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12fm93ljw9fbxmv2krki5k5wkvr7560qy8p4spvb9jiiaqv78fz4";
      type = "gem";
    };
  };

  psych = {
    version = "5.2.6";

    dependencies = [
      "date"
      "stringio"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vii1xc7x81hicdbp7dlllhmbw5w3jy20shj696n0vfbbnm2hhw1";
      type = "gem";
    };
  };

  public_suffix = {
    version = "6.0.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1543ap9w3ydhx39ljcd675cdz9cr948x9mp00ab8qvq6118wv9xz";
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

  rb-fsevent = {
    version = "0.11.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zmf31rnpm8553lqwibvv3kkx0v7majm1f341xbxc0bk5sbhp423";
      type = "gem";
    };
  };

  rb-inotify = {
    version = "0.11.1";
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vmy8xgahixcz6hzwy4zdcyn2y6d6ri8dqv5xccgzc1r292019x0";
      type = "gem";
    };
  };

  rdoc = {
    version = "6.14.0";

    dependencies = [
      "erb"
      "psych"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nyp5vc9nm46nc3aq58f2lackgbip4ynxmznzi1qg6qjsxcdwiic";
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
    version = "4.5.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18v8if3jix029rr3j8iwisv73facw223353n0h7avl39ibxk6hh3";
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

  sass-embedded = {
    version = "1.89.0";

    dependencies = [
      "google-protobuf"
      "rake"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0h7swk083ispcanyaq85xjzm2a7v8ig2xgslziycphkrjvj7dq4l";
      type = "gem";
    };
  };

  sawyer = {
    version = "0.9.2";

    dependencies = [
      "addressable"
      "faraday"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jks1qjbmqm8f9kvwa81vqj39avaj9wdnzc531xm29a55bb74fps";
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

  stringio = {
    version = "3.1.7";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yh78pg6lm28c3k0pfd2ipskii1fsraq46m6zjs5yc9a4k5vfy2v";
      type = "gem";
    };
  };

  terminal-table = {
    version = "3.0.2";
    dependencies = [ "unicode-display_width" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14dfmfjppmng5hwj7c5ka6qdapawm3h6k9lhn8zj001ybypvclgr";
      type = "gem";
    };
  };

  tomlrb = {
    version = "2.0.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xyl2nlfm39lklyaf0p7zj9psr60jvrlyfh26hrpk7wi4k7nlwy2";
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

  uri = {
    version = "1.0.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04bhfvc25b07jaiaf62yrach7khhr5jlr5bx6nygg8pf11329wp9";
      type = "gem";
    };
  };

  webrick = {
    version = "1.9.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12d9n8hll67j737ym2zw4v23cn4vxyfkb6vyv1rzpwv6y6a3qbdl";
      type = "gem";
    };
  };

  yajl-ruby = {
    version = "1.4.3";
    groups = [ "default" ];

    platforms = [
      {
        engine = "maglev";
      }
      {
        engine = "mingw";
      }
      {
        engine = "mingw";
      }
      {
        engine = "mswin";
      }
      {
        engine = "rbx";
      }
      {
        engine = "ruby";
      }
    ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lni4jbyrlph7sz8y49q84pb0sbj82lgwvnjnsiv01xf26f4v5wc";
      type = "gem";
    };
  };
}
