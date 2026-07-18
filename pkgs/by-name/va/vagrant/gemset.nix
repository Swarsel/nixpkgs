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

  bcrypt_pbkdf = {
    version = "1.1.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04rb3rp9bdxn1y3qiflfpj7ccwb8ghrfbydh5vfz1l9px3fpg41g";
      type = "gem";
    };
  };

  bigdecimal = {
    version = "3.2.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06sfv80bmxfczkqi3pb3yc9zicqhf94adh5f8hpkn3bsqqd1vlgz";
      type = "gem";
    };
  };

  builder = {
    version = "3.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pw3r2lyagsxkm71bf44v5b74f7l9r7di22brbyji9fwz791hya9";
      type = "gem";
    };
  };

  childprocess = {
    version = "5.1.0";
    dependencies = [ "logger" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1v5nalaarxnfdm6rxb7q6fmc6nx097jd630ax6h9ch7xw95li3cs";
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

  diff-lcs = {
    version = "1.6.2";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qlrj2qyysc9avzlr4zs1py3x684hqm61n4czrsk1pyllz5x5q4s";
      type = "gem";
    };
  };

  ed25519 = {
    version = "1.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0zb2dr2ihb1qiknn5iaj1ha1w9p7lj9yq5waasndlfadz225ajji";
      type = "gem";
    };
  };

  erubi = {
    version = "1.13.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1naaxsqkv5b3vklab5sbb9sdpszrjzlfsbqpy7ncbnw510xi10m0";
      type = "gem";
    };
  };

  excon = {
    version = "1.3.0";
    dependencies = [ "logger" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gj6h2r9ylkmz9wjlf6p04d3hw99qfnf0wb081lzjx3alk13ngfq";
      type = "gem";
    };
  };

  fake_ftp = {
    version = "0.3.0";
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zl9q9m4x7lz9890g0h1qqj7hcxnwzpjfnfbxadjblps7b5054q4";
      type = "gem";
    };
  };

  faraday = {
    version = "2.13.4";

    dependencies = [
      "faraday-net_http"
      "json"
      "logger"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09mcghancmn0s5cwk2xz581j3xm3xqxfv0yxg75axnyhrx9gy6f7";
      type = "gem";
    };
  };

  faraday-net_http = {
    version = "3.4.1";
    dependencies = [ "net-http" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fxbckg468dabkkznv48ss8zv14d9cd8mh1rr3m98aw7wzx5fmq9";
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

  grpc-tools = {
    version = "1.75.0";
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0c994vqf1vnjvvb4np9bckj5ycxi3svf7kh6z0011vr4a7pvarym";
      type = "gem";
    };
  };

  gssapi = {
    version = "1.3.1";
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qdfhj12aq8v0y961v4xv96a1y2z80h3xhvzrs9vsfgf884g6765";
      type = "gem";
    };
  };

  gyoku = {
    version = "1.4.0";

    dependencies = [
      "builder"
      "rexml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kd2q59xpm39hpvmmvyi6g3f1fr05xjbnxwkrdqz4xy7hirqi79q";
      type = "gem";
    };
  };

  hashicorp-checkpoint = {
    version = "0.1.6";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "031lzv4v577zc4f2f918n3hgh3hsrc7rwhlpgrfa1c1f9dsfm34j";
      type = "gem";
    };
  };

  hashie = {
    version = "5.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nh3arcrbz1rc1cr59qm53sdhqm137b258y8rcb4cvd3y98lwv4x";
      type = "gem";
    };
  };

  httpclient = {
    version = "2.9.0";
    dependencies = [ "mutex_m" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1j4qwj1nv66v3n9s4xqf64x2galvjm630bwa5xngicllwic5jr2b";
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

  ipaddr = {
    version = "1.2.7";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wmgwqv6c1kq8cxbxddllnrlh5jjmjw73i1sqbnvq55zzn3l0zyb";
      type = "gem";
    };
  };

  json = {
    version = "2.14.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hj6yxpi710g1pfyg0aysahqv6dzz8y3l949q1y6kw79a7br92dh";
      type = "gem";
    };
  };

  jwt = {
    version = "3.1.2";
    dependencies = [ "base64" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dfm4bhl4fzn076igh0bmh2v1vphcrxdv6ldc46hdd3bkbqr2sdg";
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

  little-plugger = {
    version = "1.1.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1frilv82dyxnlg8k1jhrvyd73l6k17mxc5vwxx080r4x1p04gwym";
      type = "gem";
    };
  };

  log4r = {
    version = "1.1.10";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ri90q0frfmigkirqv5ihyrj59xm8pq5zcmf156cbdv4r4l2jicv";
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

  logging = {
    version = "2.4.0";

    dependencies = [
      "little-plugger"
      "multi_json"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jqcq2yxh973f3aw63nd3wxhqyhkncz3pf8v2gs3df0iqair725s";
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
    version = "3.2025.0916";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0706xids054kgngsgnywajcwydxkhnlydvy3yb202j5c8hv7h3hb";
      type = "gem";
    };
  };

  multi_json = {
    version = "1.17.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06sabsvnw0x1aqdcswc6bqrqz6705548bfd8z22jxgxfjrn1yn3n";
      type = "gem";
    };
  };

  multi_xml = {
    version = "0.7.2";
    dependencies = [ "bigdecimal" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kl7ax7zcj8czlxs6vn3kdhpnz1dwva4y5zwnavssfv193f9cyih";
      type = "gem";
    };
  };

  mutex_m = {
    version = "0.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l875dw0lk7b2ywa54l0wjcggs94vb7gs8khfw9li75n2sn09jyg";
      type = "gem";
    };
  };

  net-ftp = {
    version = "0.3.8";

    dependencies = [
      "net-protocol"
      "time"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kw7g0j35fla8438s90m72b3xr0mqnpgm910qcwrgnvyg903xmi8";
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

  net-protocol = {
    version = "0.2.2";
    dependencies = [ "timeout" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1a32l4x73hz200cm587bc29q8q9az278syw3x6fkc9d1lv5y0wxa";
      type = "gem";
    };
  };

  net-scp = {
    version = "4.1.0";
    dependencies = [ "net-ssh" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0p8s7l4pr6hkn0l6rxflsc11alwi1kfg5ysgvsq61lz5l690p6x9";
      type = "gem";
    };
  };

  net-sftp = {
    version = "4.0.0";
    dependencies = [ "net-ssh" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0r33aa2d61hv1psm0l0mm6ik3ycsnq8symv7h84kpyf2b7493fv5";
      type = "gem";
    };
  };

  net-ssh = {
    version = "7.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1w1ypxa3n6mskkwb00b489314km19l61p5h3bar6zr8cng27c80p";
      type = "gem";
    };
  };

  nori = {
    version = "2.7.1";
    dependencies = [ "bigdecimal" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qb84bbi74q0zgs09sdkq750jf2ri3lblbry0xi4g1ard4rwsrk1";
      type = "gem";
    };
  };

  oauth2 = {
    version = "2.0.17";

    dependencies = [
      "faraday"
      "jwt"
      "logger"
      "multi_xml"
      "rack"
      "snaky_hash"
      "version_gem"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dcqwwlm8afr97mg1i633yia3hzd61f0j5csrspzsvf0mfp85qf4";
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

  rack = {
    version = "3.2.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cwy1br09dh5fklwf5xna7vabns8c1229kr2v0a0s6y2brz3zbrh";
      type = "gem";
    };
  };

  rake = {
    version = "13.3.0";
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14s4jdcs1a4saam9qmzbsa2bsh85rj9zfxny5z315x3gg0nhkxcn";
      type = "gem";
    };
  };

  rake-compiler = {
    version = "1.3.0";
    dependencies = [ "rake" ];
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09s1vyfby7lqbw4jn27la4vikwjdxswzbp2wdyrjgbaddppp5hpf";
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

  rb-kqueue = {
    version = "0.2.8";
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vpq1dmmlbggfk399s7jq2rrnjp6r8774amfli75bqhjn1sk2bxg";
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

  rspec = {
    version = "3.13.1";

    dependencies = [
      "rspec-core"
      "rspec-expectations"
      "rspec-mocks"
    ];

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0h11wynaki22a40rfq3ahcs4r36jdpz9acbb3m5dkf0mm67sbydr";
      type = "gem";
    };
  };

  rspec-core = {
    version = "3.13.5";
    dependencies = [ "rspec-support" ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18sgga9zjrd5579m9rpb78l7yn9a0bjzwz51z5kiq4y6jwl6hgxb";
      type = "gem";
    };
  };

  rspec-expectations = {
    version = "3.13.5";

    dependencies = [
      "diff-lcs"
      "rspec-support"
    ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dl8npj0jfpy31bxi6syc7jymyd861q277sfr6jawq2hv6hx791k";
      type = "gem";
    };
  };

  rspec-its = {
    version = "1.3.1";

    dependencies = [
      "rspec-core"
      "rspec-expectations"
    ];

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xjikikx2sn9b7nbaza60xq7livjw9kp3a6gwbv5xz9zjd7k2164";
      type = "gem";
    };
  };

  rspec-mocks = {
    version = "3.13.5";

    dependencies = [
      "diff-lcs"
      "rspec-support"
    ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10gajm8iscl7gb8q926hyna83bw3fx2zb4sqdzjrznjs51pqlcz4";
      type = "gem";
    };
  };

  rspec-support = {
    version = "3.13.6";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cmgz34hwj5s3jwxhyl8mszs24nci12ffbrmr5jb1si74iqf739f";
      type = "gem";
    };
  };

  rubyntlm = {
    version = "0.6.5";
    dependencies = [ "base64" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x8l0d1v88m40mby4jvgal46137cv8gga2lk7zlrxqlsp41380a7";
      type = "gem";
    };
  };

  rubyzip = {
    version = "2.3.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0grps9197qyxakbpw02pda59v45lfgbgiyw48i0mq9f2bn9y6mrz";
      type = "gem";
    };
  };

  snaky_hash = {
    version = "2.0.3";

    dependencies = [
      "hashie"
      "version_gem"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mnllrwhs7psw6xxs8x5yx85k12qjfdgs8zs0bxm70bfascx58r5";
      type = "gem";
    };
  };

  thor = {
    version = "0.18.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d1g37j6sc7fkidf8rqlm3wh9zgyg3g7y8h2x1y34hmil5ywa8c3";
      type = "gem";
    };
  };

  time = {
    version = "0.4.1";
    dependencies = [ "date" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qgarmdyqypzsaanf4w9vqrd9axrcrjqilxwrfmxp954102kcpq3";
      type = "gem";
    };
  };

  timeout = {
    version = "0.4.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03p31w5ghqfsbz5mcjzvwgkw3h9lbvbknqvrdliy8pxmn9wz02cm";
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

  vagrant-spec = {
    version = "0.0.1";

    dependencies = [
      "childprocess"
      "log4r"
      "rspec"
      "thor"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      fetchSubmodules = false;
      rev = "2a5afa7512753288b4ec1e26ec13bc6479b2fabb";
      sha256 = "08l0qc7566126pqwn3cr91j5wgd2zqij8sacngr5yfsk2anl8fw0";
      type = "git";
      url = "https://github.com/hashicorp/vagrant-spec.git";
    };
  };

  vagrant_cloud = {
    version = "3.1.3";

    dependencies = [
      "excon"
      "log4r"
      "oauth2"
      "rexml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09cmp6qsc92zy4j7xlair7yz1hgr40c8nrbh93krjcplkh55zvyv";
      type = "gem";
    };
  };

  version_gem = {
    version = "1.1.9";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "195r5qylwxwqbllnpli9c2pzin0lky6h3fw912h88g2lmri0j6hc";
      type = "gem";
    };
  };

  wdm = {
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ivnnabxvr3dzvddfpd5x8d093zfd5vccns60z59jl9pdp5rsvf4";
      type = "gem";
    };
  };

  webrick = {
    version = "1.9.1";
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12d9n8hll67j737ym2zw4v23cn4vxyfkb6vyv1rzpwv6y6a3qbdl";
      type = "gem";
    };
  };

  winrm = {
    version = "2.3.9";

    dependencies = [
      "builder"
      "erubi"
      "gssapi"
      "gyoku"
      "httpclient"
      "logging"
      "nori"
      "rexml"
      "rubyntlm"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01jxpshw5kx5ha21ymaaj14vibv5bvm0dd80ccc6xl3jaxy7cszg";
      type = "gem";
    };
  };

  winrm-elevated = {
    version = "1.2.3";

    dependencies = [
      "erubi"
      "winrm"
      "winrm-fs"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lmlaii8qapn84wxdg5d82gbailracgk67d0qsnbdnffcg8kswzd";
      type = "gem";
    };
  };

  winrm-fs = {
    version = "1.3.5";

    dependencies = [
      "erubi"
      "logging"
      "rubyzip"
      "winrm"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gb91k6s1yjqw387x4w1nkpnxblq3pjdqckayl0qvz5n3ygdsb0d";
      type = "gem";
    };
  };
}
