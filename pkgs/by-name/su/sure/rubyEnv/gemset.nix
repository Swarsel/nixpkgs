{
  Ascii85 = {
    version = "2.0.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nmyxpngg5rycyryhq9l9hapz1y3iqyflskyksxkqm0832a5vjqm";
      type = "gem";
    };
  };

  aasm = {
    version = "5.5.1";
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qdww6c1hnmwlcga2s9gv616mdp33nqk1gzwpbhx4lmz8fgxbmwc";
      type = "gem";
    };
  };

  actioncable = {
    version = "7.2.3.1";

    dependencies = [
      "actionpack"
      "activesupport"
      "nio4r"
      "websocket-driver"
      "zeitwerk"
    ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0g5kbrqvhwlliyrzd2bhc3kdiqm58df0x3w716bs0ygwyjil1gyk";
      type = "gem";
    };
  };

  actionmailbox = {
    version = "7.2.3.1";

    dependencies = [
      "actionpack"
      "activejob"
      "activerecord"
      "activestorage"
      "activesupport"
      "mail"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hf59r6sk0qb5va0ga549rbadcb5n1a2ry8nlkszzcksr6039rx4";
      type = "gem";
    };
  };

  actionmailer = {
    version = "7.2.3.1";

    dependencies = [
      "actionpack"
      "actionview"
      "activejob"
      "activesupport"
      "mail"
      "rails-dom-testing"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rq4aan18y6gwziabnj1q1486349k1v1i5m7ysv206pqqpavcy7m";
      type = "gem";
    };
  };

  actionpack = {
    version = "7.2.3.1";

    dependencies = [
      "actionview"
      "activesupport"
      "cgi"
      "nokogiri"
      "racc"
      "rack"
      "rack-session"
      "rack-test"
      "rails-dom-testing"
      "rails-html-sanitizer"
      "useragent"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jp4w493wvfh9246wxk7g00m1a3vmzkvs0rznq62fwvjjdzzwsmn";
      type = "gem";
    };
  };

  actiontext = {
    version = "7.2.3.1";

    dependencies = [
      "actionpack"
      "activerecord"
      "activestorage"
      "activesupport"
      "globalid"
      "nokogiri"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qs350j3zm7sd6xxn61d93mv3lx1ravbjqja12c7nd7a0zs1h52v";
      type = "gem";
    };
  };

  actionview = {
    version = "7.2.3.1";

    dependencies = [
      "activesupport"
      "builder"
      "cgi"
      "erubi"
      "rails-dom-testing"
      "rails-html-sanitizer"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z7zy6ibfpsdj9jbdm54bx3ws4dszcq7qa564jn645rr8dlbh6fy";
      type = "gem";
    };
  };

  activejob = {
    version = "7.2.3.1";

    dependencies = [
      "activesupport"
      "globalid"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1n3fiwm1x3dxwj36n9pspd2bgffyw28ys9yd36hjvf3iwdy25i0b";
      type = "gem";
    };
  };

  activemodel = {
    version = "7.2.3.1";
    dependencies = [ "activesupport" ];

    groups = [
      "default"
      "development"
    ];

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

  activerecord-import = {
    version = "2.2.0";
    dependencies = [ "activerecord" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jzs0y4dg84j14j2hmlzviw66rcz6wn1j78z7mr7a1z5jsqrkjpq";
      type = "gem";
    };
  };

  activestorage = {
    version = "7.2.3.1";

    dependencies = [
      "actionpack"
      "activejob"
      "activerecord"
      "activesupport"
      "marcel"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1azzbpfp726yigwzmj8g2jji149wisnwrgb86zix6mk25sj4w8hb";
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

    groups = [
      "default"
      "development"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d6bhg9cim83g8cypjd7cms45ng4p9ga69v26i3vp823d98yvsqi";
      type = "gem";
    };
  };

  addressable = {
    version = "2.8.7";
    dependencies = [ "public_suffix" ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cl2qpvwiffym62z991ynks7imsm87qmgxf0yfsmlwzkgi9qcaa6";
      type = "gem";
    };
  };

  aes_key_wrap = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19bn0y70qm6mfj4y1m0j3s8ggh6dvxwrwrj5vfamhdrpddsz8ddr";
      type = "gem";
    };
  };

  afm = {
    version = "1.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ia5iw9xvvy1igaxsa08vvv4b5ry9ipyr18917pi8w0y4kvddm2v";
      type = "gem";
    };
  };

  after_commit_everywhere = {
    version = "1.6.0";

    dependencies = [
      "activerecord"
      "activesupport"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05yrsh6hmzmriis6nmspy2kybp49gfflnzz5s9q31r3j26d41cy8";
      type = "gem";
    };
  };

  android_key_attestation = {
    version = "0.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02spc1sh7zsljl02v9d5rdb717b628vw2k7jkkplifyjk4db0zj6";
      type = "gem";
    };
  };

  ast = {
    version = "2.4.3";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10yknjyn0728gjn6b5syynvrvrwm66bhssbxq8mkhshxghaiailm";
      type = "gem";
    };
  };

  attr_required = {
    version = "1.0.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16fbwr6nmsn97n0a6k1nwbpyz08zpinhd6g7196lz1syndbgrszh";
      type = "gem";
    };
  };

  aws-eventstream = {
    version = "1.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fqqdqg15rgwgz3mn4pj91agd20csk9gbrhi103d20328dfghsqi";
      type = "gem";
    };
  };

  aws-partitions = {
    version = "1.1196.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0r2mqf3mi41nfa3pqm6c7gbrvd6fydvsnnfakyzqbxwq29zwyqhs";
      type = "gem";
    };
  };

  aws-sdk-core = {
    version = "3.240.0";

    dependencies = [
      "aws-eventstream"
      "aws-partitions"
      "aws-sigv4"
      "base64"
      "bigdecimal"
      "jmespath"
      "logger"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17hqin6ngvlhhb414pxlq8q95j0fndljcblp09kzbajwaa83idl6";
      type = "gem";
    };
  };

  aws-sdk-kms = {
    version = "1.118.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gbgf7xgg2hrrc51g3mpf0isba801w0r0z45mjnh45agdmcm3iy9";
      type = "gem";
    };
  };

  aws-sdk-s3 = {
    version = "1.208.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sdk-kms"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vbxg6hy0j2b931llwc0jxg1q27grbs31zdhzwjy9fki05817kiz";
      type = "gem";
    };
  };

  aws-sigv4 = {
    version = "1.12.1";
    dependencies = [ "aws-eventstream" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "003ch8qzh3mppsxch83ns0jra8d222ahxs96p9cdrl0grfazywv9";
      type = "gem";
    };
  };

  base64 = {
    version = "0.3.0";

    groups = [
      "default"
      "development"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yx9yn47a8lkfcjmigk79fykxvr80r4m1i35q82sxzynpbm7lcr7";
      type = "gem";
    };
  };

  bcrypt = {
    version = "3.1.22";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0clhya4p8lhjj7hp31inp321wgzb0b5wbwppmya5sw1dikl7400z";
      type = "gem";
    };
  };

  benchmark = {
    version = "0.5.0";

    groups = [
      "default"
      "development"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v1337j39w1z7x9zs4q7ag0nfv4vs4xlsjx2la0wpv8s6hig2pa6";
      type = "gem";
    };
  };

  benchmark-ips = {
    version = "2.14.0";
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07cvi8z4ss6nzf4jp8sp6bp54d7prh6jg56dz035jpajbnkchaxp";
      type = "gem";
    };
  };

  better_html = {
    version = "2.1.1";

    dependencies = [
      "actionview"
      "activesupport"
      "ast"
      "erubi"
      "parser"
      "smart_properties"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mdgwlc02f43svy92p0k5v1hipibpzxcdjm774lkz2j8s58kav04";
      type = "gem";
    };
  };

  bigdecimal = {
    version = "3.3.1";

    groups = [
      "default"
      "development"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0612spks81fvpv2zrrv3371lbs6mwd7w6g5zafglyk75ici1x87a";
      type = "gem";
    };
  };

  bindata = {
    version = "2.5.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0n4ymlgik3xcg94h52dzmh583ss40rl3sn0kni63v56sq8g6l62k";
      type = "gem";
    };
  };

  bindex = {
    version = "0.8.1";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0zmirr3m02p52bzq4xgksq4pn8j641rx5d4czk68pv9rqnfwq7kv";
      type = "gem";
    };
  };

  bootsnap = {
    version = "1.18.6";
    dependencies = [ "msgpack" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "003xl226y120cbq1n99805jw6w75gcz1gs941yz3h7li3qy3kqha";
      type = "gem";
    };
  };

  brakeman = {
    version = "7.1.2";
    dependencies = [ "racc" ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kkds9q66jryhlyqzwhp4kh8hcb39i05v2r4f8xd3rx221vr413b";
      type = "gem";
    };
  };

  builder = {
    version = "3.3.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pw3r2lyagsxkm71bf44v5b74f7l9r7di22brbyji9fwz791hya9";
      type = "gem";
    };
  };

  capybara = {
    version = "3.40.0";

    dependencies = [
      "addressable"
      "matrix"
      "mini_mime"
      "nokogiri"
      "rack"
      "rack-test"
      "regexp_parser"
      "xpath"
    ];

    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vxfah83j6zpw3v5hic0j70h519nvmix2hbszmjwm8cfawhagns2";
      type = "gem";
    };
  };

  cbor = {
    version = "0.5.10.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0b65lw8a5s0x7g6c4h0mfzhqn83nwaql2m2hwqii321clvvh8lfz";
      type = "gem";
    };
  };

  cgi = {
    version = "0.5.1";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1s8qdw1nfh3njd47q154njlfyc2llcgi4ik13vz39adqd7yclgz9";
      type = "gem";
    };
  };

  childprocess = {
    version = "5.1.0";
    dependencies = [ "logger" ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1v5nalaarxnfdm6rxb7q6fmc6nx097jd630ax6h9ch7xw95li3cs";
      type = "gem";
    };
  };

  chunky_png = {
    version = "1.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1znw5x86hmm9vfhidwdsijz8m38pqgmv98l9ryilvky0aldv7mc9";
      type = "gem";
    };
  };

  climate_control = {
    version = "1.2.0";
    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "198aswdyqlvcw9jkd95b7b8dp3fg0wx89kd1dx9wia1z36b1icin";
      type = "gem";
    };
  };

  concurrent-ruby = {
    version = "1.3.6";

    groups = [
      "default"
      "development"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1aymcakhzl83k77g2f2krz07bg1cbafbcd2ghvwr4lky3rz86mkb";
      type = "gem";
    };
  };

  connection_pool = {
    version = "2.5.5";

    groups = [
      "default"
      "development"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1b8nlxr5z843ii7hfk6igpr5acw3k2ih9yjrgkyz2gbmallgjkz5";
      type = "gem";
    };
  };

  cose = {
    version = "1.3.1";

    dependencies = [
      "cbor"
      "openssl-signature_algorithm"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rbdzl9n8ppyp38y75hw06s17kp922ybj6jfvhz52p83dg6xpm6m";
      type = "gem";
    };
  };

  countries = {
    version = "8.0.3";
    dependencies = [ "unaccent" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05ikz4808250qivpxh99sqmkhpyx192qp1likhjcd9sh825hfrb1";
      type = "gem";
    };
  };

  crack = {
    version = "1.0.0";

    dependencies = [
      "bigdecimal"
      "rexml"
    ];

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jaa7is4fw1cxigm8vlyhg05bw4nqy4f91zjqxk7pp4c8bdyyfn8";
      type = "gem";
    };
  };

  crass = {
    version = "1.0.6";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pfl5c0pyqaparxaqxi6s4gfl21bdldwiawrc0aknyvflli60lfw";
      type = "gem";
    };
  };

  cronex = {
    version = "0.15.0";

    dependencies = [
      "tzinfo"
      "unicode"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11i1psgzcqzj4a7p62vy56i5p8s00d29y9rf9wf9blpshph99ir1";
      type = "gem";
    };
  };

  css_parser = {
    version = "1.21.1";
    dependencies = [ "addressable" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1izp5vna86s7xivqzml4nviy01bv76arrd5is8wkncwp1by3zzbc";
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

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kz6mc4b9m49iaans6cbx031j9y7ldghpi5fzsdh0n3ixwa8w9mz";
      type = "gem";
    };
  };

  debug = {
    version = "1.11.0";

    dependencies = [
      "irb"
      "reline"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wmfy5n5v2rzpr5vz698sqfj1gl596bxrqw44sahq4x0rxjdn98l";
      type = "gem";
    };
  };

  declarative = {
    version = "0.0.20";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yczgnqrbls7shrg63y88g7wand2yp9h6sf56c9bdcksn5nds8c0";
      type = "gem";
    };
  };

  derailed_benchmarks = {
    version = "2.2.1";

    dependencies = [
      "base64"
      "benchmark-ips"
      "bigdecimal"
      "drb"
      "get_process_mem"
      "heapy"
      "logger"
      "memory_profiler"
      "mini_histogram"
      "mutex_m"
      "ostruct"
      "rack"
      "rack-test"
      "rake"
      "ruby-statistics"
      "ruby2_keywords"
      "thor"
    ];

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fa4bl6afnqqq55fp45bmwin02dgrw7zq9zwv2f1rm6y9xk80hk5";
      type = "gem";
    };
  };

  diff-lcs = {
    version = "1.6.2";

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qlrj2qyysc9avzlr4zs1py3x684hqm61n4czrsk1pyllz5x5q4s";
      type = "gem";
    };
  };

  digest-crc = {
    version = "0.7.0";
    dependencies = [ "rake" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01wcsyhaadss4zzvqh12kvbq3hmkl5y4fck7pr608hd24qxc5bb4";
      type = "gem";
    };
  };

  docile = {
    version = "1.4.1";

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07pj4z3h8wk4fgdn6s62vw1lwvhj0ac0x10vfbdkr9xzk7krn5cn";
      type = "gem";
    };
  };

  doorkeeper = {
    version = "5.8.2";
    dependencies = [ "railties" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lsh9lzrglqlwm9icmn0ggrwjc9iy9308f9m59z1w2srmyp0fgd7";
      type = "gem";
    };
  };

  dotenv = {
    version = "3.1.8";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hwjsddv666wpp42bip3fqx7c5qq6s8lwf74dj71yn7d1h37c4cy";
      type = "gem";
    };
  };

  dotenv-rails = {
    version = "3.1.8";

    dependencies = [
      "dotenv"
      "railties"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1i40g6kzwp8yxsxzpzgsq2hww9gxryl5lck1bwxshn4bd8id3ja6";
      type = "gem";
    };
  };

  drb = {
    version = "2.2.3";

    groups = [
      "default"
      "development"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wrkl7yiix268s2md1h6wh91311w95ikd8fy8m5gx589npyxc00b";
      type = "gem";
    };
  };

  ed25519 = {
    version = "1.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01n5rbyws1ijwc5dw7s88xx3zzacxx9k97qn8x11b6k8k18pzs8n";
      type = "gem";
    };
  };

  email_validator = {
    version = "2.2.4";
    dependencies = [ "activemodel" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0106y8xakq6frv2xc68zz76q2l2cqvhfjc7ji69yyypcbc4kicjs";
      type = "gem";
    };
  };

  erb = {
    version = "5.0.1";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08rc8pzri3g7c85c76x84j05hkk12jvalrm2m3n97k1n7f03j13n";
      type = "gem";
    };
  };

  erb_lint = {
    version = "0.9.0";

    dependencies = [
      "activesupport"
      "better_html"
      "parser"
      "rainbow"
      "rubocop"
      "smart_properties"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cbwr8iv6d9g50w12a7ccvcrqk5clz4mxa3cspqd3s1rv05f9dfz";
      type = "gem";
    };
  };

  erubi = {
    version = "1.13.1";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1naaxsqkv5b3vklab5sbb9sdpszrjzlfsbqpy7ncbnw510xi10m0";
      type = "gem";
    };
  };

  et-orbi = {
    version = "1.2.11";
    dependencies = [ "tzinfo" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0r6zylqjfv0xhdxvldr0kgmnglm57nm506pcm6085f0xqa68cvnj";
      type = "gem";
    };
  };

  event_stream_parser = {
    version = "1.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1j73glgif3f97q3znq9ih67h5i7zd1wqzj2d33w8cqhjf2mkns52";
      type = "gem";
    };
  };

  faker = {
    version = "3.5.2";
    dependencies = [ "i18n" ];
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wy4i4vl3h2v6scffx0zbp74vq1gfgq55m8x3n05kwp3na8h5a7r";
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

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "077n5ss3z3ds4vj54w201kd12smai853dp9c9n7ii7g3q7nwwg54";
      type = "gem";
    };
  };

  faraday-follow_redirects = {
    version = "0.3.0";
    dependencies = [ "faraday" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1y87p3yk15bjbk0z9mf01r50lzxvp7agr56lbm9gxiz26mb9fbfr";
      type = "gem";
    };
  };

  faraday-multipart = {
    version = "1.1.1";
    dependencies = [ "multipart-post" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00w9imp55hi81q0wsgwak90ldkk7gbyb8nzmmv8hy0s907s8z8bp";
      type = "gem";
    };
  };

  faraday-net_http = {
    version = "3.4.2";
    dependencies = [ "net-http" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v4hfmc7d4lrqqj2wl366rm9551gd08zkv2ppwwnjlnkc217aizi";
      type = "gem";
    };
  };

  faraday-retry = {
    version = "2.3.2";
    dependencies = [ "faraday" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1laici6jximrz3a8rkm8qmwdmw3fgzk22qh4l8wd5srjj01d40i4";
      type = "gem";
    };
  };

  ffi = {
    version = "1.17.2";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19kdyjg3kv7x0ad4xsd4swy5izsbb1vl1rpb6qqcqisr5s23awi9";
      type = "gem";
    };
  };

  foreman = {
    version = "0.88.1";
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02m0iq43hrb99hca9ng834sx2p8zfc5xga1xwqn8lckabc925h2r";
      type = "gem";
    };
  };

  fugit = {
    version = "1.11.1";

    dependencies = [
      "et-orbi"
      "raabro"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0s4qhq3mjl0gak5wl20w9d5jhq069mk1393dkj76s8i2pvkqb578";
      type = "gem";
    };
  };

  get_process_mem = {
    version = "1.0.0";

    dependencies = [
      "bigdecimal"
      "ffi"
    ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1amlw0v8mal01k0c8n6i5x7a8fxw44myqm81dr6nlxxzpkrj8h6m";
      type = "gem";
    };
  };

  globalid = {
    version = "1.3.0";
    dependencies = [ "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04gzhqvsm4z4l12r9dkac9a75ah45w186ydhl0i4andldsnkkih5";
      type = "gem";
    };
  };

  google-apis-core = {
    version = "1.0.2";

    dependencies = [
      "addressable"
      "faraday"
      "faraday-follow_redirects"
      "googleauth"
      "mini_mime"
      "representable"
      "retriable"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0a961x3jq0wskwgb8ym83viza05bcvsqiny8gg6dc0n9mnm7jids";
      type = "gem";
    };
  };

  google-apis-iamcredentials_v1 = {
    version = "0.26.0";
    dependencies = [ "google-apis-core" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18s8kshls6amld400434xgmgssn2y9fpqnz9ahjxzkfnl480mxrz";
      type = "gem";
    };
  };

  google-apis-storage_v1 = {
    version = "0.61.0";
    dependencies = [ "google-apis-core" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1s42r7hmf2wl8l0wdc7z07qvmgbdilwjb58q7i9h2slfnncyac5k";
      type = "gem";
    };
  };

  google-cloud-core = {
    version = "1.8.0";

    dependencies = [
      "google-cloud-env"
      "google-cloud-errors"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kw10897ardky1chwwsb8milygzcdi8qlqlhcnqwmkw9y75yswp5";
      type = "gem";
    };
  };

  google-cloud-env = {
    version = "2.3.1";

    dependencies = [
      "base64"
      "faraday"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rvqj6n6qhjmjy0lynpmga7ly48s7dk36i6nj4jqrrvvn8gc1ahg";
      type = "gem";
    };
  };

  google-cloud-errors = {
    version = "1.6.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18fh8xvflhhksibcn1v4gnrn6d3xs284ng1fsfwh9b86sxnlga0x";
      type = "gem";
    };
  };

  google-cloud-storage = {
    version = "1.59.0";

    dependencies = [
      "addressable"
      "digest-crc"
      "google-apis-core"
      "google-apis-iamcredentials_v1"
      "google-apis-storage_v1"
      "google-cloud-core"
      "googleauth"
      "mini_mime"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fc6n7227l3b0b14c0gbfqjibn3zw1mivfvrnb66apbp3mkabjdq";
      type = "gem";
    };
  };

  google-logging-utils = {
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yyzlgy9hx104xhrbl51ana0dl3m5p5989j4lcjsizssxas64m37";
      type = "gem";
    };
  };

  googleauth = {
    version = "1.16.2";

    dependencies = [
      "faraday"
      "google-cloud-env"
      "google-logging-utils"
      "jwt"
      "multi_json"
      "os"
      "signet"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0f56614nd955cxwy98c2d1zk4zg263r1iafd90czg2p3w819a00m";
      type = "gem";
    };
  };

  hashdiff = {
    version = "1.2.0";

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1da0w5v7ppxrgvh58bafjklzv73nknyq73if6d9rkz2v24zg3169";
      type = "gem";
    };
  };

  hashery = {
    version = "2.1.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qj8815bf7q6q7llm5rzdz279gzmpqmqqicxnzv066a020iwqffj";
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

  heapy = {
    version = "0.2.0";
    dependencies = [ "thor" ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1sl56ma851i82g3ax08igbn48igriiy152xzx30wgzv1bn21w53l";
      type = "gem";
    };
  };

  highline = {
    version = "3.1.2";
    dependencies = [ "reline" ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jmvyhjp2v3iq47la7w6psrxbprnbnmzz0hxxski3vzn356x7jv7";
      type = "gem";
    };
  };

  hotwire-livereload = {
    version = "2.0.0";

    dependencies = [
      "actioncable"
      "listen"
      "railties"
    ];

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15kwskrvfpgpcas4yaivlk9b2h8fg9b67wnn3bkci39gz41wdgcf";
      type = "gem";
    };
  };

  hotwire_combobox = {
    version = "0.4.0";

    dependencies = [
      "platform_agent"
      "rails"
      "stimulus-rails"
      "turbo-rails"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1llclnxms2ihvvwf43a38ayglr3bc4nx5vhp5lgm91h67cpf1jly";
      type = "gem";
    };
  };

  htmlbeautifier = {
    version = "1.4.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nrqvgja3pbmz4v27zc5ir58sk4mv177nq7hlssy2smawbvhhgdl";
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

  httparty = {
    version = "0.24.0";

    dependencies = [
      "csv"
      "mini_mime"
      "multi_xml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1b5h8d8ygq0qradp7yr3wxd4wf9q78972pjlggvpscicv71yx4yd";
      type = "gem";
    };
  };

  i18n = {
    version = "1.14.8";
    dependencies = [ "concurrent-ruby" ];

    groups = [
      "default"
      "development"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1994i044vdmzzkyr76g8rpl1fq1532wf0sb21xg5r1ilj5iphmr8";
      type = "gem";
    };
  };

  i18n-tasks = {
    version = "1.0.15";

    dependencies = [
      "activesupport"
      "ast"
      "erubi"
      "highline"
      "i18n"
      "parser"
      "rails-i18n"
      "rainbow"
      "ruby-progressbar"
      "terminal-table"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mpvpppwkzxal9k91lifafkwg676kqkg8ng6b1y7apfvwbhfkwvl";
      type = "gem";
    };
  };

  image_processing = {
    version = "1.14.0";

    dependencies = [
      "mini_magick"
      "ruby-vips"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ys28w0ayq3vl2sl4lpq6jnsy7gd4p9vzimyi449hqn2r5lw2k3m";
      type = "gem";
    };
  };

  importmap-rails = {
    version = "2.1.0";

    dependencies = [
      "actionpack"
      "activesupport"
      "railties"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hg7m97pgssa6w0q6myvsp2i3wrx0c6i0j7lg5sm86k5c1ywc44z";
      type = "gem";
    };
  };

  inline_svg = {
    version = "1.10.0";

    dependencies = [
      "activesupport"
      "nokogiri"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03x1z55sh7cpb63g46cbd6135jmp13idcgqzqsnzinbg4cs2jrav";
      type = "gem";
    };
  };

  io-console = {
    version = "0.8.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18pgvl7lfjpichdfh1g50rpz0zpaqrpr52ybn9liv1v9pjn9ysnd";
      type = "gem";
    };
  };

  irb = {
    version = "1.15.2";

    dependencies = [
      "pp"
      "rdoc"
      "reline"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fpxa2m83rb7xlzs57daqwnzqjmz6j35xr7zb15s73975sak4br2";
      type = "gem";
    };
  };

  jbuilder = {
    version = "2.13.0";

    dependencies = [
      "actionview"
      "activesupport"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mi7s8kida8rg754bzgiik2mpdwx55x7wxd9ny0sm0803j5a603j";
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

  json = {
    version = "2.19.2";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kw39sqnr0lprwsd2h0zx1ic96skhqf88i14xv7c8drcicqvvqg7";
      type = "gem";
    };
  };

  json-jwt = {
    version = "1.16.7";

    dependencies = [
      "activesupport"
      "aes_key_wrap"
      "base64"
      "bindata"
      "faraday"
      "faraday-follow_redirects"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19bjs404inbydn40nampk5ij7vqkwpmqp3hp4dmjf50sdm6gzayc";
      type = "gem";
    };
  };

  json-schema = {
    version = "5.2.2";

    dependencies = [
      "addressable"
      "bigdecimal"
    ];

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ma0k5889hzydba2ci8lqg87pxsh9zabz7jchm9cbacwsw7axgk0";
      type = "gem";
    };
  };

  jwt = {
    version = "2.10.2";
    dependencies = [ "base64" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x64l31nkqjwfv51s2vsm0yqq4cwzrlnji12wvaq761myx3fxq9i";
      type = "gem";
    };
  };

  langfuse-ruby = {
    version = "0.1.4";

    dependencies = [
      "concurrent-ruby"
      "faraday"
      "faraday-net_http"
      "json"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wbzzajgs2qbldzn2a9ngb59q4nfzhfs2r9lq9818xpi5cs0lkd2";
      type = "gem";
    };
  };

  language_server-protocol = {
    version = "3.17.0.5";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k0311vah76kg5m6zr7wmkwyk5p2f9d9hyckjpn3xgr83ajkj7px";
      type = "gem";
    };
  };

  launchy = {
    version = "3.1.1";

    dependencies = [
      "addressable"
      "childprocess"
      "logger"
    ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17h522xhwi5m4n6n9m22kw8z0vy8100sz5f3wbfqj5cnrjslgf3j";
      type = "gem";
    };
  };

  letter_opener = {
    version = "1.10.0";
    dependencies = [ "launchy" ];
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cnv3ggnzyagl50vzs1693aacv08bhwlprcvjp8jcg2w7cp3zwrg";
      type = "gem";
    };
  };

  lint_roller = {
    version = "1.1.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11yc0d84hsnlvx8cpk4cbj6a4dz9pk0r1k29p0n1fz9acddq831c";
      type = "gem";
    };
  };

  listen = {
    version = "3.9.0";

    dependencies = [
      "rb-fsevent"
      "rb-inotify"
    ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rwwsmvq79qwzl6324yc53py02kbrcww35si720490z5w0j497nv";
      type = "gem";
    };
  };

  logger = {
    version = "1.7.0";

    groups = [
      "default"
      "development"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00q2zznygpbls8asz5knjvvj2brr3ghmqxgr83xnrdj4rk3xwvhr";
      type = "gem";
    };
  };

  logtail = {
    version = "0.1.17";
    dependencies = [ "msgpack" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0j1sa8nynck11ifmc3v9h1ry0yj9l1a608wf132d1csk0ilhavc6";
      type = "gem";
    };
  };

  logtail-rack = {
    version = "0.2.6";

    dependencies = [
      "logtail"
      "rack"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13c02xvdi3kv3zar556yhr36x05yb2rvn5l537zgfg6lxx0r95d7";
      type = "gem";
    };
  };

  logtail-rails = {
    version = "0.2.10";

    dependencies = [
      "actionpack"
      "activerecord"
      "logtail"
      "logtail-rack"
      "railties"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0n759gbizqjvzcmrv501i40y582ybxg7fagpdds8qay8vv7wwm9s";
      type = "gem";
    };
  };

  loofah = {
    version = "2.25.1";

    dependencies = [
      "crass"
      "nokogiri"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "011fdngxzr1p9dq2hxqz7qq1glj2g44xnhaadjqlf48cplywfdnl";
      type = "gem";
    };
  };

  lookbook = {
    version = "2.3.11";

    dependencies = [
      "activemodel"
      "css_parser"
      "htmlbeautifier"
      "htmlentities"
      "marcel"
      "railties"
      "redcarpet"
      "rouge"
      "view_component"
      "yard"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qk8mz6m469bw8hry4vabwib4k9nfzz1zcrqv17h0nxwprn0ayw4";
      type = "gem";
    };
  };

  lucide-rails = {
    version = "0.7.3";
    dependencies = [ "railties" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jfsjfh78ya2hapmjnscnqp2zcmvq5p7pfkgsjdyjwla2pqh6k82";
      type = "gem";
    };
  };

  mail = {
    version = "2.8.1";

    dependencies = [
      "mini_mime"
      "net-imap"
      "net-pop"
      "net-smtp"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bf9pysw1jfgynv692hhaycfxa8ckay1gjw5hz3madrbrynryfzc";
      type = "gem";
    };
  };

  marcel = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vhb1sbzlq42k2pzd9v0w5ws4kjx184y8h4d63296bn57jiwzkzx";
      type = "gem";
    };
  };

  matrix = {
    version = "0.4.2";

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1h2cgkpzkh3dd0flnnwfq6f3nl2b1zff9lvqz8xs853ssv5kq23i";
      type = "gem";
    };
  };

  memory_profiler = {
    version = "1.1.0";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1y58ba08n4lx123c0hjcc752fc4x802mjy39qj1hq50ak3vpv8br";
      type = "gem";
    };
  };

  method_source = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1igmc3sq9ay90f8xjvfnswd1dybj1s3fi0dwd53inwsvqk4h24qq";
      type = "gem";
    };
  };

  mini_histogram = {
    version = "0.3.1";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "156xs8k7fqqcbk1fbf0ndz6gfw380fb2jrycfvhb06269r84n4ba";
      type = "gem";
    };
  };

  mini_magick = {
    version = "5.2.0";

    dependencies = [
      "benchmark"
      "logger"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jiz4jqsrmgnkyvpmsq2vicmvdqa6q2ibzx93lnj8f0xvfzzymr7";
      type = "gem";
    };
  };

  mini_mime = {
    version = "1.1.5";

    groups = [
      "default"
      "test"
    ];

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
      "test"
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

    groups = [
      "default"
      "development"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mbpz92ml19rcxxfjrj91gmkif9khb1xpzyw38f81rvglgw1ffrd";
      type = "gem";
    };
  };

  mocha = {
    version = "2.7.1";
    dependencies = [ "ruby2_keywords" ];
    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0lgqyxxdxgfik77a7lk2hjkr6flimgxr4gcbg3y7bg1ybn6m6zcg";
      type = "gem";
    };
  };

  msgpack = {
    version = "1.8.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cnpnbn2yivj9gxkh8mjklbgnpx6nf7b8j2hky01dl0040hy0k76";
      type = "gem";
    };
  };

  multi_json = {
    version = "1.20.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vfaab23d85617ps412ydb8ap4ci1sfzi8ainn8yyifc0pl38f9g";
      type = "gem";
    };
  };

  multi_xml = {
    version = "0.8.0";
    dependencies = [ "bigdecimal" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wyzwvch1a4c77g5zjwjhgf9z5inzngq42b197dm9qzqjb8dqjld";
      type = "gem";
    };
  };

  multipart-post = {
    version = "2.4.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1a5lrlvmg2kb2dhw3lxcsv6x276bwgsxpnka1752082miqxd0wlq";
      type = "gem";
    };
  };

  mutex_m = {
    version = "0.3.0";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l875dw0lk7b2ywa54l0wjcggs94vb7gs8khfw9li75n2sn09jyg";
      type = "gem";
    };
  };

  net-http = {
    version = "0.9.1";
    dependencies = [ "uri" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15k96fj6qwbaiv6g52l538ass95ds1qwgynqdridz29yqrkhpfi5";
      type = "gem";
    };
  };

  net-imap = {
    version = "0.5.8";

    dependencies = [
      "date"
      "net-protocol"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14zmzjy2sp87ac6iygkk3pz9snjvx4ks681vg4gxz8x8q7gmzajj";
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
    version = "2.7.4";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1a9www524fl1ykspznz54i0phfqya4x45hqaz67in9dvw1lfwpfr";
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
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mhp90nf3g3yy5vgjnwd34czi6rbi0p7057vgngfmmdkknsxiz9q";
      type = "gem";
    };
  };

  oauth2 = {
    version = "2.0.18";

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
      sha256 = "11rj80dgjz05x5xx93y4bfk9rcn7fl56srj8fgqn7ffzf3j13kxs";
      type = "gem";
    };
  };

  octokit = {
    version = "10.0.0";

    dependencies = [
      "faraday"
      "sawyer"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1s14kbjfm9vdvcrwqdarfdbfsjqs1jxpglp60plvfdvnkd9rmsc2";
      type = "gem";
    };
  };

  omniauth = {
    version = "2.1.3";

    dependencies = [
      "hashie"
      "rack"
      "rack-protection"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hjnb5b5m549irs0h1455ipzsv82pikdagx9wjb6r4j1bkjy494d";
      type = "gem";
    };
  };

  omniauth-github = {
    version = "2.0.1";

    dependencies = [
      "omniauth"
      "omniauth-oauth2"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1m6a7kg3lxz2nm96prln2ja8r4wlm37m5vsy9199vnynqq5fgy4g";
      type = "gem";
    };
  };

  omniauth-google-oauth2 = {
    version = "1.2.1";

    dependencies = [
      "jwt"
      "oauth2"
      "omniauth"
      "omniauth-oauth2"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pdf3bx036l6ggz6lkkykv77m9k4jypwsiw1q7874czwh2v50768";
      type = "gem";
    };
  };

  omniauth-oauth2 = {
    version = "1.8.0";

    dependencies = [
      "oauth2"
      "omniauth"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0y4y122xm8zgrxn5nnzwg6w39dnjss8pcq2ppbpx9qn7kiayky5j";
      type = "gem";
    };
  };

  omniauth-rails_csrf_protection = {
    version = "1.0.2";

    dependencies = [
      "actionpack"
      "omniauth"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1q2zvkw34vk1vyhn5kp30783w1wzam9i9g5ygsdjn2gz59kzsw0i";
      type = "gem";
    };
  };

  omniauth-saml = {
    version = "2.2.4";

    dependencies = [
      "omniauth"
      "ruby-saml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1sznc4d2qhqmkw1vhpx2v5i9ndfb4k25cazhz74cbv18wyp4bk2s";
      type = "gem";
    };
  };

  omniauth_openid_connect = {
    version = "0.8.0";

    dependencies = [
      "omniauth"
      "openid_connect"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "099xg7s6450wlfzs77mbdx78g3dp0glx5q6f44i78akf7283hbqz";
      type = "gem";
    };
  };

  openid_connect = {
    version = "2.3.1";

    dependencies = [
      "activemodel"
      "attr_required"
      "email_validator"
      "faraday"
      "faraday-follow_redirects"
      "json-jwt"
      "mail"
      "rack-oauth2"
      "swd"
      "tzinfo"
      "validate_url"
      "webfinger"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10i13cn40jiiw8lslkv7bj1isinnwbmzlk6msgiph3gqry08702x";
      type = "gem";
    };
  };

  openssl = {
    version = "4.0.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0zazkk5q3p2ldd23ka04wypsz2g8gqwwainf3d58j0kvdc9p8yg2";
      type = "gem";
    };
  };

  openssl-signature_algorithm = {
    version = "1.3.0";
    dependencies = [ "openssl" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "103yjl68wqhl5kxaciir5jdnyi7iv9yckishdr52s5knh9g0pd53";
      type = "gem";
    };
  };

  os = {
    version = "1.1.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gwd20smyhxbm687vdikfh1gpi96h8qb1x28s2pdcysf6dm6v0ap";
      type = "gem";
    };
  };

  ostruct = {
    version = "0.6.2";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1h6gazp5837xbz1aqvq9x0a5ffpw32nhvknn931a4074k6i04wvd";
      type = "gem";
    };
  };

  pagy = {
    version = "9.3.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mqgiwzjkj8b54146yj15jds53l1pfawvc9a14n8fvxra0qm3abq";
      type = "gem";
    };
  };

  parallel = {
    version = "1.27.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0c719bfgcszqvk9z47w2p8j2wkz5y35k48ywwas5yxbbh3hm3haa";
      type = "gem";
    };
  };

  parser = {
    version = "3.3.10.2";

    dependencies = [
      "ast"
      "racc"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mwk9syajzdradzqzp3agf03d0cazqwbfd1439nxpkmxli5chq3g";
      type = "gem";
    };
  };

  pdf-reader = {
    version = "2.15.1";

    dependencies = [
      "Ascii85"
      "afm"
      "hashery"
      "ruby-rc4"
      "ttfunk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kk8f1f5kkdwsbskv0vikcwx5xaivv19y9zl97x1fcaam23akihq";
      type = "gem";
    };
  };

  pg = {
    version = "1.5.9";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1p2gqqrm895fzr9vi8d118zhql67bm8ydjvgqbq1crdnfggzn7kn";
      type = "gem";
    };
  };

  plaid = {
    version = "41.0.0";

    dependencies = [
      "faraday"
      "faraday-multipart"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vrmmb043zvkcp5nm1m3n8xk9hqrc4ij3yfcdky6mkqy9fn6b7iw";
      type = "gem";
    };
  };

  platform_agent = {
    version = "1.0.1";

    dependencies = [
      "activesupport"
      "useragent"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0k6pff1lhn30fcszkr0fhn9sji2jxpaw22whfix0cg289nj1lli5";
      type = "gem";
    };
  };

  posthog-ruby = {
    version = "3.3.3";
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x9d06ipkhbp0cf047csri9rxr01yw2ddv5kz7ij5415125sdax8";
      type = "gem";
    };
  };

  pp = {
    version = "0.6.2";
    dependencies = [ "prettyprint" ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zxnfxjni0r9l2x42fyq0sqpnaf5nakjbap8irgik4kg1h9c6zll";
      type = "gem";
    };
  };

  prettyprint = {
    version = "0.2.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14zicq3plqi217w6xahv7b8f7aj5kpxv1j1w98344ix9h5ay3j9b";
      type = "gem";
    };
  };

  prism = {
    version = "1.4.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gkhpdjib9zi9i27vd9djrxiwjia03cijmd6q8yj2q1ix403w3nw";
      type = "gem";
    };
  };

  propshaft = {
    version = "1.1.0";

    dependencies = [
      "actionpack"
      "activesupport"
      "rack"
      "railties"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0sqg0xf46xd47zdpm8d12kfnwl0y5jb2hj10imzb3bk6mwgkd2fk";
      type = "gem";
    };
  };

  psych = {
    version = "5.2.6";

    dependencies = [
      "date"
      "stringio"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vii1xc7x81hicdbp7dlllhmbw5w3jy20shj696n0vfbbnm2hhw1";
      type = "gem";
    };
  };

  public_suffix = {
    version = "6.0.2";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1543ap9w3ydhx39ljcd675cdz9cr948x9mp00ab8qvq6118wv9xz";
      type = "gem";
    };
  };

  puma = {
    version = "6.6.0";
    dependencies = [ "nio4r" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11xd3207k5rl6bz0qxhcb3zcr941rhx7ig2f19gxxmdk7s3hcp7j";
      type = "gem";
    };
  };

  pundit = {
    version = "2.5.2";
    dependencies = [ "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gcb23749jwggmgic4607ky6hm2c9fpkya980iihpy94m8miax73";
      type = "gem";
    };
  };

  raabro = {
    version = "1.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10m8bln9d00dwzjil1k42i5r7l82x25ysbi45fwyv4932zsrzynl";
      type = "gem";
    };
  };

  racc = {
    version = "1.8.1";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0byn0c9nkahsl93y9ln5bysq4j31q8xkf2ws42swighxd4lnjzsa";
      type = "gem";
    };
  };

  rack = {
    version = "3.2.6";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hhjy9gcp52dzij05gmidqac8g28ski5xm67prwmdqmjfcgqxmsy";
      type = "gem";
    };
  };

  rack-attack = {
    version = "6.7.0";
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z6pj5vjgl6swq7a33gssf795k958mss8gpmdb4v4cydcs7px91w";
      type = "gem";
    };
  };

  rack-cors = {
    version = "3.0.0";

    dependencies = [
      "logger"
      "rack"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0s1zymxhk7pkzsrgrn5ax862p07s0drbv0qvnq36jq1rvdhvx5bv";
      type = "gem";
    };
  };

  rack-mini-profiler = {
    version = "4.0.0";
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03z02blb8q1c8fiwn249rnvmvrw655s4x36xmpa3mqq1gp5ysyy3";
      type = "gem";
    };
  };

  rack-oauth2 = {
    version = "2.2.1";

    dependencies = [
      "activesupport"
      "attr_required"
      "faraday"
      "faraday-follow_redirects"
      "json-jwt"
      "rack"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19fi42hi9l474ki89y6cs8vrpfmc1h8zpd02iwjy4hw0a1yahfn7";
      type = "gem";
    };
  };

  rack-protection = {
    version = "4.1.1";

    dependencies = [
      "base64"
      "logger"
      "rack"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0sniswjyi0yn949l776h7f67rvx5w9f04wh69z5g19vlsnjm98ji";
      type = "gem";
    };
  };

  rack-session = {
    version = "2.1.2";

    dependencies = [
      "base64"
      "rack"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1s7zcxlmg88a6dam4aqbgk9xkpy6dkdfqmmcszkkliy3q3w38m2r";
      type = "gem";
    };
  };

  rack-test = {
    version = "2.2.0";
    dependencies = [ "rack" ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qy4ylhcfdn65a5mz2hly7g9vl0g13p5a0rmm6sc0sih5ilkcnh0";
      type = "gem";
    };
  };

  rackup = {
    version = "2.2.1";
    dependencies = [ "rack" ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13brkq5xkj6lcdxj3f0k7v28hgrqhqxjlhd4y2vlicy5slgijdzp";
      type = "gem";
    };
  };

  rails = {
    version = "7.2.3.1";

    dependencies = [
      "actioncable"
      "actionmailbox"
      "actionmailer"
      "actionpack"
      "actiontext"
      "actionview"
      "activejob"
      "activemodel"
      "activerecord"
      "activestorage"
      "activesupport"
      "railties"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "155skqkjrckvzj1qy37lrnafrillc47qhf3l80g3zvw100ba1h4n";
      type = "gem";
    };
  };

  rails-dom-testing = {
    version = "2.3.0";

    dependencies = [
      "activesupport"
      "minitest"
      "nokogiri"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07awj8bp7jib54d0khqw391ryw8nphvqgw4bb12cl4drlx9pkk4a";
      type = "gem";
    };
  };

  rails-html-sanitizer = {
    version = "1.7.0";

    dependencies = [
      "loofah"
      "nokogiri"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "128y5g3fyi8fds41jasrr4va1jrs7hcamzklk1523k7rxb64bc98";
      type = "gem";
    };
  };

  rails-i18n = {
    version = "7.0.10";

    dependencies = [
      "i18n"
      "railties"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jiiv5ni1jrk15g572wc0l1ansbx6aqqsp2mk0pg9h18mkh1dbpg";
      type = "gem";
    };
  };

  rails-settings-cached = {
    version = "2.9.6";

    dependencies = [
      "activerecord"
      "railties"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1f59b260w1pd208l52zxxk34jfiz4cg93cxqa0lic6hz48l627bn";
      type = "gem";
    };
  };

  railties = {
    version = "7.2.3.1";

    dependencies = [
      "actionpack"
      "activesupport"
      "cgi"
      "irb"
      "rackup"
      "rake"
      "thor"
      "tsort"
      "zeitwerk"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0np1m8xqb4wbzwpg66yjnqjban0di92lbjzcrgnwwhq2w4z3k8xf";
      type = "gem";
    };
  };

  rainbow = {
    version = "3.1.1";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0smwg4mii0fm38pyb5fddbmrdpifwv22zv3d3px2xx497am93503";
      type = "gem";
    };
  };

  rake = {
    version = "13.3.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14s4jdcs1a4saam9qmzbsa2bsh85rj9zfxny5z315x3gg0nhkxcn";
      type = "gem";
    };
  };

  rb-fsevent = {
    version = "0.11.2";

    groups = [
      "default"
      "development"
    ];

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

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vmy8xgahixcz6hzwy4zdcyn2y6d6ri8dqv5xccgzc1r292019x0";
      type = "gem";
    };
  };

  rbs = {
    version = "3.9.4";
    dependencies = [ "logger" ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mx533jn2nv29xc5faw9g5xj9qbdaiwl9wv2byv98bgw6gqwhhlf";
      type = "gem";
    };
  };

  rchardet = {
    version = "1.10.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03rr05qam5d6gcsnsjs85bnwg80qww484xql347j42kj3bb2xsnm";
      type = "gem";
    };
  };

  rdoc = {
    version = "6.14.2";

    dependencies = [
      "erb"
      "psych"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09lj8d16wx5byj0nbcb9wc6v9farsvgn98n91kknm18g2ggl9pcz";
      type = "gem";
    };
  };

  redcarpet = {
    version = "3.6.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0iglapqs4av4za9yfaac0lna7s16fq2xn36wpk380m55d8792i6l";
      type = "gem";
    };
  };

  redis = {
    version = "5.4.0";
    dependencies = [ "redis-client" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0syhyw1bp9nbb0fvcmm58y1c6iav6xw6b4bzjz1rz2j1d7c012br";
      type = "gem";
    };
  };

  redis-client = {
    version = "0.25.0";
    dependencies = [ "connection_pool" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0419fjymfl3srw52cyac1162p86jk4qsq36q268zsikklc3zszcj";
      type = "gem";
    };
  };

  regexp_parser = {
    version = "2.10.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qccah61pjvzyyg6mrp27w27dlv6vxlbznzipxjcswl7x3fhsvyb";
      type = "gem";
    };
  };

  reline = {
    version = "0.6.1";
    dependencies = [ "io-console" ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yvm0svcdk6377ng6l00g39ldkjijbqg4whdg2zcsa8hrgbwkz0s";
      type = "gem";
    };
  };

  representable = {
    version = "3.2.0";

    dependencies = [
      "declarative"
      "trailblazer-option"
      "uber"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kms3r6w6pnryysnaqqa9fsn0v73zx1ilds9d1c565n3xdzbyafc";
      type = "gem";
    };
  };

  retriable = {
    version = "3.4.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1g634lvyriq8pk87fn0dnz2ib9mma98ks7y0b30j28a9gm5i2gzv";
      type = "gem";
    };
  };

  rexml = {
    version = "3.4.2";

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05y4lwzci16c2xgckmpxkzq4czgkyaiiqhvrabdgaym3aj2jd10k";
      type = "gem";
    };
  };

  rotp = {
    version = "6.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0m48hv6wpmmm6cjr6q92q78h1i610riml19k5h1dil2yws3h1m3m";
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

  rqrcode = {
    version = "3.1.0";

    dependencies = [
      "chunky_png"
      "rqrcode_core"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bwqy1iwbyn1091mg203is5ngsnvfparwa1wh89s1sgnfmirkmg2";
      type = "gem";
    };
  };

  rqrcode_core = {
    version = "2.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ayrj7pwbv1g6jg5vvx6rq05lr1kbkfzbzqplj169aapmcivhh0y";
      type = "gem";
    };
  };

  rspec-core = {
    version = "3.13.6";
    dependencies = [ "rspec-support" ];

    groups = [
      "default"
      "test"
    ];

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

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dl8npj0jfpy31bxi6syc7jymyd861q277sfr6jawq2hv6hx791k";
      type = "gem";
    };
  };

  rspec-mocks = {
    version = "3.13.6";

    dependencies = [
      "diff-lcs"
      "rspec-support"
    ];

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0klv9mibmnfqw92w5bc1bab1x4dai60xfh0xz0mhgicibsp3gcbq";
      type = "gem";
    };
  };

  rspec-rails = {
    version = "8.0.2";

    dependencies = [
      "actionpack"
      "activesupport"
      "railties"
      "rspec-core"
      "rspec-expectations"
      "rspec-mocks"
      "rspec-support"
    ];

    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kis8dfxlvi6gdzrv9nsn3ckw0c2z7armhni917qs1jx7yjkjc8i";
      type = "gem";
    };
  };

  rspec-support = {
    version = "3.13.6";

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cmgz34hwj5s3jwxhyl8mszs24nci12ffbrmr5jb1si74iqf739f";
      type = "gem";
    };
  };

  rswag-api = {
    version = "2.16.0";

    dependencies = [
      "activesupport"
      "railties"
    ];

    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0x30mviwxvxravw9jfi91sbb1mshi7c2aidb065y32z9jayzflxn";
      type = "gem";
    };
  };

  rswag-specs = {
    version = "2.16.0";

    dependencies = [
      "activesupport"
      "json-schema"
      "railties"
      "rspec-core"
    ];

    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "149apnslj99w2fvhlwk39k9wf5zlh1f03j0xs8pbvc08qj2n18lb";
      type = "gem";
    };
  };

  rswag-ui = {
    version = "2.16.0";

    dependencies = [
      "actionpack"
      "railties"
    ];

    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kx0scyb766w660y4sazarnfczi13q7h1hg7wvk95nnfgn99xx51";
      type = "gem";
    };
  };

  rubocop = {
    version = "1.76.1";

    dependencies = [
      "json"
      "language_server-protocol"
      "lint_roller"
      "parallel"
      "parser"
      "rainbow"
      "regexp_parser"
      "rubocop-ast"
      "ruby-progressbar"
      "unicode-display_width"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rz0wwhxy6rv0kk2m8jp77fbhwgs7m01p2yys9bj3kwl0xsjsnp1";
      type = "gem";
    };
  };

  rubocop-ast = {
    version = "1.45.1";

    dependencies = [
      "parser"
      "prism"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gis8w51k5dsmzzlppvwwznqyfd73fa3zcrpl1xihzy1mm4jw14l";
      type = "gem";
    };
  };

  rubocop-performance = {
    version = "1.25.0";

    dependencies = [
      "lint_roller"
      "rubocop"
      "rubocop-ast"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1h9flnqk2f3llwf8g0mk0fvzzznfj7hsil3qg88m803pi9b06zbg";
      type = "gem";
    };
  };

  rubocop-rails = {
    version = "2.32.0";

    dependencies = [
      "activesupport"
      "lint_roller"
      "rack"
      "rubocop"
      "rubocop-ast"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1404nfa0gw3p0xzmv4b9zg9v1da0nwc4m7796pl73zi2hwy65k4z";
      type = "gem";
    };
  };

  rubocop-rails-omakase = {
    version = "1.1.0";

    dependencies = [
      "rubocop"
      "rubocop-performance"
      "rubocop-rails"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "178h17q6wfsxk8gzqk1ca6dw25cwmwc2dgdb34lxwljqxv43mxra";
      type = "gem";
    };
  };

  ruby-lsp = {
    version = "0.26.9";

    dependencies = [
      "language_server-protocol"
      "prism"
      "rbs"
    ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0aa1mg6bdl23wgrxd98wycq3963jfpnh9z0yh976p9q03h01r81k";
      type = "gem";
    };
  };

  ruby-lsp-rails = {
    version = "0.4.8";
    dependencies = [ "ruby-lsp" ];
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bj4bj35l9jas2yf6w93j5ngw3f24lck2j9h5zmxwqs0dn91z7gh";
      type = "gem";
    };
  };

  ruby-openai = {
    version = "8.1.0";

    dependencies = [
      "event_stream_parser"
      "faraday"
      "faraday-multipart"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "052y1ai31bv4ajsgyq718c8sjlgx1liqcwl047z3kc5k07syfsbg";
      type = "gem";
    };
  };

  ruby-progressbar = {
    version = "1.13.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cwvyb7j47m7wihpfaq7rc47zwwx9k4v7iqd9s1xch5nm53rrz40";
      type = "gem";
    };
  };

  ruby-rc4 = {
    version = "0.1.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00vci475258mmbvsdqkmqadlwn6gj9m01sp7b5a3zd90knil1k00";
      type = "gem";
    };
  };

  ruby-saml = {
    version = "1.18.1";

    dependencies = [
      "nokogiri"
      "rexml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01wi1csw4kjmlxmd1igx5hj2wrwkslay1xamg4cv8l7imr27l3hv";
      type = "gem";
    };
  };

  ruby-statistics = {
    version = "4.1.0";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1agj0yspf9haqvqlq5dy3gqn8xc0h9a1dd7c44fi9rn4bnyplsbx";
      type = "gem";
    };
  };

  ruby-vips = {
    version = "2.2.4";

    dependencies = [
      "ffi"
      "logger"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0j8wxbkl261nwg7jr6kdz0zlyim4zcnnb72ynky97grqid6d61d3";
      type = "gem";
    };
  };

  ruby2_keywords = {
    version = "0.0.5";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vz322p8n39hz3b4a9gkmz9y7a5jaz41zrm2ywf31dvkqm03glgz";
      type = "gem";
    };
  };

  rubyzip = {
    version = "2.4.1";

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05an0wz87vkmqwcwyh5rjiaavydfn5f4q1lixcsqkphzvj7chxw5";
      type = "gem";
    };
  };

  safety_net_attestation = {
    version = "0.5.0";
    dependencies = [ "jwt" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1apjjd99bqsc22bfq66j27dp4im0amisy619hr9qbghdapfh3kf8";
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

    groups = [
      "default"
      "development"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cd0iriqfsf1z91qg271sm88xjnfd92b832z49p1nd542ka96lfc";
      type = "gem";
    };
  };

  selenium-webdriver = {
    version = "4.34.0";

    dependencies = [
      "base64"
      "logger"
      "rexml"
      "rubyzip"
      "websocket"
    ];

    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07i7ifp8vpgsn9y9smvndnbx1bkcl9mmxjnq8yrf4vz6rccbfyzc";
      type = "gem";
    };
  };

  sentry-rails = {
    version = "5.26.0";

    dependencies = [
      "railties"
      "sentry-ruby"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "133195jdyn3slgqybj66ig4v8fn3ms6xr60chi02lwlzxinijkdf";
      type = "gem";
    };
  };

  sentry-ruby = {
    version = "5.26.0";

    dependencies = [
      "bigdecimal"
      "concurrent-ruby"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jsmjh46kpqfvysl5hp9iynxiq4pcvp6f26vrdr72gv89542vf1p";
      type = "gem";
    };
  };

  sentry-sidekiq = {
    version = "5.26.0";

    dependencies = [
      "sentry-ruby"
      "sidekiq"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dc3nffkv79dpkskyhl658kvbz0y4msrlr9rgvcksw34i4g5bc2c";
      type = "gem";
    };
  };

  sidekiq = {
    version = "8.0.5";

    dependencies = [
      "connection_pool"
      "json"
      "logger"
      "rack"
      "redis-client"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1m7pz58jkkild9y4w7l61rwxrzdv739z7nfr5kd85w3vrxpv4qyh";
      type = "gem";
    };
  };

  sidekiq-cron = {
    version = "2.3.0";

    dependencies = [
      "cronex"
      "fugit"
      "globalid"
      "sidekiq"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05fns2mlajklgx04r9w4lrj1ikarwg6f34z5j8xxpdm5wx2mgiw9";
      type = "gem";
    };
  };

  sidekiq-unique-jobs = {
    version = "8.0.11";

    dependencies = [
      "concurrent-ruby"
      "sidekiq"
      "thor"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10g1y6258xsw89c831c16z7m66i37ivhrcbfirpi0pb48fwinik3";
      type = "gem";
    };
  };

  signet = {
    version = "0.21.0";

    dependencies = [
      "addressable"
      "faraday"
      "jwt"
      "multi_json"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nydm087m5c3j85gvzvz30w1qb9pl2lzpznw746jha29ybxyj5yn";
      type = "gem";
    };
  };

  simplecov = {
    version = "0.22.0";

    dependencies = [
      "docile"
      "simplecov-html"
      "simplecov_json_formatter"
    ];

    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "198kcbrjxhhzca19yrdcd6jjj9sb51aaic3b0sc3pwjghg3j49py";
      type = "gem";
    };
  };

  simplecov-html = {
    version = "0.13.1";

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02zi3rwihp7rlnp9x18c9idnkx7x68w6jmxdhyc0xrhjwrz0pasx";
      type = "gem";
    };
  };

  simplecov_json_formatter = {
    version = "0.1.4";

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0a5l0733hj7sk51j81ykfmlk2vd5vaijlq9d5fn165yyx3xii52j";
      type = "gem";
    };
  };

  skylight = {
    version = "6.0.4";
    dependencies = [ "activesupport" ];
    groups = [ "production" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "035xplxkr21z73c7mzfaj7ak438w2j63118724s53fbnv8rrw790";
      type = "gem";
    };
  };

  smart_properties = {
    version = "1.17.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jrqssk9qhwrpq41arm712226vpcr458xv6xaqbk8cp94a0kycpr";
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

  snaptrade = {
    version = "2.0.156";

    dependencies = [
      "faraday"
      "faraday-multipart"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19c6vj1g6iy81czg0z9r28w7mqzfqxp4isg3fzpxgq8x4ihi5s3x";
      type = "gem";
    };
  };

  stackprof = {
    version = "0.2.27";
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03788mbipmihq2w7rznzvv0ks0s9z1321k1jyr6ffln8as3d5xmg";
      type = "gem";
    };
  };

  stimulus-rails = {
    version = "1.3.4";
    dependencies = [ "railties" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01nbcxyi1mhikq8yjl0g9swy1cpzx146pli6w16gcfpkl7zpcmkn";
      type = "gem";
    };
  };

  stringio = {
    version = "3.1.7";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yh78pg6lm28c3k0pfd2ipskii1fsraq46m6zjs5yc9a4k5vfy2v";
      type = "gem";
    };
  };

  stripe = {
    version = "15.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wsnpmbswir58hg7hi745mpgwsd5h5452f57mgpc6k7qzbm9v2v2";
      type = "gem";
    };
  };

  swd = {
    version = "2.0.3";

    dependencies = [
      "activesupport"
      "attr_required"
      "faraday"
      "faraday-follow_redirects"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0m86fzmwgw0vc8p6fwvnsdbldpgbqdz9cbp2zj9z06bc4jjf5nsc";
      type = "gem";
    };
  };

  tailwindcss-rails = {
    version = "4.2.3";

    dependencies = [
      "railties"
      "tailwindcss-ruby"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ab8dd2agzxx6nk8nvwrdqg6y7gl1p9knfypkxc561wxh5qbyl18";
      type = "gem";
    };
  };

  tailwindcss-ruby = {
    version = "4.1.8";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ljizfgxivhlqb14hd2i2szg6dqkmpqvk2xaf4by1kb57vmzhz5b";
      type = "gem";
    };
  };

  terminal-table = {
    version = "4.0.0";
    dependencies = [ "unicode-display_width" ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lh18gwpksk25sbcjgh94vmfw2rz0lrq61n7lwp1n9gq0cr7j17m";
      type = "gem";
    };
  };

  thor = {
    version = "1.4.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gcarlmpfbmqnjvwfz44gdjhcmm634di7plcx2zdgwdhrhifhqw7";
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

  tpm-key_attestation = {
    version = "0.14.1";

    dependencies = [
      "bindata"
      "openssl"
      "openssl-signature_algorithm"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gqr27hrmg35j7kcb6c2cx3xvkqfs42zpp9jcqw0mzbs79jy9m3z";
      type = "gem";
    };
  };

  trailblazer-option = {
    version = "0.1.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18s48fndi2kfvrfzmq6rxvjfwad347548yby0341ixz1lhpg3r10";
      type = "gem";
    };
  };

  tsort = {
    version = "0.2.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17q8h020dw73wjmql50lqw5ddsngg67jfw8ncjv476l5ys9sfl4n";
      type = "gem";
    };
  };

  ttfunk = {
    version = "1.8.0";
    dependencies = [ "bigdecimal" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ji0kn8jkf1rpskv3ijzxvqwixg4p6sk8kg0vmwyjinci7jcgjx7";
      type = "gem";
    };
  };

  turbo-rails = {
    version = "2.0.16";

    dependencies = [
      "actionpack"
      "railties"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13d31vm4i39cg7nkgn10h8zi89qh77jngafdkrab6xf5y1h1nknj";
      type = "gem";
    };
  };

  tzinfo = {
    version = "2.0.6";
    dependencies = [ "concurrent-ruby" ];

    groups = [
      "default"
      "development"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16w2g84dzaf3z13gxyzlzbf748kylk5bdgg3n1ipvkvvqy685bwd";
      type = "gem";
    };
  };

  tzinfo-data = {
    version = "1.2026.2";
    dependencies = [ "tzinfo" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1g0hmv2axxjvk7m5ksql9q0a6mnhqv4cqgqqzh0pd39vsp9x7c3x";
      type = "gem";
    };
  };

  uber = {
    version = "0.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1p1mm7mngg40x05z52md3mbamkng0zpajbzqjjwmsyw0zw3v9vjv";
      type = "gem";
    };
  };

  unaccent = {
    version = "0.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cvk3vhs95123r4faa60vqknishx3r6fiy2kq0bm7p3f04q849yr";
      type = "gem";
    };
  };

  unicode = {
    version = "0.4.4.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mx9lwzy021lpcqql5kn4yi20njhf5h7c7wxm2fx51p1r2zr9wj2";
      type = "gem";
    };
  };

  unicode-display_width = {
    version = "3.1.4";
    dependencies = [ "unicode-emoji" ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1has87asspm6m9wgqas8ghhhwyf2i1yqrqgrkv47xw7jq3qjmbwc";
      type = "gem";
    };
  };

  unicode-emoji = {
    version = "4.0.4";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ajk6rngypm3chvl6r0vwv36q1931fjqaqhjjya81rakygvlwb1c";
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

  useragent = {
    version = "0.16.11";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0i1q2xdjam4d7gwwc35lfnz0wyyzvnca0zslcfxm9fabml9n83kh";
      type = "gem";
    };
  };

  validate_url = {
    version = "1.0.15";

    dependencies = [
      "activemodel"
      "public_suffix"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0lblym140w5n88ijyfgcvkxvpfj8m6z00rxxf2ckmmhk0x61dzkj";
      type = "gem";
    };
  };

  vcr = {
    version = "6.3.1";
    dependencies = [ "base64" ];
    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1v83xjgj5y1fzp7nm4s5dixwpy5yr8crklyjyjilc13jgqanxd9p";
      type = "gem";
    };
  };

  vernier = {
    version = "1.8.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pdc4p5vmms5bd7z324g0zmr7aa59l5xwidwbv1gz2m5q9arbky6";
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

  view_component = {
    version = "3.23.2";

    dependencies = [
      "activesupport"
      "concurrent-ruby"
      "method_source"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0aw962shs2x52dy1vhzkw1qc0b5vxmgaab6lld7hggrqkr5ysbrw";
      type = "gem";
    };
  };

  web-console = {
    version = "4.2.1";

    dependencies = [
      "actionview"
      "activemodel"
      "bindex"
      "railties"
    ];

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "087y4byl2s3fg0nfhix4s0r25cv1wk7d2j8n5324waza21xg7g77";
      type = "gem";
    };
  };

  webauthn = {
    version = "3.4.3";

    dependencies = [
      "android_key_attestation"
      "bindata"
      "cbor"
      "cose"
      "openssl"
      "safety_net_attestation"
      "tpm-key_attestation"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1z710ndfr9yajywhji8mr5gc3j3wnr0alq754q15nh7k73wgbrlv";
      type = "gem";
    };
  };

  webfinger = {
    version = "2.1.3";

    dependencies = [
      "activesupport"
      "faraday"
      "faraday-follow_redirects"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0p39802sfnm62r4x5hai8vn6d1wqbxsxnmbynsk8rcvzwyym4yjn";
      type = "gem";
    };
  };

  webmock = {
    version = "3.25.1";

    dependencies = [
      "addressable"
      "crack"
      "hashdiff"
    ];

    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08v374yrqqhjj3xjzmvwnv3yz21r22kn071yr0i67gmwaf9mv7db";
      type = "gem";
    };
  };

  websocket = {
    version = "1.2.11";

    groups = [
      "default"
      "test"
    ];

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

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qj9dmkmgahmadgh88kydb7cv15w13l1fj3kk9zz28iwji5vl3gd";
      type = "gem";
    };
  };

  websocket-extensions = {
    version = "0.1.5";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hc2g9qps8lmhibl5baa91b4qx8wqw872rgwagml78ydj8qacsqw";
      type = "gem";
    };
  };

  xpath = {
    version = "3.2.0";
    dependencies = [ "nokogiri" ];

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bh8lk9hvlpn7vmi6h4hkcwjzvs2y0cmkk3yjjdr8fxvj6fsgzbd";
      type = "gem";
    };
  };

  yard = {
    version = "0.9.37";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14k9lb9a60r9z2zcqg08by9iljrrgjxdkbd91gw17rkqkqwi1sd6";
      type = "gem";
    };
  };

  zeitwerk = {
    version = "2.7.3";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "119ypabas886gd0n9kiid3q41w76gz60s8qmiak6pljpkd56ps5j";
      type = "gem";
    };
  };
}
