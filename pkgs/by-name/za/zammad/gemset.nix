{
  PoParser = {
    version = "3.2.8";
    dependencies = [ "simple_po_parser" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rl8vkqhdxzk416q898drqinmfji13wjnbxbqbzjkz3wvd7pikzm";
      type = "gem";
    };
  };

  aasm = {
    version = "5.5.2";
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bv128fy6dwkqk5i26fkginv8zx0831qawf7lbj3pfww7nrp9f53";
      type = "gem";
    };
  };

  actioncable = {
    version = "8.0.5";

    dependencies = [
      "actionpack"
      "activesupport"
      "nio4r"
      "websocket-driver"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12xv89kmr6l6mflzqddk0zsmbbsr53mv9dz6z91sdcb3ifjd3881";
      type = "gem";
    };
  };

  actionmailbox = {
    version = "8.0.5";

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
      sha256 = "0m00a0sqf68rllzmsfkb02cqy4vi5q2lrrmgld1i5pf31iyahl96";
      type = "gem";
    };
  };

  actionmailer = {
    version = "8.0.5";

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
      sha256 = "0qc5ycibnxricdlgmrihds0hqjli5hhksbv947nqbsfg8b4gl63r";
      type = "gem";
    };
  };

  actionpack = {
    version = "8.0.5";

    dependencies = [
      "actionview"
      "activesupport"
      "nokogiri"
      "rack"
      "rack-session"
      "rack-test"
      "rails-dom-testing"
      "rails-html-sanitizer"
      "useragent"
    ];

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dabvb49acbwvy91587cbn36ghv3bsyl14a9aq4ll4nxfn4qdpn9";
      type = "gem";
    };
  };

  actiontext = {
    version = "8.0.5";

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
      sha256 = "1q8jm23v29zv055wpgyrwzb008bvqbm4x8bb64l0f8r6ccywxwqj";
      type = "gem";
    };
  };

  actionview = {
    version = "8.0.5";

    dependencies = [
      "activesupport"
      "builder"
      "erubi"
      "rails-dom-testing"
      "rails-html-sanitizer"
    ];

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04ql6lpvdmrl5169y166pfr9w53c6f40jkgmn4ljgkzh7pkaj3vd";
      type = "gem";
    };
  };

  activejob = {
    version = "8.0.5";

    dependencies = [
      "activesupport"
      "globalid"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "047asb83p78zh93v0q1svrfl6da3aqqbjlkwd2jap172pz1ybard";
      type = "gem";
    };
  };

  activemodel = {
    version = "8.0.5";
    dependencies = [ "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hjv2kmv7i0jk8zkng3pxa1kdd90qpgr3v60qvs764yw8qyq35n7";
      type = "gem";
    };
  };

  activerecord = {
    version = "8.0.5";

    dependencies = [
      "activemodel"
      "activesupport"
      "timeout"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ri9l5v4601bxwrkl105k1ccxxg2wpvg6x94rwqr834irnv63cl9";
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

  activerecord-session_store = {
    version = "2.2.0";

    dependencies = [
      "actionpack"
      "activerecord"
      "cgi"
      "rack"
      "railties"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hr7dv4qfimy3bqw3yhwsz4i9kpyw5jyg2dghx7vz0rnaxa814b5";
      type = "gem";
    };
  };

  activestorage = {
    version = "8.0.5";

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
      sha256 = "1wrxnj6rqzp7n80f0cfrdalz7b2md6sqqmx8lrgd3klaiwzqm295";
      type = "gem";
    };
  };

  activesupport = {
    version = "8.0.5";

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

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08ybmp63qrfaxq7bv7mvb4xvfb4fcylw2a0szankzkrpdbzi7wip";
      type = "gem";
    };
  };

  acts_as_list = {
    version = "1.2.6";

    dependencies = [
      "activerecord"
      "activesupport"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1j7xclldl8g34vs791cyihysyngfrj8hkl3sq0hfdgmp004khic3";
      type = "gem";
    };
  };

  addressable = {
    version = "2.9.0";
    dependencies = [ "public_suffix" ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1by7h2lwziiblizpd5yx87jsq8ppdhzvwf08ga34wzqgcv1nmpvz";
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

  argon2 = {
    version = "2.3.3";

    dependencies = [
      "ffi"
      "ffi-compiler"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ga570l7wrxr8qmxps8gcjjd1c6kp54iphqsy901kxxbgi2pcljk";
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

  auth-sanitizer = {
    version = "0.2.1";
    dependencies = [ "version_gem" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xy5gjb12kv6zjn4zyd16yfv4bygd02ykbr6cz10d6sqyw0wyzci";
      type = "gem";
    };
  };

  autodiscover = {
    version = "1.0.2";

    dependencies = [
      "httpclient"
      "logging"
      "nokogiri"
      "nori"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      fetchSubmodules = false;
      rev = "ee9b53dfa797ce6d4f970b82beea7fbdd2df56bb";
      sha256 = "1qffylir5i06vd3khwd182pslnqsa0kfc3dihvvjfdyl7p1lxv16";
      type = "git";
      url = "https://github.com/zammad-deps/autodiscover";
    };
  };

  autoprefixer-rails = {
    version = "10.4.21.0";
    dependencies = [ "execjs" ];
    groups = [ "assets" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d82qylmvc5cbh431kcrkcf2xj2ivlghnvyrmdsm5hhghnpqrd3i";
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
    version = "1.1244.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0asrqg47gp087wvx1cvhy1s7rpqx7r9q8kxnndfpggg3jp8dxrg6";
      type = "gem";
    };
  };

  aws-sdk-core = {
    version = "3.246.0";

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
      sha256 = "1k6xqkipjli9vl40d4wqxcl7035lav9f9hnczilhwmj8i7n68f1r";
      type = "gem";
    };
  };

  aws-sdk-kms = {
    version = "1.124.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z7k84m1wqf2zra9pm5xb8lndwj6npfd02r743b9zr6p0svhml20";
      type = "gem";
    };
  };

  aws-sdk-s3 = {
    version = "1.220.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sdk-kms"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z4cl87lbyw9qgp1l52sbjnysw63zmxih9wfhjfdvv67d9gdlzr3";
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

  bake = {
    version = "0.24.1";

    dependencies = [
      "bigdecimal"
      "samovar"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1izlqnz0828mgdq04s1w291ky912w6jzcg5iwch7gc8l2pkcgylb";
      type = "gem";
    };
  };

  base64 = {
    version = "0.3.0";

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yx9yn47a8lkfcjmigk79fykxvr80r4m1i35q82sxzynpbm7lcr7";
      type = "gem";
    };
  };

  benchmark = {
    version = "0.5.0";

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v1337j39w1z7x9zs4q7ag0nfv4vs4xlsjx2la0wpv8s6hig2pa6";
      type = "gem";
    };
  };

  bigdecimal = {
    version = "4.1.2";

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1g9zi8c4i7g8zz0c3hxrw6mblrjvgn7akys60clb9si7c1k1gljk";
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

  binding_of_caller = {
    version = "2.0.0";
    dependencies = [ "debug_inspector" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05yma8qd0c53dalkh2b9iddvi7j1wy1kmd77xmx5i1ca8bwfngp5";
      type = "gem";
    };
  };

  biz = {
    version = "1.8.2";

    dependencies = [
      "clavius"
      "tzinfo"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1n2d7cs9jlnpi75nbssv77qlw0jsqnixaikpxsrbxz154q43gvlc";
      type = "gem";
    };
  };

  bootsnap = {
    version = "1.24.2";
    dependencies = [ "msgpack" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "071dihwrx2bnz9cplhidqr40g0i0bgjvbnh3klndd22hly2hz46j";
      type = "gem";
    };
  };

  brakeman = {
    version = "8.0.4";
    dependencies = [ "racc" ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vyg9l6xivamb49r4kzkcw12r9x943kv79wsvwslhm1qjvx23ybv";
      type = "gem";
    };
  };

  browser = {
    version = "6.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bffb8dddrg6zn8c74swhy8mq2mysb195hi7chwwj9c8g2am4798";
      type = "gem";
    };
  };

  builder = {
    version = "3.3.0";

    groups = [
      "assets"
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

  byk = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cw26m1977kk6awns8h3d10f9bq9j467s0a4srdvkhgy6ar2jagn";
      type = "gem";
    };
  };

  camertron-eprun = {
    version = "1.1.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jyfz769dqpipy0wi72la16c8brh5793akvaixj64pj42rwk73ls";
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

    groups = [
      "development"
      "test"
    ];

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
    groups = [ "default" ];
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
      "test"
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

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1znw5x86hmm9vfhidwdsijz8m38pqgmv98l9ryilvky0aldv7mc9";
      type = "gem";
    };
  };

  clavius = {
    version = "1.0.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0y58v8k860vafm1psm69f2ndcqmcifyvswsjdy8bxbxy30zrgad1";
      type = "gem";
    };
  };

  cld = {
    version = "0.13.0";
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03297qpxh4q1c4fhksq8wkgwwlqdqg47izy5piz9x62n2xsbasa2";
      type = "gem";
    };
  };

  cldr-plurals-runtime-rb = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1afzavyzb7rw15s75vzfg6lj8nw2fglr2266970gmscvz1d8flr3";
      type = "gem";
    };
  };

  clearbit = {
    version = "0.3.3";
    dependencies = [ "nestful" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ccgvxzgpll1wr5i9wjm1h0m2z600j6c4yf6pww423qhg8a25lbl";
      type = "gem";
    };
  };

  coderay = {
    version = "1.1.3";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jvxqxzply1lwp7ysn94zjhh57vc14mcshw1ygw14ib8lhc00lyw";
      type = "gem";
    };
  };

  coffee-rails = {
    version = "5.0.0";

    dependencies = [
      "coffee-script"
      "railties"
    ];

    groups = [ "assets" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "170sp4y82bf6nsczkkkzypzv368sgjg6lfrkib4hfjgxa6xa3ajx";
      type = "gem";
    };
  };

  coffee-script = {
    version = "2.4.1";

    dependencies = [
      "coffee-script-source"
      "execjs"
    ];

    groups = [
      "assets"
      "default"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rc7scyk7mnpfxqv5yy4y5q1hx3i7q3ahplcp4bq2g5r24g2izl2";
      type = "gem";
    };
  };

  coffee-script-source = {
    version = "1.12.2";

    groups = [
      "assets"
      "default"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1907v9q1zcqmmyqzhzych5l7qifgls2rlbnbhy5vzyr7i7yicaz1";
      type = "gem";
    };
  };

  concurrent-ruby = {
    version = "1.3.7";

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1c2i64xsd35vijnb50rxb70g508s0x674xi0qpyyb8jy7bncl4j4";
      type = "gem";
    };
  };

  connection_pool = {
    version = "3.0.2";

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

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

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k0dxi072mz8j72r32kkzpky825hn092hb8hdxh4rz3yd5sbv7w6";
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

  crack = {
    version = "1.0.1";

    dependencies = [
      "bigdecimal"
      "rexml"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0zjcdl5i6lw508r01dym05ibhkc784cfn93m1d26c7fk1hwi0jpz";
      type = "gem";
    };
  };

  crass = {
    version = "1.0.6";

    groups = [
      "assets"
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

  csv = {
    version = "3.3.5";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gz7r2kazwwwyrwi95hbnhy54kwkfac5swh2gy5p5vw36fn38lbf";
      type = "gem";
    };
  };

  daemons = {
    version = "1.4.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07cszb0zl8mqmwhc8a2yfg36vi6lbgrp4pa5bvmryrpcz9v6viwg";
      type = "gem";
    };
  };

  dalli = {
    version = "5.0.2";
    dependencies = [ "logger" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jc7k9g0hd2nz7lfayaqahah20nlfnpcapn67zddkkcsgci6k141";
      type = "gem";
    };
  };

  dartsass-rails = {
    version = "0.5.1";

    dependencies = [
      "railties"
      "sass-embedded"
    ];

    groups = [ "assets" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06is62xl51f6sy6ndz5nagb0mlpi2pb58sd074bnrir93gxi15gi";
      type = "gem";
    };
  };

  date = {
    version = "3.5.1";

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1h0db8r2v5llxdbzkzyllkfniqw9gm092qn7cbaib73v9lw0c3bm";
      type = "gem";
    };
  };

  debug_inspector = {
    version = "1.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18k8x9viqlkh7dbmjzh8crbjy8w480arpa766cw1dnn3xcpa1pwv";
      type = "gem";
    };
  };

  delayed_job = {
    version = "4.1.13";
    dependencies = [ "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      fetchSubmodules = false;
      rev = "0f1644ccc6911f7fc0950aec6a63440b333a5074";
      sha256 = "1f1cw7g43wvlkhzzm955hdbygzz8rizc1nnrikaagj25v8wznd4b";
      type = "git";
      url = "https://github.com/zammad-deps/delayed_job";
    };
  };

  delayed_job_active_record = {
    version = "4.1.11";

    dependencies = [
      "activerecord"
      "delayed_job"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      fetchSubmodules = false;
      rev = "d49dd6da2cfd7650a0c1205f8007cdc9771004fb";
      sha256 = "17ak74wga5jx0nlj2sng2yfaz8wiib2jr59dsfm9ld87cxl4qwjl";
      type = "git";
      url = "https://github.com/zammad-deps/delayed_job_active_record";
    };
  };

  deprecation_toolkit = {
    version = "2.3.0";
    dependencies = [ "activesupport" ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jddwmb6ybmwinxd52nb3wyxx6hfvwczw7g1r9kyzffhqciqnma1";
      type = "gem";
    };
  };

  diff-lcs = {
    version = "1.6.2";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qlrj2qyysc9avzlr4zs1py3x684hqm61n4czrsk1pyllz5x5q4s";
      type = "gem";
    };
  };

  diffy = {
    version = "3.4.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qs7drxvyzk3dg22xgblc12lq5kww9hhj7vpn8ay3l42rasllf3r";
      type = "gem";
    };
  };

  doorkeeper = {
    version = "5.9.0";
    dependencies = [ "railties" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dk37d3fcg34g4ii5cmycf4a5yz76crl5z4164ggasyb7lxhbbgd";
      type = "gem";
    };
  };

  drb = {
    version = "2.2.3";

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wrkl7yiix268s2md1h6wh91311w95ikd8fy8m5gx589npyxc00b";
      type = "gem";
    };
  };

  dry-cli = {
    version = "1.4.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0x6qlxk6zp3jw748k6x3zkpywx9yjyagdyinb9qai2khdjvmn0dq";
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

  eco = {
    version = "1.0.0";

    dependencies = [
      "coffee-script"
      "eco-source"
      "execjs"
    ];

    groups = [ "assets" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09jiwb7pkg0sxk730maxahra4whqw5l47zd7yg7fvd71pikdwdr0";
      type = "gem";
    };
  };

  eco-source = {
    version = "1.1.0.rc.1";

    groups = [
      "assets"
      "default"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ccxrvaac6mw5kdj1i490b5xb1wdka3a5q4jhvn8dvg41594yba1";
      type = "gem";
    };
  };

  elastic-transport = {
    version = "8.5.1";

    dependencies = [
      "faraday"
      "multi_json"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kf058q3mdq4nch8x0qgy9hf761hj0k3hbsxygag4h0qg67ygsjy";
      type = "gem";
    };
  };

  elasticsearch = {
    version = "9.3.1";

    dependencies = [
      "elastic-transport"
      "elasticsearch-api"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "097a46f3921y72fy0s2izsxlcfqmr41fcjz7a56l7xgmn1rznffa";
      type = "gem";
    };
  };

  elasticsearch-api = {
    version = "9.3.1";

    dependencies = [
      "base64"
      "multi_json"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wm61n1v7syry78lmvs1vp7024r8s1qag37vw07hrgywapnl96lw";
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

  email_address = {
    version = "0.2.9";

    dependencies = [
      "base64"
      "simpleidn"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1si81641108bf0cl06j4yj1k1ad5azskbmh676d0xmk8f5mpsxnn";
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
    version = "6.0.4";

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ncmbdjf2bwmk0jf5cxywns9zbxyfiy4h4p3pzi7yddyjhv81qrq";
      type = "gem";
    };
  };

  erubi = {
    version = "1.13.1";

    groups = [
      "assets"
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
    version = "2.10.1";
    groups = [ "assets" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wbkbskyaz1vh4yq0zmf39lnm1q79n9yn508q4q8xsv7hh1axq5b";
      type = "gem";
    };
  };

  factory_bot = {
    version = "6.5.6";
    dependencies = [ "activesupport" ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xz02xlnfhj418g51w06asfpcjccf7b66dx6ly3c1k2d45rv7ghj";
      type = "gem";
    };
  };

  factory_bot_rails = {
    version = "6.5.1";

    dependencies = [
      "factory_bot"
      "railties"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0s3dpi8x754bwv4mlasdal8ffiahi4b4ajpccnkaipp4x98lik6k";
      type = "gem";
    };
  };

  faker = {
    version = "3.8.0";
    dependencies = [ "i18n" ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1z1yfmqwml3gr1hjnjx6qbchmvr29j6z317wlhkhzabkvw4b6iy1";
      type = "gem";
    };
  };

  faraday = {
    version = "2.14.3";

    dependencies = [
      "faraday-net_http"
      "json"
      "logger"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0y7j6yzv07zggic6g0p2v1ivnvkzsbqjnfdl4215qqb6cxz290hq";
      type = "gem";
    };
  };

  faraday-follow_redirects = {
    version = "0.5.0";
    dependencies = [ "faraday" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1b8hgpci3wjm3rm41bzpasvsc5j253ljyg5rsajl62dkjk497pjw";
      type = "gem";
    };
  };

  faraday-mashify = {
    version = "1.0.2";

    dependencies = [
      "faraday"
      "hashie"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1sfjmpkvd3gybw0w577dg8lix86dggy6gnf3315rmbq7z2rr7p7b";
      type = "gem";
    };
  };

  faraday-multipart = {
    version = "1.2.0";
    dependencies = [ "multipart-post" ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mzp9rlqiryyi99bm9ii80hfsbbafh9wl8r3c5pif51pd54sk2bx";
      type = "gem";
    };
  };

  faraday-net_http = {
    version = "3.4.4";
    dependencies = [ "net-http" ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "125m3qri52vwh5v9dhq0dkqxf8629cxrf99yyc01pva72wasyy0f";
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

  ffi-compiler = {
    version = "1.4.2";

    dependencies = [
      "ffi"
      "rake"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vhjv98f9rjdzdxfsyyk19sfb45dcxc57ynsdmvn8vzdkifrvmm9";
      type = "gem";
    };
  };

  fiber-annotation = {
    version = "0.2.0";

    groups = [
      "default"
      "development"
      "test"
    ];

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

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01lz929qf3xa90vra1ai1kh059kf2c8xarfy6xbv1f8g457zk1f8";
      type = "gem";
    };
  };

  fiber-storage = {
    version = "1.0.1";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qa0j9qjwav9xb0n3isx0rbh0942xrfback392n6vs8bidnmp3pl";
      type = "gem";
    };
  };

  gli = {
    version = "2.22.2";
    dependencies = [ "ostruct" ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1c2x5wh3d3mz8vg5bs7c5is0zvc56j6a2b4biv5z1w5hi1n8s3jq";
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

  google-protobuf = {
    version = "4.34.1";

    dependencies = [
      "bigdecimal"
      "rake"
    ];

    groups = [
      "assets"
      "default"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1p3cg5sf7if5vf17glhsm58ydk6cr68kgyi8y1h9qrcd5da82w9l";
      type = "gem";
    };
  };

  graphql = {
    version = "2.6.1";

    dependencies = [
      "base64"
      "fiber-storage"
      "logger"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rqrwkviv3vkszxrx6zh0r71kqk7xvsar37k5nxcz7rhv86jkd74";
      type = "gem";
    };
  };

  graphql-batch = {
    version = "0.6.1";

    dependencies = [
      "graphql"
      "promise.rb"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0k85y2vk0n8cvb4q22i8lv1v2cp9k4j8zv6mv812vkfk4cjcmmyw";
      type = "gem";
    };
  };

  graphql-fragment_cache = {
    version = "1.22.2";
    dependencies = [ "graphql" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00w48v80mfpxrqrgwlmz0sw997nch47lrfwj38ikm96fqhyhxbl0";
      type = "gem";
    };
  };

  hashdiff = {
    version = "1.2.1";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lbw8lqzjv17vnwb9vy5ki4jiyihybcc5h2rmcrqiz1xa6y9s1ww";
      type = "gem";
    };
  };

  hashie = {
    version = "5.1.0";
    dependencies = [ "logger" ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0w1qrab701d3a63aj2qavwc2fpcqmkzzh1w2x93c88zkjqc4frn2";
      type = "gem";
    };
  };

  hiredis-client = {
    version = "0.28.0";
    dependencies = [ "redis-client" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17gj43jwjiy56sag0zy0gpwkxd9kf2giqngn71yxjl6397dvf30g";
      type = "gem";
    };
  };

  htmlentities = {
    version = "4.4.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hy5jvzd4wagk0k0yq7bjm6fa7ba7vjggzjfpri95jifkzvbvbxv";
      type = "gem";
    };
  };

  "http_parser.rb" = {
    version = "0.8.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yh924g697spcv4hfigyxgidhyy6a7b9007rnac57airbcadzs4s";
      type = "gem";
    };
  };

  httparty = {
    version = "0.24.2";

    dependencies = [
      "csv"
      "mini_mime"
      "multi_xml"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0f4wv9zvv2j57ck19xrladm5s5sn45g3xlqg78qa8jhcm9a6mjlg";
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
    version = "1.14.8";
    dependencies = [ "concurrent-ruby" ];

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1994i044vdmzzkyr76g8rpl1fq1532wf0sb21xg5r1ilj5iphmr8";
      type = "gem";
    };
  };

  icalendar = {
    version = "2.12.2";

    dependencies = [
      "base64"
      "ice_cube"
      "logger"
      "ostruct"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xfr3686v5brfwhpz7cjj638rxzac5z0jh7cxay184jd9dwgngdn";
      type = "gem";
    };
  };

  icalendar-recurrence = {
    version = "1.2.1";

    dependencies = [
      "icalendar"
      "ice_cube"
      "tzinfo"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08mwwidgyg9hzarw2j7q2hkpxiy7nf1dz8447jcp58d92h9rfff7";
      type = "gem";
    };
  };

  ice_cube = {
    version = "0.17.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gpwlpshsjlld53h1f999p0azd9jdlgmhbswa19wqjjbv9fv9pij";
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

  inflection = {
    version = "1.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mfkk0j0dway3p4gwzk8fnpi4hwaywl2v0iywf1azf98zhk9pfnf";
      type = "gem";
    };
  };

  iniparse = {
    version = "1.5.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wb1qy4i2xrrd92dc34pi7q7ibrjpapzk9y465v0n9caiplnb89n";
      type = "gem";
    };
  };

  interception = {
    version = "0.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01vrkn28psdx1ysh5js3hn17nfp1nvvv46wc1pwqsakm6vb1hf55";
      type = "gem";
    };
  };

  io-console = {
    version = "0.8.2";

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k0lk3pwadm2myvpg893n8jshmrf2sigrd4ki15lymy7gixaxqyn";
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

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qs8a9vprg7s8krgq4s0pygr91hclqqyz98ik15p0m1sf2h5956y";
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
    version = "2.19.9";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16mp8vzgxa8nsa81np042za453j8b0ihpjkf666s7byxrnvjb44v";
      type = "gem";
    };
  };

  json-jwt = {
    version = "1.17.0";

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
      sha256 = "1k64mp59jlbqd5hyy46pf93s3yl1xdngfy8i8flq2hn5nhk91ybg";
      type = "gem";
    };
  };

  jwt = {
    version = "3.2.0";
    dependencies = [ "base64" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mqps8z4ly74hpksfajcfamqk1wb79biy187pn10knmi6zzb26al";
      type = "gem";
    };
  };

  koala = {
    version = "3.7.0";

    dependencies = [
      "addressable"
      "base64"
      "cgi"
      "faraday"
      "faraday-multipart"
      "json"
      "ostruct"
      "rexml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0myh3q9caiyr5cmfah91ajqxs5rql1k0ilhc7lw99mj88j0rpk0k";
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
    version = "3.10.0";

    dependencies = [
      "logger"
      "rb-fsevent"
      "rb-inotify"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ln9c0vx165hkfbn2817qw4m6i77xcxh6q0r5v6fqfhlcbdq5qf6";
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

  localhost = {
    version = "1.8.0";
    dependencies = [ "bake" ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0097kdsp2fwkps57f8ypc12dqzf4dg4glzn1i32ljjgnnhjshznz";
      type = "gem";
    };
  };

  logger = {
    version = "1.7.0";

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

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

  loofah = {
    version = "2.25.1";

    dependencies = [
      "crass"
      "nokogiri"
    ];

    groups = [
      "assets"
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

  macaddr = {
    version = "1.7.2";
    dependencies = [ "systemu" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10nzvbp3raa93afisa870005acmv2vlrka82pxh13g4bjq4phdys";
      type = "gem";
    };
  };

  mail = {
    version = "2.9.0";

    dependencies = [
      "logger"
      "mini_mime"
      "net-imap"
      "net-pop"
      "net-smtp"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ha9sgkfqna62c1basc17dkx91yk7ppgjq32k4nhrikirlz6g9kg";
      type = "gem";
    };
  };

  mapping = {
    version = "1.1.3";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18jdbz3x6cvprhsw7jiv44xi6wklric0rq6iznm6xm7c40fr6x12";
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
    version = "0.4.3";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nscas3a4mmrp1rc07cdjlbbpb2rydkindmbj3v3z5y1viyspmd0";
      type = "gem";
    };
  };

  messagebird-rest = {
    version = "5.0.0";
    dependencies = [ "jwt" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "176m75m0bxmq9c8aa3b7wmn34sybq8k79l7s46h4lpixpbpw2k6s";
      type = "gem";
    };
  };

  method_source = {
    version = "1.1.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1igmc3sq9ay90f8xjvfnswd1dybj1s3fi0dwd53inwsvqk4h24qq";
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
    version = "3.2026.0414";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k28j6ww8rf43r5i8278jvm2cq3pnzsvqm7yqpb4p93kadjlq726";
      type = "gem";
    };
  };

  mini_mime = {
    version = "1.1.5";

    groups = [
      "default"
      "development"
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
      "assets"
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
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mbpz92ml19rcxxfjrj91gmkif9khb1xpzyw38f81rvglgw1ffrd";
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
    version = "1.21.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0a14g7qzbp32f4q3y1x8ifnxl9yfprqic33q75mpkx6f2hc7csfx";
      type = "gem";
    };
  };

  multi_xml = {
    version = "0.9.1";
    dependencies = [ "bigdecimal" ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0msflv26i6i3jr9w761k4qdl7cp9zbhymjkn57b1w90pkjsndrvw";
      type = "gem";
    };
  };

  multipart-post = {
    version = "2.4.1";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1a5lrlvmg2kb2dhw3lxcsv6x276bwgsxpnka1752082miqxd0wlq";
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

  nestful = {
    version = "1.1.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0sn7lrdhp1dwn9xkqwkarby5bxx1g30givy3fi1dwp1xvqbrqikw";
      type = "gem";
    };
  };

  net-http = {
    version = "0.9.1";
    dependencies = [ "uri" ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15k96fj6qwbaiv6g52l538ass95ds1qwgynqdridz29yqrkhpfi5";
      type = "gem";
    };
  };

  net-imap = {
    version = "0.6.4.1";

    dependencies = [
      "date"
      "net-protocol"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03ga2h4i5hsk8pdlicyfvqfsbh55vrbikb0nkx9x7vx7fl6kdw19";
      type = "gem";
    };
  };

  net-ldap = {
    version = "0.20.0";

    dependencies = [
      "base64"
      "ostruct"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wjkrvcwnxa6ggq0nfz004f1blm1c67fv7c6614sraak0wshn25j";
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

    groups = [
      "default"
      "puma"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18fwy5yqnvgixq3cn0h63lm8jaxsjjxkmj8rhiv8wpzv9271d43c";
      type = "gem";
    };
  };

  nkf = {
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09piyp2pd74klb9wcn0zw4mb5l0k9wzwppxggxi1yi95l2ym3hgv";
      type = "gem";
    };
  };

  nokogiri = {
    version = "1.19.4";

    dependencies = [
      "mini_portile2"
      "racc"
    ];

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1d9safb4dly6qmc2g06444l0zifby52yy6j1a5fa1g4j3ihm3jah";
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

  oauth = {
    version = "1.1.6";

    dependencies = [
      "auth-sanitizer"
      "base64"
      "cgi"
      "oauth-tty"
      "snaky_hash"
      "version_gem"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "107i702qlyirqh243zan4lpl6ki599brw31fhhvq47z413ih7p8r";
      type = "gem";
    };
  };

  oauth-tty = {
    version = "1.0.8";

    dependencies = [
      "auth-sanitizer"
      "cgi"
      "version_gem"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01qylh3rskdpvjkd2dkm6sdf2klf2w99zib8z0bjbhhpmxkkp9nr";
      type = "gem";
    };
  };

  oauth2 = {
    version = "2.0.22";

    dependencies = [
      "auth-sanitizer"
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
      sha256 = "19igd2jv3vqrqpqqdf36740g1sln16ibv1npgvdzcsfyr3q6jilg";
      type = "gem";
    };
  };

  omniauth = {
    version = "2.1.4";

    dependencies = [
      "hashie"
      "logger"
      "rack"
      "rack-protection"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0g3n12k5npmmgai2cs3snimy6r7h0bvalhjxv0fjxlphjq25p822";
      type = "gem";
    };
  };

  omniauth-facebook = {
    version = "10.0.0";

    dependencies = [
      "bigdecimal"
      "omniauth-oauth2"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qdrziqfa4sqpqf77i0nzbwq4qyg8qaqd127alnmg1skvax6rp6z";
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

  omniauth-gitlab = {
    version = "4.1.0";

    dependencies = [
      "omniauth"
      "omniauth-oauth2"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04wnjnapgwsnyd3dfnp8dp1jjnsg64zkls5xharj10j822kiygsl";
      type = "gem";
    };
  };

  omniauth-google-oauth2 = {
    version = "1.2.2";

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
      sha256 = "04dyy57rlgvrv69pq2pm4rsj658zbaqjy2a6i29qy10w4b8g7hvl";
      type = "gem";
    };
  };

  omniauth-linkedin-oauth2 = {
    version = "1.0.1";
    dependencies = [ "omniauth-oauth2" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xai5k6xzinc4d67n64y1acffs8p7xi2hikz493dz6jx8qv9b2g3";
      type = "gem";
    };
  };

  omniauth-microsoft-office365 = {
    version = "0.0.8";

    dependencies = [
      "omniauth"
      "omniauth-oauth2"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vw6418gykxqd9z32ddq0mr6wa737la1zwppb1ilw9sgii24rg1v";
      type = "gem";
    };
  };

  omniauth-oauth = {
    version = "1.2.1";

    dependencies = [
      "oauth"
      "omniauth"
      "rack"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1a4dqmlv3if6hb4ddyx4y5v7vkpi7zq901104nl0ya1l0b4j5gr5";
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
    version = "2.0.1";

    dependencies = [
      "actionpack"
      "omniauth"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bf3m2ds78scmgacb1wx38zjj1czzkym0bdmgi9vn99rgr6j1qy6";
      type = "gem";
    };
  };

  omniauth-saml = {
    version = "2.2.5";

    dependencies = [
      "omniauth"
      "ruby-saml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ndbsyhdalpijj8bri3imkrrr06y07c0m7hnzl6iywadarjd8ajm";
      type = "gem";
    };
  };

  omniauth-twitter = {
    version = "1.4.0";

    dependencies = [
      "omniauth-oauth"
      "rack"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0r5j65hkpgzhvvbs90id3nfsjgsad6ymzggbm7zlaxvnrmvnrk65";
      type = "gem";
    };
  };

  omniauth-weibo-oauth2 = {
    version = "0.5.3";

    dependencies = [
      "omniauth"
      "omniauth-oauth2"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kmakx58hf1dl1s8xapz2h8hnl7zw13b3fq01qszk7vp0yyg7cnx";
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

  ostruct = {
    version = "0.6.3";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04nrir9wdpc4izqwqbysxyly8y7hsfr4fsv69rw91lfi9d5fv8lm";
      type = "gem";
    };
  };

  overcommit = {
    version = "0.69.0";

    dependencies = [
      "childprocess"
      "iniparse"
      "rexml"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15w69xzvbzjadcl5lppmjf7jjw3p5cz9859y19wcn17bb0jh828m";
      type = "gem";
    };
  };

  parallel = {
    version = "2.1.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mlkn1vhh9lr7vljibpgspwsswk7mzm8nw6bbr616c9fbj35hlmk";
      type = "gem";
    };
  };

  parser = {
    version = "3.3.11.1";

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
      sha256 = "0m2xqvn1la62hji1mn04y59giikww95p2hs0r4y2rrz3mdxcwyni";
      type = "gem";
    };
  };

  pg = {
    version = "1.6.3";
    groups = [ "postgres" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16caca7lcz5pwl82snarqrayjj9j7abmxqw92267blhk7rbd120k";
      type = "gem";
    };
  };

  power_assert = {
    version = "3.0.1";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00s1sfjak8w3f12g66ldb61xjavr5p2wvkflziiyhx6c2rkqgscc";
      type = "gem";
    };
  };

  pp = {
    version = "0.6.3";
    dependencies = [ "prettyprint" ];

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xlxmg86k5kifci1xvlmgw56x88dmqf04zfzn7zcr4qb8ladal99";
      type = "gem";
    };
  };

  prettyprint = {
    version = "0.2.0";

    groups = [
      "assets"
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
    version = "1.9.0";

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11ggfikcs1lv17nhmhqyyp6z8nq5pkfcj6a904047hljkxm0qlvv";
      type = "gem";
    };
  };

  "promise.rb" = {
    version = "0.7.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0a819sikcqvhi8hck1y10d1nv2qkjvmmm553626fmrh51h2i089d";
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

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kh5nv8v74k1ccy6gc7nd04aaf1cjkbk7g8pwy2izvcqaq36jv6p";
      type = "gem";
    };
  };

  pry-doc = {
    version = "1.7.0";

    dependencies = [
      "pry"
      "yard"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13id4bmq39fm8176b7a9mz0cira5qfa4zr24chf48m1b0vn9znka";
      type = "gem";
    };
  };

  pry-rails = {
    version = "0.3.11";
    dependencies = [ "pry" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0garafb0lxbm3sx2r9pqgs7ky9al58cl3wmwc0gmvmrl9bi2i7m6";
      type = "gem";
    };
  };

  pry-remote = {
    version = "0.1.8";

    dependencies = [
      "pry"
      "slop"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10g1wrkcy5v5qyg9fpw1cag6g5rlcl1i66kn00r7kwqkzrdhd7nm";
      type = "gem";
    };
  };

  pry-rescue = {
    version = "1.6.0";

    dependencies = [
      "interception"
      "pry"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nx6mf97vv11bgy2giljgwds8rjj8kw0qyc6zn3varlqdm8gsnwq";
      type = "gem";
    };
  };

  pry-stack_explorer = {
    version = "0.6.3";

    dependencies = [
      "binding_of_caller"
      "pry"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1413005yb8h1g48bzb17gzs554ch9mxa8gkhd7xa67n4mwy4q51z";
      type = "gem";
    };
  };

  pry-theme = {
    version = "1.3.1";
    dependencies = [ "coderay" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qhs1qmv6zhl45zhpv5qj6vkwm0nkdc37dqd49fwl8ph6f0sfh8h";
      type = "gem";
    };
  };

  psych = {
    version = "5.3.1";

    dependencies = [
      "date"
      "stringio"
    ];

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0x0r3gc66abv8i4dw0x0370b5hrshjfp6kpp7wbp178cy775fypb";
      type = "gem";
    };
  };

  public_suffix = {
    version = "7.0.5";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08znfv30pxmdkjyihvbjqbvv874dj3nybmmyscl958dy3f7v12qs";
      type = "gem";
    };
  };

  puma = {
    version = "8.0.2";
    dependencies = [ "nio4r" ];
    groups = [ "puma" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yw6nvkvddriacmva8hm0za0961d6j96dm7zm6748rmyzcfqgvf8";
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

  pundit-matchers = {
    version = "4.0.0";

    dependencies = [
      "rspec-core"
      "rspec-expectations"
      "rspec-mocks"
      "rspec-support"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mgzij87czkr59xp1v0il7hqwj2pabgp7vd3xk6afpjp3mx0gmjr";
      type = "gem";
    };
  };

  racc = {
    version = "1.8.1";

    groups = [
      "assets"
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
      "assets"
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
    version = "6.8.0";
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wpcxspprm187k6mch9fxhaaq1a3s9bzybd2fdaw1g45pzg9yjgj";
      type = "gem";
    };
  };

  rack-oauth2 = {
    version = "2.3.0";

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
      sha256 = "0cn6a9v8nry9fx4zrzp1xakfp2n5xv5075j90q56m20k7zvjrq23";
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

  rack-proxy = {
    version = "0.7.7";
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12jw7401j543fj8cc83lmw72d8k6bxvkp9rvbifi88hh01blnsj4";
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
      "assets"
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
      "assets"
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
    version = "2.3.1";
    dependencies = [ "rack" ];

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0s48d2a0z5f0cg4npvzznf933vipi6j7gmk16yc913kpadkw4ybc";
      type = "gem";
    };
  };

  rails = {
    version = "8.0.5";

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
      sha256 = "1rjvzpnl0js6axlygij5a5c6cwmraxvv6z6c2px95qlbjj80zd2c";
      type = "gem";
    };
  };

  rails-controller-testing = {
    version = "1.0.5";

    dependencies = [
      "actionpack"
      "actionview"
      "activesupport"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "151f303jcvs8s149mhx2g5mn67487x0blrf9dzl76q1nb7dlh53l";
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
      "assets"
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
      "assets"
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

  railties = {
    version = "8.0.5";

    dependencies = [
      "actionpack"
      "activesupport"
      "irb"
      "rackup"
      "rake"
      "thor"
      "tsort"
      "zeitwerk"
    ];

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1md96yl05v436jkgz9725cax9hf61sv74267cg7yidwnl3lwd65d";
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
    version = "13.4.2";

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "009p524zl0p0kfa65nii8wdmaigkmawv9pbvlcffky7islmmp0nb";
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
    version = "7.2.0";

    dependencies = [
      "erb"
      "psych"
      "tsort"
    ];

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

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
    version = "0.28.0";
    dependencies = [ "connection_pool" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jw2xjzz24dwn85y8v1jf1vzzpsnypsvs06f1qfa91w7rpwr5248";
      type = "gem";
    };
  };

  regexp_parser = {
    version = "2.12.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fwfw26a32rps78920nn29shqg2zmqv72i89j1fap41isshida9m";
      type = "gem";
    };
  };

  reline = {
    version = "0.6.3";
    dependencies = [ "io-console" ];

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d8q5c4nh2g9pp758kizh8sfrvngynrjlm0i1zn3cnsnfd4v160i";
      type = "gem";
    };
  };

  rexml = {
    version = "3.4.4";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hninnbvqd2pn40h863lbrn9p11gvdxp928izkag5ysx8b1s5q0r";
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

  rspec-core = {
    version = "3.13.6";
    dependencies = [ "rspec-support" ];

    groups = [
      "default"
      "development"
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
      "development"
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
    version = "3.13.8";

    dependencies = [
      "diff-lcs"
      "rspec-support"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0iqxmw0knjiz5nf6pgr8ihs6cjzh89f0ppj3fqiz8cvms79x6sh8";
      type = "gem";
    };
  };

  rspec-rails = {
    version = "8.0.4";

    dependencies = [
      "actionpack"
      "activesupport"
      "railties"
      "rspec-core"
      "rspec-expectations"
      "rspec-mocks"
      "rspec-support"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pr29snnnlgkqv80vbi4795l6rxq3l47x5rl7lyni4h8zj95c8q6";
      type = "gem";
    };
  };

  rspec-retry = {
    version = "0.6.2";
    dependencies = [ "rspec-core" ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0n6qc0d16h6bgh1xarmc8vc58728mgjcsjj8wcd822c8lcivl0b1";
      type = "gem";
    };
  };

  rspec-support = {
    version = "3.13.7";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z64h5rznm2zv21vjdjshz4v0h7bxvg02yc6g7yzxakj11byah06";
      type = "gem";
    };
  };

  rszr = {
    version = "1.5.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1642s4w153pbfk98h9hv94wdylgp8nv6my3as75wvfpd7yl2ykjh";
      type = "gem";
    };
  };

  rubocop = {
    version = "1.86.1";

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
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ca5inh368d4l24a2v2nbd3p4xc6s0pqs91j27h226nh04zmyha4";
      type = "gem";
    };
  };

  rubocop-ast = {
    version = "1.49.1";

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
      sha256 = "0dahfpnzz63hyqxa03x8rypnrxzwyvh4i5a8ri34bzpnf3pg64j4";
      type = "gem";
    };
  };

  rubocop-capybara = {
    version = "2.23.0";

    dependencies = [
      "lint_roller"
      "rubocop"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mz3mvjh09awggp0bwsmf4rfaz2irrwc6vzpiklfh7jnlyiipspr";
      type = "gem";
    };
  };

  rubocop-factory_bot = {
    version = "2.28.0";

    dependencies = [
      "lint_roller"
      "rubocop"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jzhj9fi1h9rh7z2j6m78hl7c3av36fpacg12wrifi24281gq5sb";
      type = "gem";
    };
  };

  rubocop-faker = {
    version = "1.3.0";

    dependencies = [
      "faker"
      "lint_roller"
      "rubocop"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16swvh7jgx2j8375pvxs5hklvgq08xqzby7rsnv2v7agshrc36nb";
      type = "gem";
    };
  };

  rubocop-graphql = {
    version = "1.6.0";

    dependencies = [
      "lint_roller"
      "rubocop"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ki8lx0x76jrb8kibkjnqc023s0jh1g0v2cmjzzlyf5qrdvqwxv0";
      type = "gem";
    };
  };

  rubocop-inflector = {
    version = "1.0.0";

    dependencies = [
      "activesupport"
      "rubocop"
      "rubocop-rspec"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0sxmmsl0vghkgd4xp5qr56c06kmps6vilxsin0l57iysl61whj3k";
      type = "gem";
    };
  };

  rubocop-performance = {
    version = "1.26.1";

    dependencies = [
      "lint_roller"
      "rubocop"
      "rubocop-ast"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d0qyyw1332afi9glwfjkb4bd62gzlibar6j55cghv8rzwvbj6fd";
      type = "gem";
    };
  };

  rubocop-rails = {
    version = "2.34.3";

    dependencies = [
      "activesupport"
      "lint_roller"
      "rack"
      "rubocop"
      "rubocop-ast"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1llsxc8wm2pq8glpv5mczd1h36fazbri3wwrh7dfqra80a4pklqh";
      type = "gem";
    };
  };

  rubocop-rake = {
    version = "0.7.1";

    dependencies = [
      "lint_roller"
      "rubocop"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kdfrckz1v32dy7c7bdiksjysx9l9zsda9kc6zvrsghch6vg55rp";
      type = "gem";
    };
  };

  rubocop-rspec = {
    version = "3.9.0";

    dependencies = [
      "lint_roller"
      "rubocop"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qjmvcpk6qwxjdh3w5smr2n7c1glxsdzpv5fi7bkg0j034v0m9wg";
      type = "gem";
    };
  };

  rubocop-rspec_rails = {
    version = "2.32.0";

    dependencies = [
      "lint_roller"
      "rubocop"
      "rubocop-rspec"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "004i5a4iww7l3vpaxl70ijypmi321afrslsgadbvksznf8f683aa";
      type = "gem";
    };
  };

  ruby-keycloak-admin = {
    version = "26.5.2";

    dependencies = [
      "hashie"
      "httparty"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1y9kbpl9mnwsnyjhrabhiyjm8l7aa30z0n96rdi8xdbnm3avbmsv";
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
    version = "3.3.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d50hcsix6zrmmijwjx60y4f9n2k0dr6p47cr05qqkrai5kzqwm3";
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

  samovar = {
    version = "2.4.1";

    dependencies = [
      "console"
      "mapping"
    ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "104y60zqn1mznv1smbzzvhljam193w8w2886c2yf6w87b381vff3";
      type = "gem";
    };
  };

  sass-embedded = {
    version = "1.99.0";

    dependencies = [
      "google-protobuf"
      "rake"
    ];

    groups = [
      "assets"
      "default"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qbqaldw9d7l937kr9370q318lrx3lyd95l1d0sz793xvhlj5531";
      type = "gem";
    };
  };

  securerandom = {
    version = "0.4.1";

    groups = [
      "assets"
      "default"
      "development"
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
    version = "4.43.0";

    dependencies = [
      "base64"
      "logger"
      "rexml"
      "rubyzip"
      "websocket"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0p56552x321hgvasdsbz3qgfqd7s10xcw2d0q1m1qw2bjrxkfd56";
      type = "gem";
    };
  };

  shoulda-matchers = {
    version = "7.0.1";
    dependencies = [ "activesupport" ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xwwfj48d6mpc66lhl4yabnjazpf47wqg9n1i9na7q0h9isdigxl";
      type = "gem";
    };
  };

  simple_po_parser = {
    version = "1.1.6";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wybcipkfawg4pragmayiig03xc084x3hbwywsh1dr9x9pa8f9hj";
      type = "gem";
    };
  };

  simpleidn = {
    version = "0.2.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0a9c1mdy12y81ck7mcn9f9i2s2wwzjh1nr92ps354q517zq9dkh8";
      type = "gem";
    };
  };

  slack-ruby-client = {
    version = "3.1.0";

    dependencies = [
      "faraday"
      "faraday-mashify"
      "faraday-multipart"
      "gli"
      "hashie"
      "logger"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wp18wbghc4lpr84fbd6mrj37qlfdj289yv2bkylhv2y0vxwx641";
      type = "gem";
    };
  };

  slop = {
    version = "3.6.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00w8g3j7k7kl8ri2cf1m58ckxk8rn350gp4chfscmgv6pq1spk3n";
      type = "gem";
    };
  };

  snaky_hash = {
    version = "2.0.5";

    dependencies = [
      "hashie"
      "version_gem"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1p9cnbz0fxkfqgpjb5xwwj5pfm969ndbp8shg43fz2kksqvl3rvh";
      type = "gem";
    };
  };

  sprockets = {
    version = "4.2.2";

    dependencies = [
      "concurrent-ruby"
      "logger"
      "rack"
    ];

    groups = [ "assets" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1car3fpzhn1l06x2zmanz2l4bj346mv3jcgpcd3p1262y54ml7kn";
      type = "gem";
    };
  };

  sprockets-rails = {
    version = "3.5.2";

    dependencies = [
      "actionpack"
      "activesupport"
      "sprockets"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17hiqkdpcjyyhlm997mgdcr45v35j5802m5a979i5jgqx5n8xs59";
      type = "gem";
    };
  };

  stringio = {
    version = "3.2.0";

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1q92y9627yisykyscv0bdsrrgyaajc2qr56dwlzx7ysgigjv4z63";
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

  syslog = {
    version = "0.4.0";
    dependencies = [ "logger" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wklh86rhpiff34ja0hda5pwdfywybjvb50hqhz90wpyhblqmhy4";
      type = "gem";
    };
  };

  systemu = {
    version = "2.6.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gmkbakhfci5wnmbfx5i54f25j9zsvbw858yg3jjhfs5n4ad1xq1";
      type = "gem";
    };
  };

  tcr = {
    version = "0.4.1";

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1m7dzia4wwllin385vwhrhyy05gpvklzd9haymd16k87hjyi7d3y";
      type = "gem";
    };
  };

  telegram-bot-ruby = {
    version = "2.7.0";

    dependencies = [
      "dry-struct"
      "faraday"
      "faraday-multipart"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0w8k5620n68axdkrdijcsdyyvlpsx1ag2p7dilb1an0kx1hwhxcw";
      type = "gem";
    };
  };

  telephone_number = {
    version = "1.4.24";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00hr620ifj1002x6886wd1mvs8iqfimyn65pni13asxi05zhy57b";
      type = "gem";
    };
  };

  terser = {
    version = "1.2.7";
    dependencies = [ "execjs" ];
    groups = [ "assets" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06xaqs2gz304x37vmfzi6ns4mzr8i6rqad5cr92arbcxfr4yn4hv";
      type = "gem";
    };
  };

  test-unit = {
    version = "3.7.7";
    dependencies = [ "power_assert" ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0i8ymnz0cnxxkk7g9z2dsnwh411r4i36q5a6k7pnp8ch0vzxb29w";
      type = "gem";
    };
  };

  thor = {
    version = "1.5.0";

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wsy88vg2mazl039392hqrcwvs5nb9kq8jhhrrclir2px1gybag3";
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

  tsort = {
    version = "0.2.0";

    groups = [
      "assets"
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

  twilio-ruby = {
    version = "7.10.5";

    dependencies = [
      "faraday"
      "jwt"
      "nokogiri"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ammns6wi0d8xv95wbx6yljnqazar1b4fp7z78ivx0083rsi21mg";
      type = "gem";
    };
  };

  twitter_cldr = {
    version = "6.14.0";

    dependencies = [
      "base64"
      "camertron-eprun"
      "cldr-plurals-runtime-rb"
      "tzinfo"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1967m253d7yihqjdzvnmhbclkz7xcrbm6q528ajwv2q0jwqc462x";
      type = "gem";
    };
  };

  tzinfo = {
    version = "2.0.6";
    dependencies = [ "concurrent-ruby" ];

    groups = [
      "assets"
      "default"
      "development"
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

  unicode-display_width = {
    version = "3.2.0";
    dependencies = [ "unicode-emoji" ];

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hiwhnqpq271xqari6mg996fgjps42sffm9cpk6ljn8sd2srdp8c";
      type = "gem";
    };
  };

  unicode-emoji = {
    version = "4.2.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03zqn207zypycbz5m9mn7ym763wgpk7hcqbkpx02wrbm1wank7ji";
      type = "gem";
    };
  };

  uri = {
    version = "1.1.1";

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

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
      "assets"
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
    version = "6.4.0";

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rjalag6mjd796idhil076jnqpiv2lc2ljchxc25kz3fq4ncjyh7";
      type = "gem";
    };
  };

  version_gem = {
    version = "1.1.11";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15wwjmzk8y63v1w11lzc6y0pqlb2j040wvjgdfbxrcv2913gcpb9";
      type = "gem";
    };
  };

  viewpoint = {
    version = "1.2.0";

    dependencies = [
      "httpclient"
      "logging"
      "mutex_m"
      "nokogiri"
      "rubyntlm"
      "syslog"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02z2d16yfkkkcighr37mqivnqa5dcls7zazvcxaj318kssmcrdai";
      type = "gem";
    };
  };

  vite_rails = {
    version = "3.11.0";

    dependencies = [
      "railties"
      "vite_ruby"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0md8zry4dvcj436mssd4mf4fmi6n7xsvk9aldyz3yz6xl4db32bf";
      type = "gem";
    };
  };

  vite_ruby = {
    version = "3.10.2";

    dependencies = [
      "dry-cli"
      "logger"
      "mutex_m"
      "rack-proxy"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11lsr9c9v7xpyz0z6yxvw992aaqxcxivm5pmh7fbn2hqxd8m8inv";
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
    version = "3.26.2";

    dependencies = [
      "addressable"
      "crack"
      "hashdiff"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "142cbab47mjxmg8gc89d94sd3h7an9ligh38r9n88wb3xbr5cibp";
      type = "gem";
    };
  };

  websocket = {
    version = "1.2.11";

    groups = [
      "default"
      "development"
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

  whatsapp_sdk = {
    version = "1.1.0";

    dependencies = [
      "faraday"
      "faraday-multipart"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0sq9kj9w828yaqfik5gygbzpnph4mkp32ym1jhh2r3b9kv0kg286";
      type = "gem";
    };
  };

  write_xlsx = {
    version = "1.15.0";

    dependencies = [
      "nkf"
      "rubyzip"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16j37cvk4w2zaha9kdsfi9w8rp5d0bn5rvydi1h2x031fg6c3kv7";
      type = "gem";
    };
  };

  xpath = {
    version = "3.2.0";
    dependencies = [ "nokogiri" ];

    groups = [
      "default"
      "development"
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
    version = "0.9.43";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08aq3im74b20ixmhkpi2dlgsc59231grnzljcahz4pa8y2l371yg";
      type = "gem";
    };
  };

  zeitwerk = {
    version = "2.7.5";

    groups = [
      "assets"
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pbkiwwla5gldgb3saamn91058nl1sq1344l5k36xsh9ih995nnq";
      type = "gem";
    };
  };

  zendesk_api = {
    version = "3.1.1";

    dependencies = [
      "faraday"
      "faraday-multipart"
      "hashie"
      "inflection"
      "mini_mime"
      "multipart-post"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05kjdvi67h26xsfjk550a0b6zwma7jxh4zy4qf6yx7vjcdi68nzq";
      type = "gem";
    };
  };
}
