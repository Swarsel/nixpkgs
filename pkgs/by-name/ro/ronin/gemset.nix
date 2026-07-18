{
  activemodel = {
    version = "7.2.3.1";
    dependencies = [ "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1l60a6mqx1wgp15ki1cp68djci0czgrikpydii5bd877hndqdq9r";
      type = "gem";
    };
  };

  activerecord = {
    version = "7.2.3.1";

    dependencies = [
      "activemodel"
      "activesupport"
      "timeout"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pd0f1hy6rvyanmrklqir33xq0jb2my4jajz7hc38nysfpi175dq";
      type = "gem";
    };
  };

  activesupport = {
    version = "7.2.3.1";

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
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d6bhg9cim83g8cypjd7cms45ng4p9ga69v26i3vp823d98yvsqi";
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

  async = {
    version = "2.39.0";

    dependencies = [
      "console"
      "fiber-annotation"
      "io-event"
      "metrics"
      "traces"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ah038cvb5k7vr29z5jkjhdwqpinrchglz87i1bv9fzjfc07666z";
      type = "gem";
    };
  };

  async-dns = {
    version = "1.4.1";

    dependencies = [
      "async"
      "io-endpoint"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nyz9fbbl2kmvfmc30h2qqij11rfbwjxps60xqhml94lild0shh2";
      type = "gem";
    };
  };

  async-http = {
    version = "0.95.1";

    dependencies = [
      "async"
      "async-pool"
      "io-endpoint"
      "io-stream"
      "metrics"
      "protocol-http"
      "protocol-http1"
      "protocol-http2"
      "protocol-url"
      "traces"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v3q2kn9j5vfag7b4zv2vc1i4jkrqjz1pc109df6vh04q9cd8g8c";
      type = "gem";
    };
  };

  async-io = {
    version = "1.43.2";
    dependencies = [ "async" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1isyrpbsnp00kh38jjqzk933zx48xyvpr2mzk3lsybvs885aybl9";
      type = "gem";
    };
  };

  async-pool = {
    version = "0.11.2";
    dependencies = [ "async" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vg3lwb3yhq0rad3dm00vp35vrahkbxgl4kx3d2rqkdh09xs2hqa";
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

  benchmark = {
    version = "0.5.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v1337j39w1z7x9zs4q7ag0nfv4vs4xlsjx2la0wpv8s6hig2pa6";
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

  chars = {
    version = "0.3.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bqcbk4c4vdxfmcr9hrq8ilvb7cl7s65602bgvxyqrdw2k12pl13";
      type = "gem";
    };
  };

  combinatorics = {
    version = "0.5.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bwkk3hw3ll585y4558zy8ahbc1049ylc3321sjvlhm2lvha7717";
      type = "gem";
    };
  };

  command_kit = {
    version = "0.6.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "147s9bc97k2pkh9pbzidwi4mgy47zw8djh8044f5fkzfbb7jjzz5";
      type = "gem";
    };
  };

  command_mapper = {
    version = "0.3.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08x2c5vfhljcws535mdlqfqxf3qmpgvw69hjgb6bg0k7ybddmyhn";
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

  console = {
    version = "1.34.3";

    dependencies = [
      "fiber-annotation"
      "fiber-local"
      "json"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k0dxi072mz8j72r32kkzpky825hn092hb8hdxh4rz3yd5sbv7w6";
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
    version = "3.5.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1h0db8r2v5llxdbzkzyllkfniqw9gm092qn7cbaib73v9lw0c3bm";
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

  dry-configurable = {
    version = "1.4.0";

    dependencies = [
      "dry-core"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kkk3fs22ndslgihxwm6rwr0y03rvccljmhz6vpm65q87iginpg3";
      type = "gem";
    };
  };

  dry-core = {
    version = "1.2.0";

    dependencies = [
      "concurrent-ruby"
      "logger"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18cn9s2p7cbgacy0z41h3sf9jvl75vjfmvj774apyffzi3dagi8c";
      type = "gem";
    };
  };

  dry-inflector = {
    version = "1.3.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k1dd35sqqqg2abd2g2w78m94pa3mcwvmrsjbkr3hxpn0jxw5c3z";
      type = "gem";
    };
  };

  dry-initializer = {
    version = "3.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qy4cv0j0ahabprdbp02nc3r1606jd5dp90lzqg0mp0jz6c9gm9p";
      type = "gem";
    };
  };

  dry-logic = {
    version = "1.6.0";

    dependencies = [
      "bigdecimal"
      "concurrent-ruby"
      "dry-core"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18nf8mbnhgvkw34drj7nmvpx2afmyl2nyzncn3wl3z4h1yyfsvys";
      type = "gem";
    };
  };

  dry-schema = {
    version = "1.16.0";

    dependencies = [
      "concurrent-ruby"
      "dry-configurable"
      "dry-core"
      "dry-initializer"
      "dry-logic"
      "dry-types"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09spk1wfpg0v5fi2kblxifjs14pvqka9d452hbn6dbziq2mswfnd";
      type = "gem";
    };
  };

  dry-struct = {
    version = "1.8.1";

    dependencies = [
      "dry-core"
      "dry-types"
      "ice_nine"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wc07v0qm8zbblr74w3iy2s74sxpifyfpw9b2x01a9259icnhf03";
      type = "gem";
    };
  };

  dry-types = {
    version = "1.9.1";

    dependencies = [
      "bigdecimal"
      "concurrent-ruby"
      "dry-core"
      "dry-inflector"
      "dry-logic"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0y7icwaa26ycikz6h97gwd1hji3r280n4yr2kmn5sfgqp76yxsxs";
      type = "gem";
    };
  };

  dry-validation = {
    version = "1.11.1";

    dependencies = [
      "concurrent-ruby"
      "dry-core"
      "dry-initializer"
      "dry-schema"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11c0zx0irrawi028xsljpyw8kwxzqrhf7lv6nnmch4frlashp43h";
      type = "gem";
    };
  };

  erb = {
    version = "6.0.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ncmbdjf2bwmk0jf5cxywns9zbxyfiy4h4p3pzi7yddyjhv81qrq";
      type = "gem";
    };
  };

  fake_io = {
    version = "0.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10559cnd2cqllql8ibd0zx0rvq8xk0qll5sqa4khb5963596ldmn";
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

  fiber-annotation = {
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00vcmynyvhny8n4p799rrhcx0m033hivy0s1gn30ix8rs7qsvgvs";
      type = "gem";
    };
  };

  fiber-local = {
    version = "1.1.0";
    dependencies = [ "fiber-storage" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01lz929qf3xa90vra1ai1kh059kf2c8xarfy6xbv1f8g457zk1f8";
      type = "gem";
    };
  };

  fiber-storage = {
    version = "1.0.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qa0j9qjwav9xb0n3isx0rbh0942xrfback392n6vs8bidnmp3pl";
      type = "gem";
    };
  };

  hexdump = {
    version = "1.0.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wvi685igjmi00b7pmjpxnki5gwgzxn71qxhycbivbqy9vj86jvk";
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

  ice_nine = {
    version = "0.11.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nv35qg1rps9fsis28hz2cq2fx1i96795f91q4nmkm934xynll2x";
      type = "gem";
    };
  };

  io-console = {
    version = "0.8.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k0lk3pwadm2myvpg893n8jshmrf2sigrd4ki15lymy7gixaxqyn";
      type = "gem";
    };
  };

  io-endpoint = {
    version = "0.17.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0f1kzf4d5qgqgfjh52a8pf3pii5dmav6ib0zq4wmicqnq5kggsiz";
      type = "gem";
    };
  };

  io-event = {
    version = "1.16.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "143v7rhfq2kv10nadsq9fkhf2x0jf240jgq9wmvs9510pcyxjh9b";
      type = "gem";
    };
  };

  io-stream = {
    version = "0.13.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dhnkjf59ayw5xi873a939i63d47lrlqcpphvv73xprb635vq96f";
      type = "gem";
    };
  };

  irb = {
    version = "1.18.0";

    dependencies = [
      "pp"
      "prism"
      "rdoc"
      "reline"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qs8a9vprg7s8krgq4s0pygr91hclqqyz98ik15p0m1sf2h5956y";
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

  metrics = {
    version = "0.15.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wlh0g4xmfqa41dsh4m3514q3jcvy6jx97mwn6ayj62ir6xdbpk1";
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
    version = "5.27.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mbpz92ml19rcxxfjrj91gmkif9khb1xpzyw38f81rvglgw1ffrd";
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

  net-ftp = {
    version = "0.3.9";

    dependencies = [
      "net-protocol"
      "time"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0r9vn7q6c66y4iw048qdbqviv7bankdkcziz12fzfa7lyz61fy1h";
      type = "gem";
    };
  };

  net-imap = {
    version = "0.6.4";

    dependencies = [
      "date"
      "net-protocol"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ax0f0r97jm83q462vsrcbdxprs894fyyc44v62c48ihgb39hmcs";
      type = "gem";
    };
  };

  net-pop = {
    version = "0.1.2";
    dependencies = [ "net-protocol" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wyz41jd4zpjn0v1xsf9j778qx1vfrl24yc20cpmph8k42c4x2w4";
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

  net-smtp = {
    version = "0.5.1";
    dependencies = [ "net-protocol" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dh7nzjp0fiaqq1jz90nv4nxhc2w359d7c199gmzq965cfps15pd";
      type = "gem";
    };
  };

  nio4r = {
    version = "2.7.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18fwy5yqnvgixq3cn0h63lm8jaxsjjxkmj8rhiv8wpzv9271d43c";
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

  nokogiri-diff = {
    version = "0.3.0";

    dependencies = [
      "nokogiri"
      "tdiff"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x96g7zbfiqac3h2prhaz0zz8xbryapdbxpsra3019a2q29ac3yj";
      type = "gem";
    };
  };

  nokogiri-ext = {
    version = "0.1.1";
    dependencies = [ "nokogiri" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03jgdkdmh5ny9c49l18ls9cr8rwwlff3vfawqg2s7cwzpndn7lk9";
      type = "gem";
    };
  };

  open_namespace = {
    version = "0.4.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0k7093vbkf4mgppjz2r7pk7w3gcpmmzm4a6l8q2aa1fks4bvqhxl";
      type = "gem";
    };
  };

  pagy = {
    version = "6.5.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01qsxw0686k0987yybqb2z2blrb6sxpszp8dhanbnynnkgkih91v";
      type = "gem";
    };
  };

  pp = {
    version = "0.6.3";
    dependencies = [ "prettyprint" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xlxmg86k5kifci1xvlmgw56x88dmqf04zfzn7zcr4qb8ladal99";
      type = "gem";
    };
  };

  prettyprint = {
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14zicq3plqi217w6xahv7b8f7aj5kpxv1j1w98344ix9h5ay3j9b";
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

  protocol-hpack = {
    version = "1.5.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14ddqg5mcs9ysd1hdzkm5pwil0660vrxcxsn576s3387p0wa5v3g";
      type = "gem";
    };
  };

  protocol-http = {
    version = "0.62.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fvpza7nnbyd3nfxkn5gych6diwns386g2ib9s6azh99c3sz5hg1";
      type = "gem";
    };
  };

  protocol-http1 = {
    version = "0.39.0";
    dependencies = [ "protocol-http" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1syqgaklsn9rf11xmll2s3ms7jvpd5zjng9jdb3r8pbgv963z6z4";
      type = "gem";
    };
  };

  protocol-http2 = {
    version = "0.26.0";

    dependencies = [
      "protocol-hpack"
      "protocol-http"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11kl6768hpzgvvvlpyvmr74v0jqf2vslcwngs3643cl2h3brrj5s";
      type = "gem";
    };
  };

  protocol-url = {
    version = "0.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qd9vsn9sif58swfqsyj429aynqyv6hpgbzxqrd83baidcxw1m34";
      type = "gem";
    };
  };

  psych = {
    version = "5.3.1";

    dependencies = [
      "date"
      "stringio"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0x0r3gc66abv8i4dw0x0370b5hrshjfp6kpp7wbp178cy775fypb";
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

  puma = {
    version = "6.6.1";
    dependencies = [ "nio4r" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07pajhv7pqz82kcjc6017y4d0hwz5kp746cydpx1npd79r56xddr";
      type = "gem";
    };
  };

  python-pickle = {
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nk6wylwn5l8cx4m01z41c9ib6fnf7hlki0p9srwqdm1zs0ifsjf";
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

  rack = {
    version = "2.2.23";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "175ni9qsai9x2ykwvdbd5dzfyncaxpyn6dhjxjw70iq60xz9vzm8";
      type = "gem";
    };
  };

  rack-protection = {
    version = "3.2.0";

    dependencies = [
      "base64"
      "rack"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zzvivmdb4dkscc58i3gmcyrnypynsjwp6xgc4ylarlhqmzvlx1w";
      type = "gem";
    };
  };

  rack-session = {
    version = "1.0.2";
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xhxhlsz6shh8nm44jsmd9276zcnyzii364vhcvf0k8b8bjia8d0";
      type = "gem";
    };
  };

  rack-user_agent = {
    version = "0.6.0";

    dependencies = [
      "rack"
      "woothee"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "131a7v696ddzh3aric141gdsz3nshq4s763jb5b8mdl9cbf6gj8w";
      type = "gem";
    };
  };

  rdoc = {
    version = "7.2.0";

    dependencies = [
      "erb"
      "psych"
      "tsort"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14iiyb4yi1chdzrynrk74xbhmikml3ixgdayjma3p700singfl46";
      type = "gem";
    };
  };

  redis = {
    version = "5.4.1";
    dependencies = [ "redis-client" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bpsh5dbvybsa8qnv4dg11a6f2zn4sndarf7pk4iaayjgaspbrmm";
      type = "gem";
    };
  };

  redis-client = {
    version = "0.29.0";
    dependencies = [ "connection_pool" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18xy2nd8mcb186gqd11sy3vfwkq5n85mq26v7l325jkdiwgvyr8c";
      type = "gem";
    };
  };

  redis-namespace = {
    version = "1.11.0";
    dependencies = [ "redis" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0f92i9cwlp6xj6fyn7qn4qsaqvxfw4wqvayll7gbd26qnai1l6p9";
      type = "gem";
    };
  };

  reline = {
    version = "0.6.3";
    dependencies = [ "io-console" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d8q5c4nh2g9pp758kizh8sfrvngynrjlm0i1zn3cnsnfd4v160i";
      type = "gem";
    };
  };

  robots = {
    version = "0.10.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "141gvihcr2c0dpzl3dqyh8kqc9121prfdql2iamaaw0mf9qs3njs";
      type = "gem";
    };
  };

  ronin = {
    version = "2.1.1";

    dependencies = [
      "async-io"
      "open_namespace"
      "ronin-app"
      "ronin-code-asm"
      "ronin-code-sql"
      "ronin-core"
      "ronin-db"
      "ronin-dns-proxy"
      "ronin-exploits"
      "ronin-fuzzer"
      "ronin-listener"
      "ronin-masscan"
      "ronin-nmap"
      "ronin-payloads"
      "ronin-recon"
      "ronin-repos"
      "ronin-support"
      "ronin-vulns"
      "ronin-web"
      "ronin-wordlists"
      "rouge"
      "wordlist"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zhlq8xjay0143kl6ix70daxs4cqs00vf3yhn96pifqnn9l7p4ww";
      type = "gem";
    };
  };

  ronin-app = {
    version = "0.1.0";

    dependencies = [
      "dry-schema"
      "dry-struct"
      "dry-validation"
      "pagy"
      "puma"
      "redis"
      "redis-namespace"
      "ronin-core"
      "ronin-db"
      "ronin-db-activerecord"
      "ronin-exploits"
      "ronin-masscan"
      "ronin-nmap"
      "ronin-payloads"
      "ronin-recon"
      "ronin-repos"
      "ronin-support"
      "ronin-vulns"
      "ronin-web-spider"
      "sidekiq"
      "sinatra"
      "sinatra-contrib"
      "sinatra-flash"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1d5lrc0wq8vvxcl7gp78h6yk3j3hb1rspn94w5mmk4n79xm2cy3i";
      type = "gem";
    };
  };

  ronin-code-asm = {
    version = "1.0.1";
    dependencies = [ "ruby-yasm" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01qn97lsln0izrns2bwmh980qzf02ba864y66hxkxf50nm2vcign";
      type = "gem";
    };
  };

  ronin-code-sql = {
    version = "2.1.1";
    dependencies = [ "ronin-support" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19db7ayhhyvzkdyms81brfsilkk9xccikakhwch3zy3kbmdzrr6w";
      type = "gem";
    };
  };

  ronin-core = {
    version = "0.2.1";

    dependencies = [
      "command_kit"
      "csv"
      "irb"
      "reline"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0h5zd5b4fh5rx1cn4r9n6abw1y7izr4imx2fcc6rn014w4zq1i2b";
      type = "gem";
    };
  };

  ronin-db = {
    version = "0.2.1";

    dependencies = [
      "ronin-core"
      "ronin-db-activerecord"
      "ronin-support"
      "sqlite3"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07rksw32aakr4y7j03ba12cbvvciv6snf4xql2imwa1571x7b5z3";
      type = "gem";
    };
  };

  ronin-db-activerecord = {
    version = "0.2.1";

    dependencies = [
      "activerecord"
      "uri-query_params"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10f4h6vz9axmzcnp7rrmqbkmp38z0sw8i6vvqljcnc0f0r71vzap";
      type = "gem";
    };
  };

  ronin-dns-proxy = {
    version = "0.1.0";

    dependencies = [
      "async-dns"
      "ronin-support"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0lnmbb6cc2j8id1rprjlh2jynarq682mdq42bklcp203wvvifanq";
      type = "gem";
    };
  };

  ronin-exploits = {
    version = "1.1.1";

    dependencies = [
      "csv"
      "ronin-code-sql"
      "ronin-core"
      "ronin-payloads"
      "ronin-post_ex"
      "ronin-repos"
      "ronin-support"
      "ronin-vulns"
      "uri-query_params"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1spirikck7a1adsn0lz8s9qwgjci09yah24qz58b38kqh1f4kvs2";
      type = "gem";
    };
  };

  ronin-fuzzer = {
    version = "0.2.0";

    dependencies = [
      "combinatorics"
      "ronin-core"
      "ronin-support"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ikvyy7xa1z9p4ww7fgxzn0kqv2knz1c5nb9hhk5k47j4rrlxlky";
      type = "gem";
    };
  };

  ronin-listener = {
    version = "0.1.0";

    dependencies = [
      "ronin-core"
      "ronin-listener-dns"
      "ronin-listener-http"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0iashm02jlfk1w0v9y03r595jb1v2mh4raa6mcvdz2gsjvpngd4a";
      type = "gem";
    };
  };

  ronin-listener-dns = {
    version = "0.1.0";
    dependencies = [ "async-dns" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nh990mykhjrpnzqnypgm6csrhb8xkvd1r2m7skx67jdyyh42b5w";
      type = "gem";
    };
  };

  ronin-listener-http = {
    version = "0.1.0";
    dependencies = [ "async-http" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nqg61n1ladrg9cfwb1w8l9i14020crhpxnjqhc36zwmshi28rz2";
      type = "gem";
    };
  };

  ronin-masscan = {
    version = "0.1.1";

    dependencies = [
      "csv"
      "ronin-core"
      "ronin-db"
      "ruby-masscan"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0g4vq16qqrrmdr8nsg1kyl7w7v7p61j8kk0lkjwg4i22lyz8w464";
      type = "gem";
    };
  };

  ronin-nmap = {
    version = "0.1.1";

    dependencies = [
      "csv"
      "ronin-core"
      "ronin-db"
      "ruby-nmap"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xf7hdxd3vl9lkmx4hlq75jgvv4qzk01v34fdwgxny6r684lngd4";
      type = "gem";
    };
  };

  ronin-payloads = {
    version = "0.2.1";

    dependencies = [
      "ronin-code-asm"
      "ronin-core"
      "ronin-post_ex"
      "ronin-repos"
      "ronin-support"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bzw3y3m1p743ifandylmfgdlfx8j03iv8ii5wih18gyv6h0q27x";
      type = "gem";
    };
  };

  ronin-post_ex = {
    version = "0.1.0";

    dependencies = [
      "fake_io"
      "hexdump"
      "ronin-core"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dcpnlz8niqjjm5d9z8khg53acl7xn5dgliv70svsncc3h0hx0w7";
      type = "gem";
    };
  };

  ronin-recon = {
    version = "0.1.0";

    dependencies = [
      "async-dns"
      "async-http"
      "async-io"
      "ronin-core"
      "ronin-db"
      "ronin-masscan"
      "ronin-nmap"
      "ronin-repos"
      "ronin-support"
      "ronin-web-spider"
      "thread-local"
      "wordlist"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11fqjhl3dckwz9rm9zff2kwf38026799sq6d89cnwajr6pwz6ffh";
      type = "gem";
    };
  };

  ronin-repos = {
    version = "0.2.0";
    dependencies = [ "ronin-core" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15np60qj069235gnmgsv3yy3jlj2w4ypdh5dblhxcrwq8fhawcwy";
      type = "gem";
    };
  };

  ronin-support = {
    version = "1.1.1";

    dependencies = [
      "addressable"
      "base64"
      "chars"
      "combinatorics"
      "hexdump"
      "uri-query_params"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dff85yirfzdskchzhx2vd0l39vndw76iddayii1hgwffqwmbr9f";
      type = "gem";
    };
  };

  ronin-support-web = {
    version = "0.1.1";

    dependencies = [
      "nokogiri"
      "nokogiri-ext"
      "ronin-support"
      "websocket"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09gg2zmapg9qyrsszfn0w2qsdrh7jx50hbbq77b52dqz3jxvy4qc";
      type = "gem";
    };
  };

  ronin-vulns = {
    version = "0.2.1";

    dependencies = [
      "base64"
      "ronin-core"
      "ronin-db"
      "ronin-support"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11pmxl73g6wdk702g6rz4igy207a8bq8yfm8n8hwaq8v8bw2y1rx";
      type = "gem";
    };
  };

  ronin-web = {
    version = "2.0.1";

    dependencies = [
      "nokogiri"
      "nokogiri-diff"
      "open_namespace"
      "robots"
      "ronin-core"
      "ronin-support"
      "ronin-support-web"
      "ronin-vulns"
      "ronin-web-browser"
      "ronin-web-server"
      "ronin-web-session_cookie"
      "ronin-web-spider"
      "ronin-web-user_agents"
      "wordlist"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09xdwiz33v1n6ygkz2bi564gsvrypfsg236aisrlnskwc403dx9i";
      type = "gem";
    };
  };

  ronin-web-browser = {
    version = "0.1.0";

    dependencies = [
      "ferrum"
      "ronin-support"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d0d4mw5gs3a8a0pzvnil4sbhyh84davly0q2z2h7967dxa7rfyg";
      type = "gem";
    };
  };

  ronin-web-server = {
    version = "0.1.2";

    dependencies = [
      "rack"
      "rack-user_agent"
      "ronin-support"
      "sinatra"
      "webrick"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pv018w05yx0qmxnygvr42aa7jixyjihnf1n54wh9zwqbwk110qh";
      type = "gem";
    };
  };

  ronin-web-session_cookie = {
    version = "0.1.1";

    dependencies = [
      "base64"
      "python-pickle"
      "rack-session"
      "ronin-support"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vr5wkhls77a1vpy1lnzs3wickn3x6pv42wmdv1jhxz9r9qiwigp";
      type = "gem";
    };
  };

  ronin-web-spider = {
    version = "0.2.1";

    dependencies = [
      "ronin-support"
      "spidr"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cdv1ypqa6r3hpzmdw52lfp9i32yaxcsdjr6pjys3r8phvglgg3w";
      type = "gem";
    };
  };

  ronin-web-user_agents = {
    version = "0.1.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06y0l85qn0j6lvfmj9sfvbakbfjn0m3s78aghf03gk0p837r0711";
      type = "gem";
    };
  };

  ronin-wordlists = {
    version = "0.1.0";

    dependencies = [
      "ronin-core"
      "wordlist"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09yb1dnaygq86ahhq9hhh5ddl2ylawjg68m3nz2cv43h85ax2xsa";
      type = "gem";
    };
  };

  rouge = {
    version = "3.30.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1dnfkrk8xx2m8r3r9m2p5xcq57viznyc09k7r3i4jbm758i57lx3";
      type = "gem";
    };
  };

  ruby-masscan = {
    version = "0.3.0";
    dependencies = [ "command_mapper" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "018jjdah2zyw12wcyk0qmislysb9847wisyv593r4f9m8aq5ppbi";
      type = "gem";
    };
  };

  ruby-nmap = {
    version = "1.0.3";

    dependencies = [
      "command_mapper"
      "nokogiri"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17a0qgj0sk8dyw80pnvih81027f1mnf4a1xh1vj6x48xajzvsdmy";
      type = "gem";
    };
  };

  ruby-yasm = {
    version = "0.3.1";
    dependencies = [ "command_mapper" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06gdp5d5mw7rs4qh6m2nar8yir8di0n8cqrc5ls6zpw18lsbzyfd";
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

  sidekiq = {
    version = "7.3.9";

    dependencies = [
      "base64"
      "connection_pool"
      "logger"
      "rack"
      "redis-client"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19xm4s49hq0kpfbmvhnjskzmfjjxw5d5sm7350mh12gg3lp7220i";
      type = "gem";
    };
  };

  sinatra = {
    version = "3.2.0";

    dependencies = [
      "mustermann"
      "rack"
      "rack-protection"
      "tilt"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01wq20aqk5kfggq3wagx5xr1cz0x08lg6dxbk9yhd1sf0d6pywkf";
      type = "gem";
    };
  };

  sinatra-contrib = {
    version = "3.2.0";

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
      sha256 = "1hggy6m87bam8h3hs2d7m9wnfgw0w3fzwi60jysyj8icxghsjchc";
      type = "gem";
    };
  };

  sinatra-flash = {
    version = "0.3.0";
    dependencies = [ "sinatra" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vhpyzv3nvx6rl01pgzg5a9wdarb5iccj73gvk6hv1218gd49w7y";
      type = "gem";
    };
  };

  spidr = {
    version = "0.7.2";

    dependencies = [
      "base64"
      "nokogiri"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bj2ylgc96sl8r5bhxj9zbd0m3mmiz4sj06b8xmvj8li8ws0lpqj";
      type = "gem";
    };
  };

  sqlite3 = {
    version = "1.7.3";
    dependencies = [ "mini_portile2" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "073hd24qwx9j26cqbk0jma0kiajjv9fb8swv9rnz8j4mf0ygcxzs";
      type = "gem";
    };
  };

  stringio = {
    version = "3.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1q92y9627yisykyscv0bdsrrgyaajc2qr56dwlzx7ysgigjv4z63";
      type = "gem";
    };
  };

  tdiff = {
    version = "0.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0c4kaj6yqh84rln9iixvcngyf0ghrcr9baysvdr2cjbyh19vwnv8";
      type = "gem";
    };
  };

  thread-local = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ryjgfwcsbkxph1l24x87p1yabnnbqy958s57w37iwhf3z9nid9g";
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

  time = {
    version = "0.4.2";
    dependencies = [ "date" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1arxpii25xgb3fkgqp5acyc0x6179j3qzld78lflgsdxqfcf897k";
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

  traces = {
    version = "0.18.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05722prvh34n96irnxa762wz0yj2nyrz70ab2zby3b6snjf69wc0";
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

  uri-query_params = {
    version = "0.8.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z7w39zz9pfs5zcjkk5ga6q0yadc82kn1wlhmj6f56bj0jpdnlbi";
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

  websocket = {
    version = "1.2.11";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dr78vh3ag0d1q5gfd8960g1ca9g6arjd2w54mffid8h4i7agrxp";
      type = "gem";
    };
  };

  websocket-driver = {
    version = "0.8.0";

    dependencies = [
      "base64"
      "websocket-extensions"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qj9dmkmgahmadgh88kydb7cv15w13l1fj3kk9zz28iwji5vl3gd";
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

  woothee = {
    version = "1.13.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xg31qi09swgsf46b9ba38z2jav2516bg3kg7xf1wfbzw8mpd3fc";
      type = "gem";
    };
  };

  wordlist = {
    version = "1.1.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lg0sp95ny4i62n9zw0mc87i5vdrwm4g692f0lv9wc6ad0xd5gmd";
      type = "gem";
    };
  };

  zeitwerk = {
    version = "2.7.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pbkiwwla5gldgb3saamn91058nl1sq1344l5k36xsh9ih995nnq";
      type = "gem";
    };
  };
}
