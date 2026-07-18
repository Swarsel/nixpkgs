{
  action_text-trix = {
    version = "2.1.18";
    dependencies = [ "railties" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hinzgbjfwgdjm3dz9mz218sy764gbacv0z2ic4ms57lpzw87nrz";
      type = "gem";
    };
  };

  actioncable = {
    version = "8.1.3";

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
      sha256 = "1w40bbkjd0lds57bfr24hbj9qfkwj9v33x6457g24sjfwispzg75";
      type = "gem";
    };
  };

  actionmailbox = {
    version = "8.1.3";

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
      sha256 = "0ndf98dpzmz8xs6m253zpwnhyfrvxdkfyvssxps0vrx0x9sa8zfz";
      type = "gem";
    };
  };

  actionmailer = {
    version = "8.1.3";

    dependencies = [
      "actionpack"
      "actionview"
      "activejob"
      "activesupport"
      "mail"
      "rails-dom-testing"
    ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13a4329lgrda8s9mqrfbaakvc90i6ak82rfpljmd0w5vj54747w3";
      type = "gem";
    };
  };

  actionpack = {
    version = "8.1.3";

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
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18r93ii2ayw8n60qsx259dy8nwgbfxf3ndncla0xbia79np8r6dg";
      type = "gem";
    };
  };

  actiontext = {
    version = "8.1.3";

    dependencies = [
      "action_text-trix"
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
      sha256 = "1ln7mwflqf7nsgkj9lm1p7bmc6h8yqaa47q1cdj9xsp102f034fj";
      type = "gem";
    };
  };

  actionview = {
    version = "8.1.3";

    dependencies = [
      "activesupport"
      "builder"
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
      sha256 = "0pgxl9p2q2zbwb6626yw7rgpbmv2bvxykq2w1h83inrygy6chiqk";
      type = "gem";
    };
  };

  activejob = {
    version = "8.1.3";

    dependencies = [
      "activesupport"
      "globalid"
    ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lz8bxb6pcf9yvxwyj6355aws3ylxi5rwc577ly4q858d9vb2jd1";
      type = "gem";
    };
  };

  activemodel = {
    version = "8.1.3";
    dependencies = [ "activesupport" ];

    groups = [
      "default"
      "development"
    ];

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

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1avhmih54xqyj14zrv6ciw2ndpb11bmkwq0fcwm0mfk64ixvw0w0";
      type = "gem";
    };
  };

  activestorage = {
    version = "8.1.3";

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
      sha256 = "0k9q8sdlf576r8rp2hgdxy5lpr8f157bpq8mfsk52f8l169wwr05";
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

    groups = [
      "default"
      "development"
      "test"
    ];

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

  annotaterb = {
    version = "4.22.0";

    dependencies = [
      "activerecord"
      "activesupport"
    ];

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11h2lz0fyj1hh37x1lwvxr0svaisnkjs2g81hap84nwdykjl1z36";
      type = "gem";
    };
  };

  arabic-letter-connector = {
    version = "0.1.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0myhflz0cqn4wz780ar8zdz834n1byvmdvkzp0sfh9yvyy98ngj0";
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
    version = "1.1233.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hhkcawvn8fr5ys7xy4bhk4glcqyyibwkd3y75cidc9d123393cj";
      type = "gem";
    };
  };

  aws-sdk-core = {
    version = "3.244.0";

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
      sha256 = "1shqk9frm15g1ygiy33krwj34jrphfjc6w63bglxwnqcic3qqi9y";
      type = "gem";
    };
  };

  aws-sdk-kms = {
    version = "1.123.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "080zh4g1lcjl0bz2l0gjm8vmpd60cvi0p658bh235ypqh9zg61fl";
      type = "gem";
    };
  };

  aws-sdk-s3 = {
    version = "1.218.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sdk-kms"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "134qr73ri1j52y42xib0fpyscd5miwc37zx1ikxavwh747rsawjn";
      type = "gem";
    };
  };

  aws-sdk-secretsmanager = {
    version = "1.129.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0m69f1jghxlixd4b5wb2dsp38dly7nxm5si1klnajv89m23mqi00";
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

  azure-blob = {
    version = "0.8.0";

    dependencies = [
      "cgi"
      "rexml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "044whzbqmjnyb8ijbx8m7k8377xs780bzmm8yql95ymlr3jm13aw";
      type = "gem";
    };
  };

  base64 = {
    version = "0.3.0";

    groups = [
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

  better_html = {
    version = "2.2.0";

    dependencies = [
      "actionview"
      "activesupport"
      "ast"
      "erubi"
      "parser"
      "smart_properties"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xngv2yj85hiw8lgb4kqp807a41wmbl3bgrv6c4bg5lnn1mbd2p6";
      type = "gem";
    };
  };

  bigdecimal = {
    version = "4.1.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bkcvp4aavdxh1pmgg65sypyjx5l0w5ffylfsk65di1xm9kpgh3d";
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
    version = "1.23.0";
    dependencies = [ "msgpack" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "057jsch213i42qgdsz2vg1b190n2xvvbi3hgprc8nmaqim2ly9f1";
      type = "gem";
    };
  };

  brakeman = {
    version = "8.0.4";
    dependencies = [ "racc" ];
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vyg9l6xivamb49r4kzkcw12r9x943kv79wsvwslhm1qjvx23ybv";
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

  bullet = {
    version = "8.1.0";

    dependencies = [
      "activesupport"
      "uniform_notifier"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zwq7g98c1mdigahb50c980a0fcc4ib1m9ivmgf3f8gc6qk7wjv0";
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

  cancancan = {
    version = "3.6.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qkbqmj8hnljyl108mw7rl44c99xmrhpyaj5m54dzmaqpxf1sp4p";
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

  cmdparse = {
    version = "3.0.7";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0f87jny4zk21iyrkyyw4kpnq8ymrwjay02ipagwapimy237cmigp";
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

  concurrent-ruby = {
    version = "1.3.6";

    groups = [
      "default"
      "development"
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
    version = "3.0.2";

    groups = [
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

  crack = {
    version = "1.0.1";

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
      sha256 = "0zjcdl5i6lw508r01dym05ibhkc784cfn93m1d26c7fk1hwi0jpz";
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

  csv-safe = {
    version = "3.3.1";
    dependencies = [ "csv" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gx7j6976k0hl8nrgy8zw2yw149180djikd5jy0zb2im73649ay2";
      type = "gem";
    };
  };

  cuprite = {
    version = "0.17";

    dependencies = [
      "capybara"
      "ferrum"
    ];

    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ay1azfzslgqzxvgxpz9j7i31m0bbpcmrx5wajnrg2yhf3fdah5i";
      type = "gem";
    };
  };

  date = {
    version = "3.5.1";

    groups = [
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

  debug = {
    version = "1.11.1";

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
      sha256 = "1djjx5332d1hdh9s782dyr0f9d4fr9rllzdcz2k0f8lz2730l2rf";
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

  devise = {
    version = "5.0.3";

    dependencies = [
      "bcrypt"
      "orm_adapter"
      "railties"
      "responders"
      "warden"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ilmy9wgy57nj3zgal4j4vqx15sc7if7yavvah8wwjnw3h2nbh64";
      type = "gem";
    };
  };

  devise-two-factor = {
    version = "6.4.0";

    dependencies = [
      "activesupport"
      "devise"
      "railties"
      "rotp"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1d5day3h573faxsy24h9pbidjm04hs4ql8qxi1wdmrwsbcxs5qq9";
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
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07pj4z3h8wk4fgdn6s62vw1lwvhj0ac0x10vfbdkr9xzk7krn5cn";
      type = "gem";
    };
  };

  dotenv = {
    version = "3.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17b1zr9kih0i3wb7h4yq9i8vi6hjfq07857j437a8z7a44qvhxg3";
      type = "gem";
    };
  };

  drb = {
    version = "2.2.3";

    groups = [
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

  email_typo = {
    version = "0.2.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xwz5dyj4dd4v5rqlk37dkwlkiwnypy7gm4rialmqmmzbmxld5i0";
      type = "gem";
    };
  };

  erb = {
    version = "6.0.4";

    groups = [
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
    version = "3.6.1";
    dependencies = [ "i18n" ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pncl49j3sn6ka53dbf1sw8n0mqlnzh2afwi7ql2dd163lyd44y5";
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

  ferrum = {
    version = "0.17.2";

    dependencies = [
      "addressable"
      "base64"
      "concurrent-ruby"
      "webrick"
      "websocket-driver"
    ];

    groups = [
      "default"
      "test"
    ];

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

  foreman = {
    version = "0.90.0";
    dependencies = [ "thor" ];
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z0i7wn1x5ii3i9q9c4d3ps0d3zfw71llvaaf5caq1xn8wnmwrzz";
      type = "gem";
    };
  };

  geom2d = {
    version = "0.4.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nafcfznjqycxd062cais64ydgl99xddh4zy4hp7bwn4j3m9h2ga";
      type = "gem";
    };
  };

  globalid = {
    version = "1.3.0";
    dependencies = [ "activesupport" ];

    groups = [
      "default"
      "development"
    ];

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
    version = "1.2.1";

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lbw8lqzjv17vnwb9vy5ki4jiyihybcc5h2rmcrqiz1xa6y9s1ww";
      type = "gem";
    };
  };

  hexapdf = {
    version = "1.7.0";

    dependencies = [
      "cmdparse"
      "geom2d"
      "openssl"
      "strscan"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ma1rv2hc51hlji4d3xflx610pq4222bw51sax434b7fayhh55fz";
      type = "gem";
    };
  };

  i18n = {
    version = "1.14.8";
    dependencies = [ "concurrent-ruby" ];

    groups = [
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

  io-console = {
    version = "0.8.2";

    groups = [
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
    version = "1.17.0";

    dependencies = [
      "pp"
      "prism"
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
      sha256 = "1bishrxfn2anwlagw8rzly7i2yicjnr947f48nh638yqjgdlv30n";
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
    version = "2.19.3";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0il6qxkxqql7n7sgrws5bi5a36v51dswqcxb6j6gm8aj62shp6r8";
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

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cnv3ggnzyagl50vzs1693aacv08bhwlprcvjp8jcg2w7cp3zwrg";
      type = "gem";
    };
  };

  letter_opener_web = {
    version = "3.0.0";

    dependencies = [
      "actionmailer"
      "letter_opener"
      "railties"
      "rexml"
    ];

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0q4qfi5wnn5bv93zjf10agmzap3sn7gkfmdbryz296wb1vz1wf9z";
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

  logger = {
    version = "1.7.0";

    groups = [
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

  lograge = {
    version = "0.14.0";

    dependencies = [
      "actionpack"
      "activesupport"
      "railties"
      "request_store"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qcsvh9k4c0cp6agqm9a8m4x2gg7vifryqr7yxkg2x9ph9silds2";
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

  mail = {
    version = "2.9.0";

    dependencies = [
      "logger"
      "mini_mime"
      "net-imap"
      "net-pop"
      "net-smtp"
    ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ha9sgkfqna62c1basc17dkx91yk7ppgjq32k4nhrikirlz6g9kg";
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
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nscas3a4mmrp1rc07cdjlbbpb2rydkindmbj3v3z5y1viyspmd0";
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

  mini_magick = {
    version = "5.3.1";
    dependencies = [ "logger" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1i2ilgjfjqc6sw4cwa4g9w3ngs41yvvazr9y82vapp5sfvymsf99";
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
    version = "6.0.3";

    dependencies = [
      "drb"
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
      sha256 = "048ls6kn009jkwj1rvka2b5vnwq73b0krjz740j6j03cwcfqmb48";
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
    version = "1.19.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1drisvysgvnjlz49a0qcbs294id6mvj3i8iik5rvym68ybwfzvvs";
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
    version = "0.6.4";

    dependencies = [
      "date"
      "net-protocol"
    ];

    groups = [
      "default"
      "development"
    ];

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

    groups = [
      "default"
      "development"
    ];

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

    groups = [
      "default"
      "development"
    ];

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

    groups = [
      "default"
      "development"
    ];

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

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1s30b7h7qpyim30m8060xs415mbr3ci7i5hdg09chh1aqfx2qcbq";
      type = "gem";
    };
  };

  numo-narray-alt = {
    version = "0.10.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vh20lxy5gsdr4an994s0d4h1d5bfbhmlr63gw15n3ghcf31mc07";
      type = "gem";
    };
  };

  oj = {
    version = "3.16.16";

    dependencies = [
      "bigdecimal"
      "ostruct"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0g817hjx1rh4zhvcpb9m6lr6l8yyq3n8vnjm9x1rc5wr51hv6d9n";
      type = "gem";
    };
  };

  onnxruntime = {
    version = "0.10.1";
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0c8l82qff7vd6whh0ks1f72734gmghzm0h2hvy2gnnp7y8j7amhq";
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

  orm_adapter = {
    version = "0.5.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fg9jpjlzf5y49qs9mlpdrgs5rpcyihq1s4k79nv9js0spjhnpda";
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
    version = "0.6.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04nrir9wdpc4izqwqbysxyly8y7hsfr4fsv69rw91lfi9d5fv8lm";
      type = "gem";
    };
  };

  package_json = {
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kbb3c898vgqqs38imhgivh2nv4s9jlc27jzhdzfbacr57f25h4j";
      type = "gem";
    };
  };

  pagy = {
    version = "43.4.4";

    dependencies = [
      "json"
      "uri"
      "yaml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xmywpn5zj99708zhmxx2xf76fnwwffrxa3648igvaqai8r5f6ml";
      type = "gem";
    };
  };

  parallel = {
    version = "1.28.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0w697335hi5dk5ay9kyn53399sy87y8v0y6ij93m5wmshhadxrik";
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
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16caca7lcz5pwl82snarqrayjj9j7abmxqw92267blhk7rbd120k";
      type = "gem";
    };
  };

  pp = {
    version = "0.6.3";
    dependencies = [ "prettyprint" ];

    groups = [
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

  pretender = {
    version = "1.0.0";
    dependencies = [ "actionpack" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0a0n8imhm4m3y3ql8l4ncx3k8krlx5sz4wy4s99dp09jillg953x";
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
    version = "1.9.0";

    groups = [
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

  pry-rails = {
    version = "0.3.11";
    dependencies = [ "pry" ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0garafb0lxbm3sx2r9pqgs7ky9al58cl3wmwc0gmvmrl9bi2i7m6";
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
    version = "7.2.0";
    dependencies = [ "nio4r" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1a3jd9qakasizrf7dkq5mqv51fjf02r2chybai2nskjaa6mz93mz";
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
    version = "2.3.1";
    dependencies = [ "rack" ];

    groups = [
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
    version = "8.1.3";

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
      sha256 = "1lww7i686rm9s50d34hb596y2kfl46dida2kjy8gr64c6jjpn0bd";
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
    version = "8.1.0";

    dependencies = [
      "i18n"
      "railties"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wvcbdslb5gfvs9dw7kscd9da3xfyr3mdh1w4a28vwmy19ngvmaj";
      type = "gem";
    };
  };

  railties = {
    version = "8.1.3";

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
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08nyhsigcvjpj9i3r0s73yi8zm16sxmr2x7xgxlaq2jjrghb0gli";
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
    version = "13.3.1";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "175iisqb211n0qbfyqd8jz2g01q6xj038zjf4q0nm8k6kz88k7lc";
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
    version = "2.11.3";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "192mzi0wgwl024pwpbfa6c2a2xlvbh3mjd75a0sakdvkl60z64ya";
      type = "gem";
    };
  };

  reline = {
    version = "0.6.3";
    dependencies = [ "io-console" ];

    groups = [
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

  request_store = {
    version = "1.7.0";
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jw89j9s5p5cq2k7ffj5p4av4j4fxwvwjs1a4i9g85d38r9mvdz1";
      type = "gem";
    };
  };

  responders = {
    version = "3.2.0";

    dependencies = [
      "actionpack"
      "railties"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0npm7nyld47f516idsmslfhypp7gm3jcl90ml5c68vz11anddhl9";
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

  rouge = {
    version = "4.7.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fd77qcz603mli4lyi97cjzkv02hsfk60m495qv5qcn02mkqk9fv";
      type = "gem";
    };
  };

  rqrcode = {
    version = "3.2.0";

    dependencies = [
      "chunky_png"
      "rqrcode_core"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hlm1cfqs891irh4pl6wynsfm7nh7w7baf0g6cqxfrxvlr64khb4";
      type = "gem";
    };
  };

  rqrcode_core = {
    version = "2.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l9hl5nb7jx8sjchsrlv6bk30hywr449ihcdxv2qy6wwz1fvh0zk";
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

  rubocop = {
    version = "1.86.0";

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
      sha256 = "11nicljvmns665vryhfdrpssnk5dn1mxdap7ynprpgkfw5piiwag";
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

  ruby-vips = {
    version = "2.3.0";

    dependencies = [
      "ffi"
      "logger"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0x2k5x272m2zs0vmznl2jac14bj9a2g0365xxcnr2s9rq41fr1g6";
      type = "gem";
    };
  };

  rubyXL = {
    version = "3.4.35";

    dependencies = [
      "nokogiri"
      "rubyzip"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "071zgcwxyxip6j0s8hnvw9iy2k85liy0z1rph52an28hjmcdkrr0";
      type = "gem";
    };
  };

  rubyzip = {
    version = "3.2.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0g2vx9bwl9lgn3w5zacl52ax57k4zqrsxg05ixf42986bww9kvf0";
      type = "gem";
    };
  };

  securerandom = {
    version = "0.4.1";

    groups = [
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

  semantic_range = {
    version = "3.1.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1af49rikvc0m4mf6asjyb601195hgvgx8ycmwwrvmizhdqck70sh";
      type = "gem";
    };
  };

  shakapacker = {
    version = "9.7.0";

    dependencies = [
      "activesupport"
      "package_json"
      "rack-proxy"
      "railties"
      "semantic_range"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kxji9yj8vga2qbgg8x1m3j74w8n21rqqz60f33q9kwzaabby9j1";
      type = "gem";
    };
  };

  sidekiq = {
    version = "8.1.2";

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
      sha256 = "1szw72f2k9vyyi81c9rv1rj91s849j6jxwvvsxsxdnmi5gr6c4ja";
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

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "198kcbrjxhhzca19yrdcd6jjj9sb51aaic3b0sc3pwjghg3j49py";
      type = "gem";
    };
  };

  simplecov-html = {
    version = "0.13.2";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ikjfwydgs08nm3xzc4cn4b6z6rmcrj2imp84xcnimy2wxa8w2xx";
      type = "gem";
    };
  };

  simplecov_json_formatter = {
    version = "0.1.4";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0a5l0733hj7sk51j81ykfmlk2vd5vaijlq9d5fn165yyx3xii52j";
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

  sqlite3 = {
    version = "2.9.2";
    dependencies = [ "mini_portile2" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cbkgb5s3qsfjgnp75habwxsi97711jg90yh52ihcssbf58430c6";
      type = "gem";
    };
  };

  stringio = {
    version = "3.2.0";

    groups = [
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

  strip_attributes = {
    version = "2.0.1";
    dependencies = [ "activemodel" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12vyza5diwpakf4b6kgkr99kgbvz3bcrp9v0zkzxxbk9zhrvhk30";
      type = "gem";
    };
  };

  strscan = {
    version = "3.1.8";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17k75zrwf4ag9yl9wjjkcb90zrm4r5jigdzv3zr5jm9239hxpqma";
      type = "gem";
    };
  };

  thor = {
    version = "1.5.0";

    groups = [
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

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jxcji88mh6xsqz0mfzwnxczpg7cyniph7wpavnavfz7lxl77xbq";
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

  trilogy = {
    version = "2.12.2";
    dependencies = [ "bigdecimal" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0m5d1v0gsdh8m24bxc8hw7gypf9l56zkdy1lfaca7a9ix12n463m";
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

  turbo-rails = {
    version = "2.0.23";

    dependencies = [
      "actionpack"
      "railties"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0priz7ww23h2j9j5zicc4np3rr357n01xw8zymn0bzxg79rr03gf";
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
    version = "1.2026.1";
    dependencies = [ "tzinfo" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1z896q8kzig9x6g3bcp38apns05y36jhf4j7ml7wzqjsmqcnb8sf";
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

  uniform_notifier = {
    version = "1.18.0";

    groups = [
      "default"
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17ffzyq6482yn27r7rz2k3zslf9jigbz383d90c68vznarapi1s7";
      type = "gem";
    };
  };

  uri = {
    version = "1.1.1";

    groups = [
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

  warden = {
    version = "1.2.9";
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1l7gl7vms023w4clg02pm4ky9j12la2vzsixi2xrv9imbn44ys26";
      type = "gem";
    };
  };

  web-console = {
    version = "4.3.0";

    dependencies = [
      "actionview"
      "bindex"
      "railties"
    ];

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "193ddancfznc34qp2bqz5mkv906v4aka6njv2lzhkhnz3hq72fz1";
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

    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "142cbab47mjxmg8gc89d94sd3h7an9ligh38r9n88wb3xbr5cibp";
      type = "gem";
    };
  };

  webrick = {
    version = "1.9.2";

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ca1hr2rxrfw7s613rp4r4bxb454i3ylzniv9b9gxpklqigs3d5y";
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
      "test"
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
      "test"
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

  yaml = {
    version = "0.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hhr8z9m9yq2kf7ls0vf8ap1hqma1yd72y2r13b88dffwv8nj3i4";
      type = "gem";
    };
  };

  zeitwerk = {
    version = "2.7.5";

    groups = [
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
}
