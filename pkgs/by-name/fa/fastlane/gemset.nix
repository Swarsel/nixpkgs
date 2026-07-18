{
  CFPropertyList = {
    version = "3.0.8";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qa226xndfs9r6c7qj7zs6yhzrcbmicvvxsjn9x3svakh3cx169c";
      type = "gem";
    };
  };

  abbrev = {
    version = "0.1.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hj2qyx7rzpc7awhvqlm597x7qdxwi4kkml4aqnp5jylmsm4w6xd";
      type = "gem";
    };
  };

  addressable = {
    version = "2.8.9";
    dependencies = [ "public_suffix" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11ali533wx91fh93xlk88gjqq8w0p7kxw09nlh41hwc9wv5ly5fc";
      type = "gem";
    };
  };

  artifactory = {
    version = "3.0.17";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qzj389l2a3zig040h882mf6cxfa71pm2nk51l4p85n3ck4xa8rh";
      type = "gem";
    };
  };

  atomos = {
    version = "0.1.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17vq6sjyswr5jfzwdccw748kgph6bdw30bakwnn6p8sl4hpv4hvx";
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

  babosa = {
    version = "1.0.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16dwqn33kmxkqkv51cwiikdkbrdjfsymlnc0rgbjwilmym8a9phq";
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
    version = "4.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bkcvp4aavdxh1pmgg65sypyjx5l0w5ffylfsk65di1xm9kpgh3d";
      type = "gem";
    };
  };

  claide = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bpqhc0kqjp1bh9b7ffc395l9gfls0337rrhmab4v46ykl45qg3d";
      type = "gem";
    };
  };

  colored = {
    version = "1.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0b0x5jmsyi0z69bm6sij1k89z7h0laag3cb4mdn7zkl9qmxb90lx";
      type = "gem";
    };
  };

  colored2 = {
    version = "3.1.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jlbqa9q4mvrm73aw9mxh23ygzbjiqwisl32d8szfb5fxvbjng5i";
      type = "gem";
    };
  };

  commander = {
    version = "4.6.0";
    dependencies = [ "highline" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1n8k547hqq9hvbyqbx2qi08g0bky20bbjca1df8cqq5frhzxq7bx";
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

  dotenv = {
    version = "2.8.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1n0pi8x8ql5h1mijvm8lgn6bhq4xjb5a500p5r1krq4s6j9lg565";
      type = "gem";
    };
  };

  emoji_regex = {
    version = "3.2.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jsnrkfy345v66jlm2xrz8znivfnamg3mfzkddn414bndf2vxn7c";
      type = "gem";
    };
  };

  excon = {
    version = "0.112.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1w7098hnyby5sn2315qy26as6kxlxivxlcrs714amj9g9hxaryfs";
      type = "gem";
    };
  };

  faraday = {
    version = "1.10.5";

    dependencies = [
      "faraday-em_http"
      "faraday-em_synchrony"
      "faraday-excon"
      "faraday-httpclient"
      "faraday-multipart"
      "faraday-net_http"
      "faraday-net_http_persistent"
      "faraday-patron"
      "faraday-rack"
      "faraday-retry"
      "ruby2_keywords"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vgnx245yp2fg0fr3bixp4lcqhqn7rr35xdm42l2yra5n39g2i5i";
      type = "gem";
    };
  };

  faraday-cookie_jar = {
    version = "0.0.8";

    dependencies = [
      "faraday"
      "http-cookie"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fwx5720g33w3zycyq636m4fbn5fd94fxk4g0b3n7k7q4dc60h01";
      type = "gem";
    };
  };

  faraday-em_http = {
    version = "1.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12cnqpbak4vhikrh2cdn94assh3yxza8rq2p9w2j34bqg5q4qgbs";
      type = "gem";
    };
  };

  faraday-em_synchrony = {
    version = "1.0.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l0pz1wk2mk6p6hbfd86jfad59jyk201y1db379qhc2lrxfy8g5z";
      type = "gem";
    };
  };

  faraday-excon = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0h09wkb0k0bhm6dqsd47ac601qiaah8qdzjh8gvxfd376x1chmdh";
      type = "gem";
    };
  };

  faraday-httpclient = {
    version = "1.0.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fyk0jd3ks7fdn8nv3spnwjpzx2lmxmg2gh4inz3by1zjzqg33sc";
      type = "gem";
    };
  };

  faraday-multipart = {
    version = "1.2.0";
    dependencies = [ "multipart-post" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mzp9rlqiryyi99bm9ii80hfsbbafh9wl8r3c5pif51pd54sk2bx";
      type = "gem";
    };
  };

  faraday-net_http = {
    version = "1.0.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10n6wikd442mfm15hd6gzm0qb527161w1wwch4h5m4iclkz2x6b3";
      type = "gem";
    };
  };

  faraday-net_http_persistent = {
    version = "1.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dc36ih95qw3rlccffcb0vgxjhmipsvxhn6cw71l7ffs0f7vq30b";
      type = "gem";
    };
  };

  faraday-patron = {
    version = "1.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19wgsgfq0xkski1g7m96snv39la3zxz6x7nbdgiwhg5v82rxfb6w";
      type = "gem";
    };
  };

  faraday-rack = {
    version = "1.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1h184g4vqql5jv9s9im6igy00jp6mrah2h14py6mpf9bkabfqq7g";
      type = "gem";
    };
  };

  faraday-retry = {
    version = "1.0.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ahnsyy5f0f9qqna8883z4m10b2x19nfbzy2d5ngkavzfwrr4rfw";
      type = "gem";
    };
  };

  faraday_middleware = {
    version = "1.2.1";
    dependencies = [ "faraday" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1s990pnapb3vci9c00bklqc7jjix4i2zhxn2zf1lfk46xv47hnyl";
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

  fastlane = {
    version = "2.232.2";

    dependencies = [
      "CFPropertyList"
      "abbrev"
      "addressable"
      "artifactory"
      "aws-sdk-s3"
      "babosa"
      "base64"
      "benchmark"
      "colored"
      "commander"
      "csv"
      "dotenv"
      "emoji_regex"
      "excon"
      "faraday"
      "faraday-cookie_jar"
      "faraday_middleware"
      "fastimage"
      "fastlane-sirp"
      "gh_inspector"
      "google-apis-androidpublisher_v3"
      "google-apis-playcustomapp_v1"
      "google-cloud-env"
      "google-cloud-storage"
      "highline"
      "http-cookie"
      "json"
      "jwt"
      "logger"
      "mini_magick"
      "multipart-post"
      "mutex_m"
      "naturally"
      "nkf"
      "optparse"
      "ostruct"
      "plist"
      "rubyzip"
      "security"
      "simctl"
      "terminal-notifier"
      "terminal-table"
      "tty-screen"
      "tty-spinner"
      "word_wrap"
      "xcodeproj"
      "xcpretty"
      "xcpretty-travis-formatter"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04misa8c6msjjsc1fz11a9drznjfpq9fz1nyk53dbhqg1zv8k1lp";
      type = "gem";
    };
  };

  fastlane-sirp = {
    version = "1.0.0";
    dependencies = [ "sysrandom" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hg6ql3g25f96fsmwr9xlxpn8afa7wvjampnrh1fqffhphjqyiv6";
      type = "gem";
    };
  };

  gh_inspector = {
    version = "1.1.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0f8r9byajj3bi2c7c5sqrc7m0zrv3nblfcd4782lw5l73cbsgk04";
      type = "gem";
    };
  };

  google-apis-androidpublisher_v3 = {
    version = "0.98.0";
    dependencies = [ "google-apis-core" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jy5r35j4jxq2kv6dqnv7aijyskfr7h6dyjddk0k24cw859bjkq9";
      type = "gem";
    };
  };

  google-apis-core = {
    version = "0.18.0";

    dependencies = [
      "addressable"
      "googleauth"
      "httpclient"
      "mini_mime"
      "mutex_m"
      "representable"
      "retriable"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vjls3xdzphphay0z3wmv2lw4zxbiv3vbmcy2d4b9spfdy0mgc4n";
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

  google-apis-playcustomapp_v1 = {
    version = "0.17.0";
    dependencies = [ "google-apis-core" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0y2sm5zwm45a3n188nk8w5771ghakd28d04rnjx65y7k0nvr1g6m";
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
    version = "2.1.1";
    dependencies = [ "faraday" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16b9yjbrzal1cjkdbn29fl06ikjn1dpg1vdsjak1xvhpsp3vhjyg";
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

  googleauth = {
    version = "1.11.2";

    dependencies = [
      "faraday"
      "google-cloud-env"
      "jwt"
      "multi_json"
      "os"
      "signet"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07kk8h5f9q62qf1mk7rycgv6m09rd0k8baffdpb3vsksxnpaqsvy";
      type = "gem";
    };
  };

  highline = {
    version = "2.0.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yclf57n2j3cw8144ania99h1zinf8q3f5zrhqa754j6gl95rp9d";
      type = "gem";
    };
  };

  http-cookie = {
    version = "1.0.8";
    dependencies = [ "domain_name" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19hsskzk5zpv14mnf07pq71hfk1fsjwfjcw616pgjjzjbi2f0kxi";
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
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0il6qxkxqql7n7sgrws5bi5a36v51dswqcxb6j6gm8aj62shp6r8";
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
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l875dw0lk7b2ywa54l0wjcggs94vb7gs8khfw9li75n2sn09jyg";
      type = "gem";
    };
  };

  nanaimo = {
    version = "0.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08q73nchv8cpk28h1sdnf5z6a862fcf4mxy1d58z25xb3dankw7s";
      type = "gem";
    };
  };

  naturally = {
    version = "2.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00cy2wg40rsasnbl0cjcj3jcghq068v445rh90q63rn2fv7j76a5";
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

  optparse = {
    version = "0.8.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06mx0g76bqwyrv8hxdikhyziyq8x8j8rk9l0y3scyz4hac6s3gj2";
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

  plist = {
    version = "3.7.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hlaf4b3d8grxm9fqbnam5gwd55wvghl0jyzjd1hc5hirhklaynk";
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

  rake = {
    version = "13.3.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "175iisqb211n0qbfyqd8jz2g01q6xj038zjf4q0nm8k6kz88k7lc";
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
    version = "3.4.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hninnbvqd2pn40h863lbrn9p11gvdxp928izkag5ysx8b1s5q0r";
      type = "gem";
    };
  };

  rouge = {
    version = "3.28.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "080fswzii68wnbsg7pgq55ba7p289sqjlxwp4vch0h32qy1f8v8d";
      type = "gem";
    };
  };

  ruby2_keywords = {
    version = "0.0.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vz322p8n39hz3b4a9gkmz9y7a5jaz41zrm2ywf31dvkqm03glgz";
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

  security = {
    version = "0.1.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1drkm2wgjazwzj09db1szrllkag036bdvc3dr42fh1kpr877m5rs";
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

  simctl = {
    version = "1.6.10";

    dependencies = [
      "CFPropertyList"
      "naturally"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0sr3z4kmp6ym7synicyilj9vic7i9nxgaszqx6n1xn1ss7s7g45r";
      type = "gem";
    };
  };

  sysrandom = {
    version = "1.0.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0x8yryf6migjnkfwr8dxgx1qyzhvajgha60hr5mgfkn65qyarhas";
      type = "gem";
    };
  };

  terminal-notifier = {
    version = "2.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1slc0y8pjpw30hy21v8ypafi8r7z9jlj4bjbgz03b65b28i2n3bs";
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

  tty-spinner = {
    version = "0.9.3";
    dependencies = [ "tty-cursor" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hh5awmijnzw9flmh5ak610x1d00xiqagxa5mbr63ysggc26y0qf";
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
    version = "2.6.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nkz7fadlrdbkf37m0x7sw8bnz8r355q3vwcfb9f9md6pds9h9qj";
      type = "gem";
    };
  };

  word_wrap = {
    version = "1.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1iyc5bc7dbgsd8j3yk1i99ral39f23l6wapi0083fbl19hid8mpm";
      type = "gem";
    };
  };

  xcodeproj = {
    version = "1.27.0";

    dependencies = [
      "CFPropertyList"
      "atomos"
      "claide"
      "colored2"
      "nanaimo"
      "rexml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lslz1kfb8jnd1ilgg02qx0p0y6yiq8wwk84mgg2ghh58lxsgiwc";
      type = "gem";
    };
  };

  xcpretty = {
    version = "0.4.1";
    dependencies = [ "rouge" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14iqgwrdfzc00b3dc5pal4gm9n7w5hn3wdgmsvirwn7n47km0k5i";
      type = "gem";
    };
  };

  xcpretty-travis-formatter = {
    version = "1.0.1";
    dependencies = [ "xcpretty" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14rg4f70klrs910n7rsgfa4dn8s2qyny55194ax2qyyb2wpk7k5a";
      type = "gem";
    };
  };
}
