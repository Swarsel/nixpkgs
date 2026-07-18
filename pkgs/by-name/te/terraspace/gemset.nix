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

  aws-eventstream = {
    version = "1.3.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mvjjn8vh1c3nhibmjj9qcwxagj6m9yy961wblfqdmvhr9aklb3y";
      type = "gem";
    };
  };

  aws-partitions = {
    version = "1.1107.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0h25l48fy06yba48ymsflda93yclk0335kdcnf74f5axsah84qfn";
      type = "gem";
    };
  };

  aws-sdk-core = {
    version = "3.224.0";

    dependencies = [
      "aws-eventstream"
      "aws-partitions"
      "aws-sigv4"
      "base64"
      "jmespath"
      "logger"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1b0pi1iibp644dn78g53s7hs7gcxghfa7h8rz3lvz8ivykisl5y6";
      type = "gem";
    };
  };

  aws-sdk-kms = {
    version = "1.101.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mv8jc8sbvim2m3y3zxm8z4i5sh4x9ds7y9h5z04qfg7kjvbbn24";
      type = "gem";
    };
  };

  aws-sdk-s3 = {
    version = "1.186.1";

    dependencies = [
      "aws-sdk-core"
      "aws-sdk-kms"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00sq22mfibxq3rjy9c4vj1s8yjszv8988di7z7rs8v62my53nw2v";
      type = "gem";
    };
  };

  aws-sigv4 = {
    version = "1.11.0";
    dependencies = [ "aws-eventstream" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nx1il781qg58nwjkkdn9fw741cjjnixfsh389234qm8j5lpka2h";
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

  cli-format = {
    version = "0.6.1";

    dependencies = [
      "activesupport"
      "text-table"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rrjck5r25dlcg1gwz6pb5f4rllx77lg6a514a5l3lajfd95shm3";
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

  dotenv = {
    version = "3.1.8";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hwjsddv666wpp42bip3fqx7c5qq6s8lwf74dj71yn7d1h37c4cy";
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

  dsl_evaluator = {
    version = "0.3.2";

    dependencies = [
      "activesupport"
      "memoist"
      "rainbow"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hd079baa5pfyyc2wc9p5h82qjp7fnx0s0shn2i19ig186cizh2x";
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

  eventmachine-tail = {
    version = "0.6.5";
    dependencies = [ "eventmachine" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0x5ly7mnfr6gibjyxz6lrxb4jbf05p0r8257qcgkf8rkwg9ynw0c";
      type = "gem";
    };
  };

  graph = {
    version = "2.11.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bwssjgl9nfq9jhn9bfc7pqfl2c2xi0wnpng66l029m03kmdq8k4";
      type = "gem";
    };
  };

  hcl_parser = {
    version = "0.2.2";
    dependencies = [ "rhcl" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09d55i9y187xkw0fi0b5aq8wyzvq8w73ryi939dvzdzgss25m7jj";
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

  jmespath = {
    version = "1.6.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cdw9vw2qly7q7r41s7phnac264rbsdqgj4l0h4nqgbjb157g393";
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

  memoist = {
    version = "0.16.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0i9wpzix3sjhf6d9zw60dm4371iq8kyz7ckh2qapan2vyaim6b55";
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

  render_me_pretty = {
    version = "1.0.0";

    dependencies = [
      "activesupport"
      "rainbow"
      "tilt"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "012hbn90kwc2byqyibkadqjbhbwvz3fa8n3iw190p031f5cm75n2";
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

  rhcl = {
    version = "0.1.0";
    dependencies = [ "deep_merge" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1c7xp9y9438mnqrfrvjp1fwy2lk0b1ixz45qi2g2kbl91ilhn834";
      type = "gem";
    };
  };

  rspec = {
    version = "3.13.0";

    dependencies = [
      "rspec-core"
      "rspec-expectations"
      "rspec-mocks"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14xrp8vq6i9zx37vh0yp4h9m0anx9paw200l1r5ad9fmq559346l";
      type = "gem";
    };
  };

  rspec-core = {
    version = "3.13.3";
    dependencies = [ "rspec-support" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1r6zbis0hhbik1ck8kh58qb37d1qwij1x1d2fy4jxkzryh3na4r5";
      type = "gem";
    };
  };

  rspec-expectations = {
    version = "3.13.4";

    dependencies = [
      "diff-lcs"
      "rspec-support"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1n7cb6szws90hxbzqrfybs4rj1xb0vhn24xa4l5r1vnzcnblahsf";
      type = "gem";
    };
  };

  rspec-mocks = {
    version = "3.13.4";

    dependencies = [
      "diff-lcs"
      "rspec-support"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14xr5bq7s80hm97fcp3pvk4v515qfw3lrlsf20idalwwf6h5icbb";
      type = "gem";
    };
  };

  rspec-support = {
    version = "3.13.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hrzdcklbl8pv721cq906yfl38fmqmlnh33ff8l752z1ys9y6q9a";
      type = "gem";
    };
  };

  rspec-terraspace = {
    version = "0.3.3";

    dependencies = [
      "activesupport"
      "memoist"
      "rainbow"
      "rspec"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1q8dlamvd11d5q2p6yvq0gkm3smz42mzsva4qimim7jn2yjbh58y";
      type = "gem";
    };
  };

  rubyzip = {
    version = "2.4.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05an0wz87vkmqwcwyh5rjiaavydfn5f4q1lixcsqkphzvj7chxw5";
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

  terraspace = {
    version = "2.2.17";

    dependencies = [
      "activesupport"
      "cli-format"
      "deep_merge"
      "dotenv"
      "dsl_evaluator"
      "eventmachine-tail"
      "graph"
      "hcl_parser"
      "memoist"
      "rainbow"
      "render_me_pretty"
      "rexml"
      "rspec-terraspace"
      "terraspace-bundler"
      "thor"
      "tty-tree"
      "zeitwerk"
      "zip_folder"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zmnp71fwcj453cafmb8iicbk93flk98wh0wdk0q9xd3mgm3qh6x";
      type = "gem";
    };
  };

  terraspace-bundler = {
    version = "0.5.0";

    dependencies = [
      "activesupport"
      "aws-sdk-s3"
      "dsl_evaluator"
      "memoist"
      "nokogiri"
      "rainbow"
      "rubyzip"
      "thor"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kn6is7zqlw8l4njj4pjwbdi95w651nz3qvqgc3vw07rchs08nnx";
      type = "gem";
    };
  };

  text-table = {
    version = "1.2.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06yhlnb49fn0fhkmi6lrziyv2hd42gcm2zi3sggm2qab48qxn94j";
      type = "gem";
    };
  };

  thor = {
    version = "1.3.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nmymd86a0vb39pzj2cwv57avdrl6pl3lf5bsz58q594kqxjkw7f";
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

  tty-tree = {
    version = "0.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0w3nh9yppb7zaswa7d9hnhf6k64z5d3jd8xvpyg2mjfrzcw9rbgs";
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
    version = "1.0.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04bhfvc25b07jaiaf62yrach7khhr5jlr5bx6nygg8pf11329wp9";
      type = "gem";
    };
  };

  zeitwerk = {
    version = "2.7.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "119ypabas886gd0n9kiid3q41w76gz60s8qmiak6pljpkd56ps5j";
      type = "gem";
    };
  };

  zip_folder = {
    version = "0.1.0";
    dependencies = [ "rubyzip" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1884a1ixy7bzm9yp8cjikhdfcn8205p4fsjq894ilby8i1whl58k";
      type = "gem";
    };
  };
}
