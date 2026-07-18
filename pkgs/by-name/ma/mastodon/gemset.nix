{
  action_text-trix = {
    version = "2.1.19";
    dependencies = [ "railties" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02a0yz97d12cf6wcj5r43ak57mhlcj4r84k5ma2g570046aga4kh";
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
      "pam_authentication"
      "production"
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
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pgxl9p2q2zbwb6626yw7rgpbmv2bvxykq2w1h83inrygy6chiqk";
      type = "gem";
    };
  };

  active_model_serializers = {
    version = "0.10.16";

    dependencies = [
      "actionpack"
      "activemodel"
      "case_transform"
      "jsonapi-renderer"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06h6rknvpapvx8l4sfd72msi422fghhchmqd1jn8zh7a4wd3gdma";
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
      "test"
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
      "test"
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
      "pam_authentication"
      "production"
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

  ast = {
    version = "2.4.3";

    groups = [
      "default"
      "development"
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
    version = "1.1259.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ihq7k01fwayf4ir0n6g99r7s8xja1rnr55p9agfdqffhlzwaq8s";
      type = "gem";
    };
  };

  aws-sdk-core = {
    version = "3.252.0";

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
      sha256 = "074awkbb7rs9332vvxifxndrjambxf1bkj8w8hwj5krazk5l5h09";
      type = "gem";
    };
  };

  aws-sdk-kms = {
    version = "1.129.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hrkb8ar61zgswz16rcf1x00n1liwn236lh5zpya9x11yf6m8grn";
      type = "gem";
    };
  };

  aws-sdk-s3 = {
    version = "1.225.1";

    dependencies = [
      "aws-sdk-core"
      "aws-sdk-kms"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04k5wasssinx66vws2jn4vhzfisg30mkhbdmcs3m99dhp66kmcnl";
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
    version = "0.5.9.1";
    dependencies = [ "rexml" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "198ndg8m0w54csxb3fidzpjp491ak9jcrmjc8zmp7axi0ncvbsmx";
      type = "gem";
    };
  };

  base64 = {
    version = "0.3.0";

    groups = [
      "default"
      "development"
      "pam_authentication"
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

  bcp47_spec = {
    version = "0.2.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "043qld01c163yc7fxlar3046dac2833rlcg44jbbs9n1jvgjxmiz";
      type = "gem";
    };
  };

  bcrypt = {
    version = "3.1.22";

    groups = [
      "default"
      "pam_authentication"
    ];

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
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v1337j39w1z7x9zs4q7ag0nfv4vs4xlsjx2la0wpv8s6hig2pa6";
      type = "gem";
    };
  };

  better_errors = {
    version = "2.10.1";

    dependencies = [
      "erubi"
      "rack"
      "rouge"
    ];

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wqazisnn6hn1wsza412xribpw5wzx6b5z5p4mcpfgizr6xg367p";
      type = "gem";
    };
  };

  bigdecimal = {
    version = "3.3.1";

    groups = [
      "default"
      "development"
      "opentelemetry"
      "pam_authentication"
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

  binding_of_caller = {
    version = "2.0.0";
    dependencies = [ "debug_inspector" ];
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05yma8qd0c53dalkh2b9iddvi7j1wy1kmd77xmx5i1ca8bwfngp5";
      type = "gem";
    };
  };

  blurhash = {
    version = "0.1.8";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wni86h2mlb7sj51nq3iwsvkrzlaggls9xlf4p9dzr1ns79dphca";
      type = "gem";
    };
  };

  bootsnap = {
    version = "1.24.6";
    dependencies = [ "msgpack" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jhnvalyqhjv10y2m804z2s9wabmys4a4di6187jjch3qy4an2y6";
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
      "default"
      "development"
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pw3r2lyagsxkm71bf44v5b74f7l9r7di22brbyji9fwz791hya9";
      type = "gem";
    };
  };

  bundler-audit = {
    version = "0.9.3";
    dependencies = [ "thor" ];
    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1sdlr4rj7x5nbrl8zkd3dqdg4fc50bnpx37rl0l0szg4f5n7dj41";
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

  capybara-playwright-driver = {
    version = "0.5.9";

    dependencies = [
      "addressable"
      "capybara"
      "playwright-ruby-client"
    ];

    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10kj1rh8w3qk6mg6kap1gh0p5kgmgdp1ij6gwayy3dqp139gw5sc";
      type = "gem";
    };
  };

  case_transform = {
    version = "0.2";
    dependencies = [ "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fzyws6spn5arqf6q604dh9mrj84a36k5hsc8z7jgcpfvhc49bg2";
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

  chewy = {
    version = "8.4.1";

    dependencies = [
      "activesupport"
      "elasticsearch"
      "elasticsearch-dsl"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1clkjg3n7c29c01cykjp6gbnvywjilfanzcrcrazhzf551ssndy6";
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

  cocoon = {
    version = "1.2.15";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "038z97pkhvsqbh6cmyyzj58ya968p24k7r0f0rx7sa2kjvk193yh";
      type = "gem";
    };
  };

  color_diff = {
    version = "0.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "094hvvpr7x7m6qq3yhmnzv7yv5clmmps1fy1rply10j6gcl1wpyf";
      type = "gem";
    };
  };

  concurrent-ruby = {
    version = "1.3.7";

    groups = [
      "default"
      "development"
      "pam_authentication"
      "production"
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
      "default"
      "development"
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02ifws3c4x7b54fv17sm4cca18d2pfw1saxpdji2lbd1f6xgbzrk";
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
    version = "1.0.7";

    groups = [
      "default"
      "development"
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15djj19ynz3sbw54fsf8n7y3sha8a333f2mgvjfwhr46jhcqg1ll";
      type = "gem";
    };
  };

  css_parser = {
    version = "3.0.0";

    dependencies = [
      "addressable"
      "ssrf_filter"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "119q8j23xyb9pifka1n6jjrw04099zpwwdajh5pd10fm7wlfkw7a";
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

  database_cleaner-active_record = {
    version = "2.2.2";

    dependencies = [
      "activerecord"
      "database_cleaner-core"
    ];

    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1203q6zdw14vwmnr2hw0d6b1rdz4d07w3kjg1my1zhw862gnnac8";
      type = "gem";
    };
  };

  database_cleaner-core = {
    version = "2.1.0";

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09v9zfbslyay5d15dv7jyqwhh9f504z8i736idp72sxjv5k551xj";
      type = "gem";
    };
  };

  date = {
    version = "3.5.1";

    groups = [
      "default"
      "development"
      "pam_authentication"
      "production"
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

  debug_inspector = {
    version = "1.2.0";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18k8x9viqlkh7dbmjzh8crbjy8w480arpa766cw1dnn3xcpa1pwv";
      type = "gem";
    };
  };

  devise = {
    version = "5.0.4";

    dependencies = [
      "bcrypt"
      "orm_adapter"
      "railties"
      "responders"
      "warden"
    ];

    groups = [
      "default"
      "pam_authentication"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hacqyck22k7g9qr9n5wwq32vg02hwwjv7kqxrb4xrslb2wg41fn";
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

  devise_pam_authenticatable2 = {
    version = "9.2.0";

    dependencies = [
      "devise"
      "rpam2"
    ];

    groups = [ "pam_authentication" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13ipl52pkhc6vxp8ca31viwv01237bi2bfk3b1fixq1x46nf87p2";
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

  discard = {
    version = "2.0.0";
    dependencies = [ "activerecord" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1h6j62g1rbwvhq27sabxrv942giwn7dxmcxjm0g9nysdddw21i8g";
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

  domain_name = {
    version = "0.6.20240107";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cyr2xm576gqhqicsyqnhanni47408w2pgvrfi8pd13h2li3nsaz";
      type = "gem";
    };
  };

  doorkeeper = {
    version = "5.9.2";
    dependencies = [ "railties" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xyk49b88pcxrc08lgawkp5x57kxgyfwa3wgdbisy4jz13h46jnd";
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
      "pam_authentication"
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

  elastic-transport = {
    version = "8.5.2";

    dependencies = [
      "faraday"
      "multi_json"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hsg41zd1dkwc9frx35d9hhvbhdj0h71fs236xql8n70m9a6vdas";
      type = "gem";
    };
  };

  elasticsearch = {
    version = "8.19.3";

    dependencies = [
      "elastic-transport"
      "elasticsearch-api"
      "ostruct"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "167b9m3hqyc4g77kx7a9xbzd566hdnvwwcyfidvk0dx9fd82gq1z";
      type = "gem";
    };
  };

  elasticsearch-api = {
    version = "8.19.3";
    dependencies = [ "multi_json" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wklwh659c0faknzaqlfihl8ai3b52hwip69m2izk0ncjssjk06w";
      type = "gem";
    };
  };

  elasticsearch-dsl = {
    version = "0.1.10";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "174m3fwm3mawbkjg2xbmqvljq7ava4s95m8vpg5khcvfj506wxfk";
      type = "gem";
    };
  };

  erb = {
    version = "6.0.4";

    groups = [
      "default"
      "development"
      "pam_authentication"
      "production"
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
      "default"
      "development"
      "pam_authentication"
      "production"
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
    version = "1.4.0";
    dependencies = [ "tzinfo" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1g785lz4z2k7jrdl7bnnjllzfrwpv9pyki94ngizj8cqfy83qzkc";
      type = "gem";
    };
  };

  excon = {
    version = "1.5.0";
    dependencies = [ "logger" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l3dpg45i74ap1d7c4wyrdlc67l9vj4kgzv2l2r8mg1304fss0y5";
      type = "gem";
    };
  };

  fabrication = {
    version = "3.0.0";

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qrv8vvhjx9yi64bji6hrp08if14hmwdy08prg9qld3ij2nvz856";
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

    groups = [ "default" ];
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

  faraday-httpclient = {
    version = "2.0.2";
    dependencies = [ "httpclient" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z6nv0cxxk9rm69x84861f5zn8jck99prmjpg4apxa75rihbwpyr";
      type = "gem";
    };
  };

  faraday-net_http = {
    version = "3.4.4";
    dependencies = [ "net-http" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "125m3qri52vwh5v9dhq0dkqxf8629cxrf99yyc01pva72wasyy0f";
      type = "gem";
    };
  };

  fast_blank = {
    version = "1.0.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1shpmamyzyhyxmv95r96ja5rylzaw60r19647d0fdm7y2h2c77r6";
      type = "gem";
    };
  };

  fastimage = {
    version = "2.4.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "085d82jw6swv4k6jxya85q7rg3vjzy2nw7hcnwx99n3gdgafnjy6";
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

  flatware = {
    version = "2.4.0";

    dependencies = [
      "benchmark"
      "drb"
      "logger"
      "thor"
    ];

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0na5w1krrrmd9vkv43v30k43d880hs9yz2zr3qfwxcjk1mq3nqk7";
      type = "gem";
    };
  };

  flatware-rspec = {
    version = "2.4.0";

    dependencies = [
      "flatware"
      "rspec"
    ];

    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0f19309xgbc6y008g6bkwjxq7962dspwr31lsznx7pdxp7x98x2w";
      type = "gem";
    };
  };

  fog-core = {
    version = "2.6.0";

    dependencies = [
      "builder"
      "excon"
      "formatador"
      "mime-types"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rjv4iqr64arxv07bh84zzbr1y081h21592b5zjdrk937al8mq1z";
      type = "gem";
    };
  };

  fog-json = {
    version = "1.3.0";

    dependencies = [
      "fog-core"
      "multi_json"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05x2pvzdzwh5g7z1s5592k3dg3bfidfamc7zxqngj50w4bmlyblc";
      type = "gem";
    };
  };

  fog-openstack = {
    version = "1.1.5";

    dependencies = [
      "fog-core"
      "fog-json"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0imx2c7yrwnd1jk6xzh5903cazymfvs3iq37dl49jss1a2d2lis6";
      type = "gem";
    };
  };

  formatador = {
    version = "1.2.3";
    dependencies = [ "reline" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "156qa2wiizmdalz6cim04yaasdz1q6c6k7yhnpdnrhn26f0qkyhr";
      type = "gem";
    };
  };

  forwardable = {
    version = "1.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0f78rjpnhm4lgp1qzadnr6kr02b6afh1lvy7w607k4qjk3641kgi";
      type = "gem";
    };
  };

  fugit = {
    version = "1.12.2";

    dependencies = [
      "et-orbi"
      "raabro"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0phfqbch9pll4cny2c5ipna9nb3bnzc0v3mz1i0bsqxjipr2ngv4";
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

  google-protobuf = {
    version = "4.35.0";

    dependencies = [
      "bigdecimal"
      "rake"
    ];

    groups = [
      "default"
      "opentelemetry"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "038cqc1kzxl22m3jfspkdpg0dxskga9jvgwclb4pivcjqxi62d4m";
      type = "gem";
    };
  };

  googleapis-common-protos-types = {
    version = "1.23.0";
    dependencies = [ "google-protobuf" ];

    groups = [
      "default"
      "opentelemetry"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02mg1y34ccwf4bkhz4vcl6m3giwgbm309999bzydk51pa8578blr";
      type = "gem";
    };
  };

  haml = {
    version = "7.2.0";

    dependencies = [
      "temple"
      "thor"
      "tilt"
    ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nnmzj6g2wynxbrp9j885zab4nkzfryhl2bv6cj1gazyyxqjpzc7";
      type = "gem";
    };
  };

  haml-rails = {
    version = "3.0.0";

    dependencies = [
      "actionpack"
      "activesupport"
      "haml"
      "railties"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0psqln0xs2hkcziag6m9fiwsaxyg3q7vazy8rbcj39awm2bf87q9";
      type = "gem";
    };
  };

  haml_lint = {
    version = "0.73.0";

    dependencies = [
      "haml"
      "parallel"
      "rainbow"
      "rubocop"
      "sysexits"
    ];

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gfp0q98kfv5j68xqv2nydh64yqlwi29bl9ing212z7djc0d54fz";
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

  hashie = {
    version = "5.1.0";
    dependencies = [ "logger" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0w1qrab701d3a63aj2qavwc2fpcqmkzzh1w2x93c88zkjqc4frn2";
      type = "gem";
    };
  };

  hcaptcha = {
    version = "7.1.0";
    dependencies = [ "json" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fh6391zlv2ikvzqj2gymb70k1avk1j9da8bzgw0scsz2wqq98m2";
      type = "gem";
    };
  };

  highline = {
    version = "3.1.2";
    dependencies = [ "reline" ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jmvyhjp2v3iq47la7w6psrxbprnbnmzz0hxxski3vzn356x7jv7";
      type = "gem";
    };
  };

  hiredis-client = {
    version = "0.29.0";
    dependencies = [ "redis-client" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1v2wa2797xsjx5j96dbnd9ll0sbxrfg5xwwk022fx3p6qp0m3nns";
      type = "gem";
    };
  };

  hkdf = {
    version = "0.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04fixg0a51n4vy0j6c1hvisa2yl33m3jrrpxpb5sq6j511vjriil";
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

  http = {
    version = "5.3.1";

    dependencies = [
      "addressable"
      "http-cookie"
      "http-form_data"
      "llhttp-ffi"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z8x4c2bcg05x7ffrjy47cwarfqzlg8kcfxchk5jcfdyx7c04265";
      type = "gem";
    };
  };

  http-cookie = {
    version = "1.1.6";
    dependencies = [ "domain_name" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1aga7z4p0dka4zcqw9i05wa4ab1q7h7cgnj328ldqqfycjz84jxs";
      type = "gem";
    };
  };

  http-form_data = {
    version = "2.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wx591jdhy84901pklh1n9sgh74gnvq1qyqxwchni1yrc49ynknc";
      type = "gem";
    };
  };

  http_accept_language = {
    version = "2.1.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d0nlfz9vm4jr1l6q0chx4rp2hrnrfbx3gadc1dz930lbbaz0hq0";
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

  httplog = {
    version = "1.8.0";

    dependencies = [
      "benchmark"
      "rack"
      "rainbow"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gq7cra0d9h5mc1295h3xknqwany9xbxasgliyq6axr74rmbs51b";
      type = "gem";
    };
  };

  i18n = {
    version = "1.15.1";
    dependencies = [ "concurrent-ruby" ];

    groups = [
      "default"
      "development"
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mbjg75bsnpf3mr5ad3425wi2ps9r809gvr8n0n8lv2f3zgcapjh";
      type = "gem";
    };
  };

  i18n-tasks = {
    version = "1.1.2";

    dependencies = [
      "activesupport"
      "ast"
      "erubi"
      "highline"
      "i18n"
      "parser"
      "prism"
      "rails-i18n"
      "rainbow"
      "ruby-progressbar"
      "terminal-table"
    ];

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yk3lgzmym02bvpqhvccrfjvnkyqh35idcqwcqq3yqiawm4vmksd";
      type = "gem";
    };
  };

  idn-ruby = {
    version = "0.1.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dy04jx3n1ddz744b80mg7hp87miysnjp0h21lqr43hpmhdglxih";
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
    version = "0.8.2";

    groups = [
      "default"
      "development"
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k0lk3pwadm2myvpg893n8jshmrf2sigrd4ki15lymy7gixaxqyn";
      type = "gem";
    };
  };

  ipaddr = {
    version = "1.2.9";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1dyy0g6cycszq2xsrcx3kxq3fa3zyxx9kxxcs8dgipj55rxqm18g";
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
      "default"
      "development"
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qs8a9vprg7s8krgq4s0pygr91hclqqyz98ik15p0m1sf2h5956y";
      type = "gem";
    };
  };

  jd-paperclip-azure = {
    version = "3.0.0";

    dependencies = [
      "addressable"
      "azure-blob"
      "hashie"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gcikrlqv6r9pqvw2kfyvmia3rikp9irhq1c10njz4z7i5za4xk9";
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
    version = "2.19.8";

    groups = [
      "default"
      "development"
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1anz6a6n33x4s3906s0bz6x161kk1ns3h7xxsn3rpxkfsw7k2m33";
      type = "gem";
    };
  };

  json-canonicalization = {
    version = "1.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0illsmkly0hhi24lm1l6jjjdr6jykvydkwi1cxf4ad3mra68m16l";
      type = "gem";
    };
  };

  json-jwt = {
    version = "1.17.1";

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
      sha256 = "0ihz7l0yqyd5rlk2j4s9jy0nlhn10djrxqgygrb4qsr0gc7ys72y";
      type = "gem";
    };
  };

  json-ld = {
    version = "3.3.2";

    dependencies = [
      "htmlentities"
      "json-canonicalization"
      "link_header"
      "multi_json"
      "rack"
      "rdf"
      "rexml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09xbw6kc95qgmqcfjp0jjw8dnfm28lw9b5lf8bdh3p2vpy9ihlxr";
      type = "gem";
    };
  };

  json-ld-preloaded = {
    version = "3.3.2";

    dependencies = [
      "json-ld"
      "rdf"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1q8y2f9c9940sgqdb57zmlbhjx3rvmq2l8kpi3a9bgzkx8kl6aa6";
      type = "gem";
    };
  };

  json-schema = {
    version = "6.2.0";

    dependencies = [
      "addressable"
      "bigdecimal"
    ];

    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rinh4347nvl9jm0r4mk7gi1zh1iz367w3dxn8d2r8j5v1pg9gz8";
      type = "gem";
    };
  };

  jsonapi-renderer = {
    version = "0.2.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ys4drd0k9rw5ixf8n8fx8v0pjh792w4myh0cpdspd317l1lpi5m";
      type = "gem";
    };
  };

  jwt = {
    version = "2.10.3";
    dependencies = [ "base64" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "115ll278g3zdvff7b05gfxqc9n74vw9xfzcc8jkv22bkphpkbng4";
      type = "gem";
    };
  };

  kaminari = {
    version = "1.2.2";

    dependencies = [
      "activesupport"
      "kaminari-actionview"
      "kaminari-activerecord"
      "kaminari-core"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gia8irryvfhcr6bsr64kpisbgdbqjsqfgrk12a11incmpwny1y4";
      type = "gem";
    };
  };

  kaminari-actionview = {
    version = "1.2.2";

    dependencies = [
      "actionview"
      "kaminari-core"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02f9ghl3a9b5q7l079d3yzmqjwkr4jigi7sldbps992rigygcc0k";
      type = "gem";
    };
  };

  kaminari-activerecord = {
    version = "1.2.2";

    dependencies = [
      "activerecord"
      "kaminari-core"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0c148z97s1cqivzbwrak149z7kl1rdmj7dxk6rpkasimmdxsdlqd";
      type = "gem";
    };
  };

  kaminari-core = {
    version = "1.2.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zw3pg6kj39y7jxakbx7if59pl28lhk98fx71ks5lr3hfgn6zliv";
      type = "gem";
    };
  };

  kt-paperclip = {
    version = "7.3.0";

    dependencies = [
      "activemodel"
      "activesupport"
      "marcel"
      "mime-types"
      "terrapin"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1456pfk271q10fv064kk15536n5sp9l44mqx9y0wjlzml1mx1bpw";
      type = "gem";
    };
  };

  language_server-protocol = {
    version = "3.17.0.5";

    groups = [
      "default"
      "development"
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

  link_header = {
    version = "0.0.8";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yamrdq4rywmnpdhbygnkkl9fdy249fg5r851nrkkxr97gj5rihm";
      type = "gem";
    };
  };

  lint_roller = {
    version = "1.1.0";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11yc0d84hsnlvx8cpk4cbj6a4dz9pk0r1k29p0n1fz9acddq831c";
      type = "gem";
    };
  };

  linzer = {
    version = "0.7.9";

    dependencies = [
      "cgi"
      "forwardable"
      "logger"
      "net-http"
      "rack"
      "starry"
      "uri"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0254dp4l0p2v8jh90gc1z88vvk7zsdyqahv8w7b77ckpfvjy8k4a";
      type = "gem";
    };
  };

  llhttp-ffi = {
    version = "0.5.1";

    dependencies = [
      "ffi-compiler"
      "rake"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1g57iw0l3y7x50132x6a1jyssxa6pw7srh69g0d6j7ri37yaf9cs";
      type = "gem";
    };
  };

  logger = {
    version = "1.7.0";

    groups = [
      "default"
      "development"
      "opentelemetry"
      "pam_authentication"
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

  lograge = {
    version = "0.14.0";

    dependencies = [
      "actionpack"
      "activesupport"
      "railties"
      "request_store"
    ];

    groups = [ "production" ];
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
      "pam_authentication"
      "production"
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
    version = "1.0.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "190n2mk8m1l708kr88fh6mip9sdsh339d2s6sgrik3sbnvz4jmhd";
      type = "gem";
    };
  };

  mario-redis-lock = {
    version = "1.2.1";
    dependencies = [ "redis" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1v9wdjcjqzpns2migxp4a5b4w82mipi0fwihbqz3q2qj2qm7wc17";
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

  memory_profiler = {
    version = "1.1.0";

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1y58ba08n4lx123c0hjcc752fc4x802mjy39qj1hq50ak3vpv8br";
      type = "gem";
    };
  };

  mime-types = {
    version = "3.7.0";

    dependencies = [
      "logger"
      "mime-types-data"
    ];

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mjyxl7c0xzyqdqa8r45hqg7jcw2prp3hkp39mdf223g4hfgdsyw";
      type = "gem";
    };
  };

  mime-types-data = {
    version = "3.2026.0414";

    groups = [
      "default"
      "test"
    ];

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
      "default"
      "development"
      "pam_authentication"
      "production"
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
    version = "6.0.6";

    dependencies = [
      "drb"
      "prism"
    ];

    groups = [
      "default"
      "development"
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wfnqyfayx9n9j7x871v2ars4hjhfisi1dl24fa64ylq3mns6ghm";
      type = "gem";
    };
  };

  msgpack = {
    version = "1.8.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18g6ps30z6m365bly7sfialavnsf6m6qamdxsr84w96k51j4mnlb";
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
    version = "0.6.4.1";

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
    version = "1.19.4";

    dependencies = [
      "mini_portile2"
      "racc"
    ];

    groups = [
      "default"
      "development"
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1d9safb4dly6qmc2g06444l0zifby52yy6j1a5fa1g4j3ihm3jah";
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

  omniauth-cas = {
    version = "3.0.2";

    dependencies = [
      "addressable"
      "nokogiri"
      "omniauth"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03b034imgj5jwflc4db7hsp0n5ivqyqkmsfhc5drlidrcdfv2f0q";
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
    version = "2.5.0";

    dependencies = [
      "activemodel"
      "attr_required"
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
      sha256 = "1i1rksidmf0aj0z6y89mhyp3fadf4xgpx0znwfc7g470vj7gz6k5";
      type = "gem";
    };
  };

  openssl = {
    version = "4.0.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hj7wwp4r3jhvnyd8ik85wbs25cq1w61r28pv6ddyn5fd0lasdqh";
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

  opentelemetry-api = {
    version = "1.10.0";
    dependencies = [ "logger" ];

    groups = [
      "default"
      "opentelemetry"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1adzcv93ccs4bnjqvjwr5ma3gmv0l7v9pvhpm0qiqf0qkf17rvlr";
      type = "gem";
    };
  };

  opentelemetry-common = {
    version = "0.25.0";
    dependencies = [ "opentelemetry-api" ];

    groups = [
      "default"
      "opentelemetry"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "178ly4bh8hpi5bdmy4i74m22bxz1mvyspqfb5b4pycwdwmi574bk";
      type = "gem";
    };
  };

  opentelemetry-exporter-otlp = {
    version = "0.34.0";

    dependencies = [
      "google-protobuf"
      "googleapis-common-protos-types"
      "opentelemetry-api"
      "opentelemetry-common"
      "opentelemetry-sdk"
      "opentelemetry-semantic_conventions"
    ];

    groups = [ "opentelemetry" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0q1a3spgyzcr0cf06c50nkn87ygrp09pz744klwg8c5s551xyg1v";
      type = "gem";
    };
  };

  opentelemetry-helpers-sql = {
    version = "0.4.0";
    dependencies = [ "opentelemetry-api" ];

    groups = [
      "default"
      "opentelemetry"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yqa891zajjpaph2a25s4n5ycnfwxzjb7fsiz65aja6a5hx8q3mi";
      type = "gem";
    };
  };

  opentelemetry-helpers-sql-processor = {
    version = "0.5.0";

    dependencies = [
      "opentelemetry-api"
      "opentelemetry-common"
    ];

    groups = [
      "default"
      "opentelemetry"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wg0s0ydbc69g6irw8f24z5d86dg6144abqby3cwn7s5r4dj96di";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-action_mailer = {
    version = "0.8.1";
    dependencies = [ "opentelemetry-instrumentation-active_support" ];

    groups = [
      "default"
      "opentelemetry"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "029bhz8gqf89bwsm29zw3m7cw97dy8f1hf9k9r5jh3yy875889rg";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-action_pack = {
    version = "0.18.0";
    dependencies = [ "opentelemetry-instrumentation-rack" ];

    groups = [
      "default"
      "opentelemetry"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10anpln7i3vs5ry5ly02biz32h9ab6c7iwx409yrylqmdf12rflh";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-action_view = {
    version = "0.13.0";
    dependencies = [ "opentelemetry-instrumentation-active_support" ];

    groups = [
      "default"
      "opentelemetry"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0s0mgwqmch5d1cww3qsrily38gfciqijsj6l4z2p4f8ls485d1av";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-active_job = {
    version = "0.12.0";
    dependencies = [ "opentelemetry-instrumentation-base" ];
    groups = [ "opentelemetry" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14mr1l7a8x15khkqr8n0y94s5dj6c48hg4qxc1nq1l2w73ykcgyb";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-active_model_serializers = {
    version = "0.25.0";
    dependencies = [ "opentelemetry-instrumentation-active_support" ];
    groups = [ "opentelemetry" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mvag13gjqg38grmg6a7slr7n3pxx8v2di8zbx1gy6kq717h1fwq";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-active_record = {
    version = "0.13.0";
    dependencies = [ "opentelemetry-instrumentation-base" ];

    groups = [
      "default"
      "opentelemetry"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16d2ngy10qd3bsdpgh6sb0ha7gl830xwcyyqkpfq4bm4wnmcx7r3";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-active_storage = {
    version = "0.5.1";
    dependencies = [ "opentelemetry-instrumentation-active_support" ];

    groups = [
      "default"
      "opentelemetry"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nwvsvid7ma31l85nn75wg3a3rplwbklrnrgql0bzdjd321apjvs";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-active_support = {
    version = "0.12.0";
    dependencies = [ "opentelemetry-instrumentation-base" ];

    groups = [
      "default"
      "opentelemetry"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0177isfxbr3zb1aas1ajibnp2yqn26mrv0ly9hps9m5angfcp8i9";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-base = {
    version = "0.26.1";

    dependencies = [
      "opentelemetry-api"
      "opentelemetry-common"
      "opentelemetry-registry"
    ];

    groups = [
      "default"
      "opentelemetry"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0x9pcz49iga988jabg9kkc6mk37dlk6a955plss166jyarfx7s29";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-concurrent_ruby = {
    version = "0.25.0";
    dependencies = [ "opentelemetry-instrumentation-base" ];
    groups = [ "opentelemetry" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bbvpwn70d12fsdc31w1qnc7ah82aw4bdl159al2ac4f0zki4abj";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-excon = {
    version = "0.29.1";
    dependencies = [ "opentelemetry-instrumentation-base" ];
    groups = [ "opentelemetry" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1inkzvkn57yf4xvl0iiyh2p1sg6drfknxq5qnlfyh168yr91r7vs";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-faraday = {
    version = "0.33.0";
    dependencies = [ "opentelemetry-instrumentation-base" ];
    groups = [ "opentelemetry" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00gqhgbya6hcl7h9rklg0h69mf4r4ksyl8555g7bi5srwgn0ncpl";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-http = {
    version = "0.30.0";
    dependencies = [ "opentelemetry-instrumentation-base" ];
    groups = [ "opentelemetry" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1j2m21smk0wfcjwi64ls2mas520qwcgxkq4rbsr8dlw1mfg67lin";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-http_client = {
    version = "0.29.0";
    dependencies = [ "opentelemetry-instrumentation-base" ];
    groups = [ "opentelemetry" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0g9xg7vk8s06y83bg8jckwz35md2g0q4h72m5sq6qa54lw53ydlj";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-net_http = {
    version = "0.29.0";
    dependencies = [ "opentelemetry-instrumentation-base" ];
    groups = [ "opentelemetry" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rsgz3rx4gs8ng544grm62w2pzaw9nvl68vm2pxqggsbg5mfprgs";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-pg = {
    version = "0.36.0";

    dependencies = [
      "opentelemetry-helpers-sql"
      "opentelemetry-helpers-sql-processor"
      "opentelemetry-instrumentation-base"
    ];

    groups = [ "opentelemetry" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ixf7fr3qgsmdzn22xprwd04i27gmhp13b104z557h3p8f66yd7p";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-rack = {
    version = "0.31.1";
    dependencies = [ "opentelemetry-instrumentation-base" ];
    groups = [ "opentelemetry" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0sjk2ngdd8cq40p4gnqzln0vaabwg04l4crhiy9s4gvdrr2w3a99";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-rails = {
    version = "0.42.0";

    dependencies = [
      "opentelemetry-instrumentation-action_mailer"
      "opentelemetry-instrumentation-action_pack"
      "opentelemetry-instrumentation-action_view"
      "opentelemetry-instrumentation-active_job"
      "opentelemetry-instrumentation-active_record"
      "opentelemetry-instrumentation-active_storage"
      "opentelemetry-instrumentation-active_support"
      "opentelemetry-instrumentation-concurrent_ruby"
    ];

    groups = [ "opentelemetry" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1czqxavga9djkaw60i56ivljh75d3d3kgwzcljgywwyaff1q18sy";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-redis = {
    version = "0.29.0";
    dependencies = [ "opentelemetry-instrumentation-base" ];
    groups = [ "opentelemetry" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1v25jpq6s68qb5r7i5alr6jma57kx9and13yz6ggfwkzzwqmv1az";
      type = "gem";
    };
  };

  opentelemetry-instrumentation-sidekiq = {
    version = "0.29.0";
    dependencies = [ "opentelemetry-instrumentation-base" ];
    groups = [ "opentelemetry" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1p5av36xg4imnq54cn971s3pzl1xkvcr8z7y751f39a1j35s1lmi";
      type = "gem";
    };
  };

  opentelemetry-registry = {
    version = "0.6.0";
    dependencies = [ "opentelemetry-api" ];

    groups = [
      "default"
      "opentelemetry"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0a57k220mf0mx1d4fyr61c2a84ddc6xx1w6l63dzpq7fp4md6gjx";
      type = "gem";
    };
  };

  opentelemetry-sdk = {
    version = "1.12.0";

    dependencies = [
      "logger"
      "opentelemetry-api"
      "opentelemetry-common"
      "opentelemetry-registry"
      "opentelemetry-semantic_conventions"
    ];

    groups = [ "opentelemetry" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jw6ig29c1rjmv8mw16dxw3kk118km6n675cnwfd88whqphan952";
      type = "gem";
    };
  };

  opentelemetry-semantic_conventions = {
    version = "1.39.0";
    dependencies = [ "opentelemetry-api" ];

    groups = [
      "default"
      "opentelemetry"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jh5qaqmcvsvf6x1v73zy77fz5mhrwp7syl8gnbs8h4vk58cyil9";
      type = "gem";
    };
  };

  orm_adapter = {
    version = "0.5.0";

    groups = [
      "default"
      "pam_authentication"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fg9jpjlzf5y49qs9mlpdrgs5rpcyihq1s4k79nv9js0spjhnpda";
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

  ox = {
    version = "2.14.27";
    dependencies = [ "bigdecimal" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "174v7f6wjkhygpp6dr0vbka03v0h5kxdfkgsilbyi0pf4ihz112y";
      type = "gem";
    };
  };

  parallel = {
    version = "2.1.0";

    groups = [
      "default"
      "development"
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
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0m2xqvn1la62hji1mn04y59giikww95p2hs0r4y2rrz3mdxcwyni";
      type = "gem";
    };
  };

  parslet = {
    version = "2.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01pnw6ymz6nynklqvqxs4bcai25kcvnd5x4id9z3vd1rbmlk0lfl";
      type = "gem";
    };
  };

  pastel = {
    version = "0.8.0";
    dependencies = [ "tty-color" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xash2gj08dfjvq4hy6l1z22s5v30fhizwgs10d6nviggpxsj7a8";
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

  pghero = {
    version = "3.8.0";
    dependencies = [ "activerecord" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0q5kmfy1rgax98ivkcl5fy7lrz1zd8v9bf2cjm9x2asw15xaizgn";
      type = "gem";
    };
  };

  playwright-ruby-client = {
    version = "1.60.0";

    dependencies = [
      "base64"
      "concurrent-ruby"
      "mime-types"
    ];

    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ls8r49d27j0ffpfva99nk53a4nk17f4k71x44hpny8f2gb448ll";
      type = "gem";
    };
  };

  pp = {
    version = "0.6.3";
    dependencies = [ "prettyprint" ];

    groups = [
      "default"
      "development"
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xlxmg86k5kifci1xvlmgw56x88dmqf04zfzn7zcr4qb8ladal99";
      type = "gem";
    };
  };

  premailer = {
    version = "1.29.0";

    dependencies = [
      "addressable"
      "css_parser"
      "htmlentities"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "181x3nk1pz9fhydj7zf5zhg1grglxaiqd249zm3ks7vh432k0pq1";
      type = "gem";
    };
  };

  premailer-rails = {
    version = "1.12.0";

    dependencies = [
      "actionmailer"
      "net-smtp"
      "premailer"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0004f73kgrglida336fqkgx906m6n05nnfc17mypzg5rc78iaf61";
      type = "gem";
    };
  };

  prettyprint = {
    version = "0.2.0";

    groups = [
      "default"
      "development"
      "pam_authentication"
      "production"
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
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11ggfikcs1lv17nhmhqyyp6z8nq5pkfcj6a904047hljkxm0qlvv";
      type = "gem";
    };
  };

  prometheus_exporter = {
    version = "2.3.1";
    dependencies = [ "webrick" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "013azj8pmmn6fsj1grnq0960pzb5zbpzmv1f2mdm2frsdjjaf0f5";
      type = "gem";
    };
  };

  propshaft = {
    version = "1.3.2";

    dependencies = [
      "actionpack"
      "activesupport"
      "rack"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17iqn4sa59c9z5y3bpvxqka00srqnl379w6a57y1phljdbjs6mhx";
      type = "gem";
    };
  };

  psych = {
    version = "5.4.0";

    dependencies = [
      "date"
      "stringio"
    ];

    groups = [
      "default"
      "development"
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1dx5bc3s1mb1i53np4cdkypg7ccygnvagr3hglyndbqilrljvxql";
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
    groups = [ "default" ];
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
      "pam_authentication"
      "production"
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
      "pam_authentication"
      "production"
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
    version = "0.8.2";
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1c0sw5l6v80ffrv8ac70v5l6q8118p96qb0xshkycx5ybj36w26k";
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
      "pam_authentication"
      "production"
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
      "pam_authentication"
      "production"
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
      "pam_authentication"
      "production"
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
      "pam_authentication"
      "production"
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
      "pam_authentication"
      "production"
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

    groups = [
      "default"
      "development"
    ];

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
      "pam_authentication"
      "production"
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
      "default"
      "development"
      "opentelemetry"
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "009p524zl0p0kfa65nii8wdmaigkmawv9pbvlcffky7islmmp0nb";
      type = "gem";
    };
  };

  rdf = {
    version = "3.3.4";

    dependencies = [
      "bcp47_spec"
      "bigdecimal"
      "link_header"
      "logger"
      "ostruct"
      "readline"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1har1346p7jwrs89d5w1gv98jk2nh3cwkdyvkzm2nkjv3s1a0zx7";
      type = "gem";
    };
  };

  rdf-normalize = {
    version = "0.7.0";
    dependencies = [ "rdf" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1glyhg7lmzbq1w7bvvf84g7kvqxcn0mw3gsh1f8w4qfvvnbl8dwj";
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
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14iiyb4yi1chdzrynrk74xbhmikml3ixgdayjma3p700singfl46";
      type = "gem";
    };
  };

  readline = {
    version = "0.0.4";
    dependencies = [ "reline" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0shxkj3kbwl43rpg490k826ibdcwpxiymhvjnsc85fg2ggqywf31";
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

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18xy2nd8mcb186gqd11sy3vfwkq5n85mq26v7l325jkdiwgvyr8c";
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
      "default"
      "development"
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d8q5c4nh2g9pp758kizh8sfrvngynrjlm0i1zn3cnsnfd4v160i";
      type = "gem";
    };
  };

  request_store = {
    version = "1.7.0";
    dependencies = [ "rack" ];

    groups = [
      "default"
      "production"
    ];

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

    groups = [
      "default"
      "pam_authentication"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0npm7nyld47f516idsmslfhypp7gm3jcl90ml5c68vz11anddhl9";
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
    version = "5.0.0";
    dependencies = [ "strscan" ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1g2y2z07niw4ylbgf6zr6a7kjaqbaqxn98xwff58zf4w5yx9ppp2";
      type = "gem";
    };
  };

  rpam2 = {
    version = "4.0.2";

    groups = [
      "default"
      "pam_authentication"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zvli3s4z1hf2l7gyfickm5i3afjrnycc3ihbiax6ji6arpbyf33";
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

  rspec = {
    version = "3.13.2";

    dependencies = [
      "rspec-core"
      "rspec-expectations"
      "rspec-mocks"
    ];

    groups = [
      "default"
      "test"
    ];

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

  rspec-github = {
    version = "3.0.0";
    dependencies = [ "rspec-core" ];
    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bv8b6ld7w3rccjnxqypfdg35i91wyv551sr41647r6krbc3rbs6";
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

  rspec-sidekiq = {
    version = "5.3.0";

    dependencies = [
      "rspec-core"
      "rspec-expectations"
      "rspec-mocks"
      "sidekiq"
    ];

    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1imkvngglyd3vs2k526fffb5g22a08bwgjhdd1nq1jb7hym0b554";
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
    version = "1.87.0";

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

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "138qbhxb6r8qyq6kz38i3wq4k2rdcrhfcyicxzw1798na7sxvndr";
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

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mz3mvjh09awggp0bwsmf4rfaz2irrwc6vzpiklfh7jnlyiipspr";
      type = "gem";
    };
  };

  rubocop-i18n = {
    version = "3.3.0";

    dependencies = [
      "lint_roller"
      "rubocop"
    ];

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0sx970650mnw2pivf8bx251lnni2w3c2n39cjqs9xsy9x9x9gmbc";
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

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d0qyyw1332afi9glwfjkb4bd62gzlibar6j55cghv8rzwvbj6fd";
      type = "gem";
    };
  };

  rubocop-rails = {
    version = "2.35.4";

    dependencies = [
      "activesupport"
      "lint_roller"
      "rack"
      "rubocop"
      "rubocop-ast"
    ];

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xaxlfas5grja3lvzjrfiv86ah3rxa15cmi7hc79b2cw8cjs7sis";
      type = "gem";
    };
  };

  rubocop-rspec = {
    version = "3.10.2";

    dependencies = [
      "lint_roller"
      "regexp_parser"
      "rubocop"
    ];

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qk5bx4vg7n17i9475h6dqkhay9m3s6vanq9y35hxl9cb762wghb";
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

    groups = [ "development" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "004i5a4iww7l3vpaxl70ijypmi321afrslsgadbvksznf8f683aa";
      type = "gem";
    };
  };

  ruby-prof = {
    version = "2.0.4";

    dependencies = [
      "base64"
      "ostruct"
    ];

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d8lbpqw6hlrb5xy5h39f7pi68a4hczgd7dkb2fml18fhzv0y6a2";
      type = "gem";
    };
  };

  ruby-progressbar = {
    version = "1.13.0";

    groups = [
      "default"
      "development"
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

  rubyzip = {
    version = "3.3.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0khy3d43cr2i4x9as2k41ckrjb4wkpcycdbzaara4fy4qw923n9f";
      type = "gem";
    };
  };

  rufus-scheduler = {
    version = "3.9.2";
    dependencies = [ "fugit" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1f932ffh6v6gqpilm61rp9fcx6qcpax1fkw0ikrxfsgzn16rxyjm";
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

  sanitize = {
    version = "7.0.0";

    dependencies = [
      "crass"
      "nokogiri"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "111r4xdcf6ihdnrs6wkfc6nqdzrjq0z69x9sf83r7ri6fffip796";
      type = "gem";
    };
  };

  scenic = {
    version = "1.9.0";

    dependencies = [
      "activerecord"
      "railties"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nb3an8af7f08jnhhbn8bxvgfxqb43qc9d5hgrz16ams96h3mv3f";
      type = "gem";
    };
  };

  securerandom = {
    version = "0.4.1";

    groups = [
      "default"
      "development"
      "pam_authentication"
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

  shoulda-matchers = {
    version = "7.0.1";
    dependencies = [ "activesupport" ];
    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xwwfj48d6mpc66lhl4yabnjazpf47wqg9n1i9na7q0h9isdigxl";
      type = "gem";
    };
  };

  sidekiq = {
    version = "8.1.6";

    dependencies = [
      "connection_pool"
      "json"
      "logger"
      "rack"
      "redis-client"
    ];

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03z48p8asbid67lmlsn12njk1gdb6xqibabyz5na3c94242ws85y";
      type = "gem";
    };
  };

  sidekiq-bulk = {
    version = "0.2.0";
    dependencies = [ "sidekiq" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08nyxzmgf742irafy3l4fj09d4s5pyvsh0dzlh8y4hl51rgkh4xv";
      type = "gem";
    };
  };

  sidekiq-scheduler = {
    version = "6.0.2";

    dependencies = [
      "rufus-scheduler"
      "sidekiq"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1z6nl9aazi904qmc4vasxkb4w44c6cs1ygfjw6fq8l77i6lz2r8h";
      type = "gem";
    };
  };

  sidekiq-unique-jobs = {
    version = "8.1.0";

    dependencies = [
      "concurrent-ruby"
      "sidekiq"
      "thor"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dfwcz1v2a0xn41xm1glwb56ll3vd02zj39m8ajrg0a0mihslzka";
      type = "gem";
    };
  };

  simple-navigation = {
    version = "4.4.1";

    dependencies = [
      "activesupport"
      "ostruct"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11n460b89q3zzirkcmg9ln0rqzlfmq247ygyl4vppmjlbcm7aq3v";
      type = "gem";
    };
  };

  simple_form = {
    version = "5.4.1";

    dependencies = [
      "actionpack"
      "activemodel"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0208na2s7q1hny77v78b6h677vrhy2v72cjw0d2mazjc0clx5hsq";
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
    version = "0.13.2";

    groups = [
      "default"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ikjfwydgs08nm3xzc4cn4b6z6rmcrj2imp84xcnimy2wxa8w2xx";
      type = "gem";
    };
  };

  simplecov-lcov = {
    version = "0.9.0";
    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ka6cdwywd6a6pqjwggm0439437xdq2r7514n3a5wn8a40ga6xvs";
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

  ssrf_filter = {
    version = "1.5.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xlpb8y555frl82cx4q2i922mps36mmn0ajk21kpy3bks6wwsgg0";
      type = "gem";
    };
  };

  stackprof = {
    version = "0.2.28";

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "014s1zxlxcw35shislar3y1i3mqa0c6gh3m21js14q1q5zharhjf";
      type = "gem";
    };
  };

  starry = {
    version = "0.2.0";
    dependencies = [ "base64" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1c99sj460hdshiv2jps5d4mxcvz7nrvqznfpgcbnjhk9cnhv15i6";
      type = "gem";
    };
  };

  stoplight = {
    version = "5.8.2";

    dependencies = [
      "concurrent-ruby"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mhnm73jix2khvba81sxc7580sn5iflkb9kynag1xprsgbrafwl0";
      type = "gem";
    };
  };

  stringio = {
    version = "3.2.0";

    groups = [
      "default"
      "development"
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1q92y9627yisykyscv0bdsrrgyaajc2qr56dwlzx7ysgigjv4z63";
      type = "gem";
    };
  };

  strong_migrations = {
    version = "2.8.0";
    dependencies = [ "activerecord" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fa4hxwi075xxcfb93lfc6wja67nlrbqs2bn1sf3w3z6c20hz76b";
      type = "gem";
    };
  };

  strscan = {
    version = "3.1.8";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17k75zrwf4ag9yl9wjjkcb90zrm4r5jigdzv3zr5jm9239hxpqma";
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

  sysexits = {
    version = "1.2.0";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qjng6pllznmprzx8vb0zg0c86hdrkyjs615q41s9fjpmv2430jr";
      type = "gem";
    };
  };

  temple = {
    version = "0.10.4";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0b7pzx45f1vg6f53midy70ndlmb0k4k03zp4nsq8l0q9dx5yk8dp";
      type = "gem";
    };
  };

  terminal-table = {
    version = "4.0.0";
    dependencies = [ "unicode-display_width" ];

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lh18gwpksk25sbcjgh94vmfw2rz0lrq61n7lwp1n9gq0cr7j17m";
      type = "gem";
    };
  };

  terrapin = {
    version = "1.1.1";
    dependencies = [ "climate_control" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0aakswgqk6cfamq3h6fxdls81ia7v3fi1v825i5pdrgzbh293blw";
      type = "gem";
    };
  };

  test-prof = {
    version = "1.6.1";

    groups = [
      "development"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17j9cai2ykcndgn0800m9nb297sx0lpminxj8bcqw4bwkb1xjch3";
      type = "gem";
    };
  };

  thor = {
    version = "1.5.0";

    groups = [
      "default"
      "development"
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wsy88vg2mazl039392hqrcwvs5nb9kq8jhhrrclir2px1gybag3";
      type = "gem";
    };
  };

  tilt = {
    version = "2.7.0";

    groups = [
      "default"
      "development"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cvaikq1dcbfl008i16c1pi1gmdax7vfkvmhch64jdkakyk9nnqd";
      type = "gem";
    };
  };

  timeout = {
    version = "0.6.1";

    groups = [
      "default"
      "development"
      "test"
    ];

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
      "default"
      "development"
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17q8h020dw73wjmql50lqw5ddsngg67jfw8ncjv476l5ys9sfl4n";
      type = "gem";
    };
  };

  tty-color = {
    version = "0.6.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0aik4kmhwwrmkysha7qibi2nyzb4c8kp42bd5vxnf8sf7b53g73g";
      type = "gem";
    };
  };

  tty-cursor = {
    version = "0.7.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0j5zw041jgkmn605ya1zc151bxgxl6v192v2i26qhxx7ws2l2lvr";
      type = "gem";
    };
  };

  tty-prompt = {
    version = "0.23.1";

    dependencies = [
      "pastel"
      "tty-reader"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1j4y8ik82azjxshgd4i1v4wwhsv3g9cngpygxqkkz69qaa8cxnzw";
      type = "gem";
    };
  };

  tty-reader = {
    version = "0.9.0";

    dependencies = [
      "tty-cursor"
      "tty-screen"
      "wisper"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cf2k7w7d84hshg4kzrjvk9pkyc2g1m3nx2n1rpmdcf0hp4p4af6";
      type = "gem";
    };
  };

  tty-screen = {
    version = "0.8.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l4vh6g333jxm9lakilkva2gn17j6gb052626r1pdbmy2lhnb460";
      type = "gem";
    };
  };

  twitter-text = {
    version = "3.1.0";

    dependencies = [
      "idn-ruby"
      "unf"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1dnmp0bj3l01nbb52zby2c7hrazcdwfg846knkrjdfl0yfmv793z";
      type = "gem";
    };
  };

  tzinfo = {
    version = "2.0.6";
    dependencies = [ "concurrent-ruby" ];

    groups = [
      "default"
      "development"
      "pam_authentication"
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
    version = "0.0.9.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1sf6bxvf6x8gihv6j63iakixmdddgls58cpxpg32chckb2l18qcj";
      type = "gem";
    };
  };

  unicode-display_width = {
    version = "3.2.0";
    dependencies = [ "unicode-emoji" ];

    groups = [
      "default"
      "development"
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
      "default"
      "development"
      "pam_authentication"
      "production"
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
      "pam_authentication"
      "production"
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

  warden = {
    version = "1.2.9";
    dependencies = [ "rack" ];

    groups = [
      "default"
      "pam_authentication"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1l7gl7vms023w4clg02pm4ky9j12la2vzsixi2xrv9imbn44ys26";
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

    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "142cbab47mjxmg8gc89d94sd3h7an9ligh38r9n88wb3xbr5cibp";
      type = "gem";
    };
  };

  webpush = {
    version = "1.1.0";

    dependencies = [
      "hkdf"
      "jwt"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      fetchSubmodules = false;
      rev = "9631ac63045cfabddacc69fc06e919b4c13eb913";
      sha256 = "01vqsj9162j0rzp455sggr8k4w4i9zq0igqb7x7hghp3c53ck1v6";
      type = "git";
      url = "https://github.com/mastodon/webpush.git";
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

  websocket-driver = {
    version = "0.8.1";

    dependencies = [
      "base64"
      "websocket-extensions"
    ];

    groups = [ "test" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15idgibqpdaj97f734drx8a7k1jcc8wvxlk2nbafac72ihikicjs";
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

  wisper = {
    version = "2.0.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rpsi0ziy78cj82sbyyywby4d0aw0a5q84v65qd28vqn79fbq5yf";
      type = "gem";
    };
  };

  xorcist = {
    version = "1.1.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1dbbiy8xlcfvn9ais37xfb5rci4liwakkmxzbkp72wmvlgcrf339";
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

  zeitwerk = {
    version = "2.8.2";

    groups = [
      "default"
      "development"
      "pam_authentication"
      "production"
      "test"
    ];

    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04hx33lsnp4q0qf8982mz0acs1dap5s2bsmihi0n0g08249sc4kj";
      type = "gem";
    };
  };
}
