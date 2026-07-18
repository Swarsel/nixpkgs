{
  CFPropertyList = {
    version = "3.0.7";

    dependencies = [
      "base64"
      "nkf"
      "rexml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0k1w5i4lb1z941m7ds858nly33f3iv12wvr1zav5x3fa99hj2my4";
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
    version = "1.10.4";

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
      sha256 = "069gmdh5j90v06rbwlqvlhzhq45lxhx74mahz25xd276rm0wb153";
      type = "gem";
    };
  };

  faraday-cookie_jar = {
    version = "0.0.7";

    dependencies = [
      "faraday"
      "http-cookie"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00hligx26w9wdnpgsrf0qdnqld4rdccy8ym6027h5m735mpvxjzk";
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
    version = "1.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vgrbhkp83sngv6k4mii9f2s9v5lmp693hylfxp2ssfc60fas3a6";
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
    version = "1.1.0";
    dependencies = [ "multipart-post" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l87r9jg06nsh24gwwd1jdnxb1zq89ffybnxab0dd90nfcf0ysw5";
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
    version = "1.0.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "153i967yrwnswqgvnnajgwp981k9p50ys1h80yz3q94rygs59ldd";
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
    version = "2.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1s67b9n7ki3iaycypq8sh02377gjkaxadg4dq53bpgfk4xg3gkjz";
      type = "gem";
    };
  };

  fastlane = {
    version = "2.227.2";

    dependencies = [
      "CFPropertyList"
      "addressable"
      "artifactory"
      "aws-sdk-s3"
      "babosa"
      "colored"
      "commander"
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
      "mini_magick"
      "multipart-post"
      "naturally"
      "optparse"
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
      sha256 = "1dw9smmpzhlca2zzp2pgmr2slhwnz8926s5rnjfjrclilz33p22z";
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
    version = "0.54.0";
    dependencies = [ "google-apis-core" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "046j100lrh5dhb8p3gr38fyqrw8vcif97pqb55ysipy874lafw49";
      type = "gem";
    };
  };

  google-apis-core = {
    version = "0.11.3";

    dependencies = [
      "addressable"
      "googleauth"
      "httpclient"
      "mini_mime"
      "representable"
      "retriable"
      "rexml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15ycm7al9dizabbqmri5xmiz8mbcci343ygb64ndbmr9n49p08a3";
      type = "gem";
    };
  };

  google-apis-iamcredentials_v1 = {
    version = "0.17.0";
    dependencies = [ "google-apis-core" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ysil0bkh755kmf9xvw5szhk1yyh3gqzwfsrbwsrl77gsv7jarcs";
      type = "gem";
    };
  };

  google-apis-playcustomapp_v1 = {
    version = "0.13.0";
    dependencies = [ "google-apis-core" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mlgwiid5lgg41y7qk8ca9lzhwx5njs25hz5fbf1mdal0kwm37lm";
      type = "gem";
    };
  };

  google-apis-storage_v1 = {
    version = "0.31.0";
    dependencies = [ "google-apis-core" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13yvc9r8bhs16vq3fjc93qlffmq9p6zx97c9g1c3wh0jbrvwrs03";
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
    version = "1.6.0";
    dependencies = [ "faraday" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05gshdqscg4kil6ppfzmikyavsx449bxyj47j33r4n4p8swsqyb1";
      type = "gem";
    };
  };

  google-cloud-errors = {
    version = "1.5.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jvv9w8s4dqc4ncfa6c6qpdypz2wj8dmgpjd44jq2qhhij5y4sxm";
      type = "gem";
    };
  };

  google-cloud-storage = {
    version = "1.47.0";

    dependencies = [
      "addressable"
      "digest-crc"
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
      sha256 = "0xpb3s7zr7g647xg66y2mavdargk5ixsfbfdmi4m2jc3khdd0hxm";
      type = "gem";
    };
  };

  googleauth = {
    version = "1.8.1";

    dependencies = [
      "faraday"
      "jwt"
      "multi_json"
      "os"
      "signet"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ry9v23kndgx2pxq9v31l68k9lnnrcz1w4v75bkxq88jmbddljl1";
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
    version = "2.12.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x5b8ipv6g0z44wgc45039k04smsyf95h2m5m67mqq35sa5a955s";
      type = "gem";
    };
  };

  jwt = {
    version = "2.10.1";
    dependencies = [ "base64" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1i8wmzgb5nfhvkx1f6bhdwfm7v772172imh439v3xxhkv3hllhp6";
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
    version = "1.15.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pb1g1y3dsiahavspyzkdy39j4q377009f6ix0bh1ag4nqw43l0z";
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
    version = "2.2.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04x1nkx6gkqzlc4phdvq05v3vjds6mgqhjqzqpcs6vdh5xyqrf59";
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
    version = "0.6.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1306kdvq0xr333xma4452zvvvw6mx7fw20fwi6508i6dq5lh9s95";
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
    version = "6.0.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1543ap9w3ydhx39ljcd675cdz9cr948x9mp00ab8qvq6118wv9xz";
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
    version = "3.1.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1q48hqws2dy1vws9schc0kmina40gy7sn5qsndpsfqdslh65snha";
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
    version = "0.20.0";

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
      sha256 = "18s7xiclzajp9w9cmq8k28iy5ig1zpx1zv1mrm416cb2c0m0wrmw";
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

  xcode-install = {
    version = "2.8.1";

    dependencies = [
      "claide"
      "fastlane"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11mkjyz5icxyskmchwh1vld9vdlhc794356nbla88dgjaqhjddvl";
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
