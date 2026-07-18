{
  actioncable = {
    version = "7.0.8.6";

    dependencies = [
      "actionpack"
      "activesupport"
      "nio4r"
      "websocket-driver"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ms0196bp8gzlghfj32q2qdzszb7hsgg96v3isrv5ysd87w0z2zl";
      type = "gem";
    };
  };

  actionmailbox = {
    version = "7.0.8.6";

    dependencies = [
      "actionpack"
      "activejob"
      "activerecord"
      "activestorage"
      "activesupport"
      "mail"
      "net-imap"
      "net-pop"
      "net-smtp"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mw8casnlqgj3vwqv7qk3d4q3bjszlpmbs9ldpc9gz1qdvafx7cg";
      type = "gem";
    };
  };

  actionmailer = {
    version = "7.0.8.6";

    dependencies = [
      "actionpack"
      "actionview"
      "activejob"
      "activesupport"
      "mail"
      "net-imap"
      "net-pop"
      "net-smtp"
      "rails-dom-testing"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07gpm15k5c0y84q99zipnhcdgq93bwralyjpj252prvqwfjmiw73";
      type = "gem";
    };
  };

  actionpack = {
    version = "7.0.8.6";

    dependencies = [
      "actionview"
      "activesupport"
      "rack"
      "rack-test"
      "rails-dom-testing"
      "rails-html-sanitizer"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19ywl4jp77b51c01hsyzwia093fnj73pw1ipgyj4pk3h2b9faj5n";
      type = "gem";
    };
  };

  actiontext = {
    version = "7.0.8.6";

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
      sha256 = "1j8b29764nbiqz6d7ra42j2i6wf070lbms1fhpq3cl9azbgijb16";
      type = "gem";
    };
  };

  actionview = {
    version = "7.0.8.6";

    dependencies = [
      "activesupport"
      "builder"
      "erubi"
      "rails-dom-testing"
      "rails-html-sanitizer"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0girx71db1aq5b70ln3qq03z9d7xjdyp297v1a8rdal7k89y859c";
      type = "gem";
    };
  };

  activejob = {
    version = "7.0.8.6";

    dependencies = [
      "activesupport"
      "globalid"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gbc0wx9xal5bj0pbz8ygkr75wj4cm5i69hpwknf023psgixaybw";
      type = "gem";
    };
  };

  activemodel = {
    version = "7.0.8.6";
    dependencies = [ "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1f6szahjsb4pr2xvlvk4kghk9291xh9c14s8cqwy6wwpm1vcglim";
      type = "gem";
    };
  };

  activerecord = {
    version = "7.0.8.6";

    dependencies = [
      "activemodel"
      "activesupport"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14qs1jc9hwnsm4dzvnai8b36bcq1d7rcqgjxy0dc6wza670lqapf";
      type = "gem";
    };
  };

  activerecord-nulldb-adapter = {
    version = "1.0.1";
    dependencies = [ "activerecord" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1552py7zlamd5gy2dbkzjixanl9k07y6jqqrr4ic6n52apwd0ijy";
      type = "gem";
    };
  };

  activestorage = {
    version = "7.0.8.6";

    dependencies = [
      "actionpack"
      "activejob"
      "activerecord"
      "activesupport"
      "marcel"
      "mini_mime"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nnvqnmc7mdhw2w55j4vnx4zmmdmmwmaf6ax2mbj9j5a48fw19vf";
      type = "gem";
    };
  };

  activesupport = {
    version = "7.0.8.6";

    dependencies = [
      "concurrent-ruby"
      "i18n"
      "minitest"
      "tzinfo"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gj20cysajda05z3r7pl1g9y84nzsqak5dvk9nrz13jpy6297dj1";
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

  aws-eventstream = {
    version = "1.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gvdg4yx4p9av2glmp7vsxhs0n8fj1ga9kq2xdb8f95j7b04qhzi";
      type = "gem";
    };
  };

  aws-partitions = {
    version = "1.999.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1f2y7ycq7i3y7p5klsi3gk3p5r5p1vkq6w7dq4zk9grq2hw9f7cv";
      type = "gem";
    };
  };

  aws-sdk-cloudwatch = {
    version = "1.104.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04fw6v3qbbgdv63l7kmc29p30bjdancg0kfrxbqcmidryj00qi2c";
      type = "gem";
    };
  };

  aws-sdk-core = {
    version = "3.211.0";

    dependencies = [
      "aws-eventstream"
      "aws-partitions"
      "aws-sigv4"
      "jmespath"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16mvscjhxdyhlvk2rpbxdzqmyikcf64xavb35grk4dkh0pg390rk";
      type = "gem";
    };
  };

  aws-sigv4 = {
    version = "1.10.1";
    dependencies = [ "aws-eventstream" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fq3lbvkgm1vk5wa8l7vdnq3vjnlmsnyf4bbd0jq3qadyd9hf54a";
      type = "gem";
    };
  };

  azure_mgmt_monitor = {
    version = "0.19.0";
    dependencies = [ "ms_rest_azure" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13yqhcdqv4lr6bf3ylh2p1k9x4qg9qlr05y9fv7fi8yj5rqrbjhx";
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

  bigdecimal = {
    version = "3.1.8";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gi7zqgmqwi5lizggs1jhc3zlwaqayy9rx2ah80sxy24bbnng558";
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

  concurrent-ruby = {
    version = "1.3.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0chwfdq2a6kbj6xz9l6zrdfnyghnh32si82la1dnpa5h75ir5anl";
      type = "gem";
    };
  };

  crass = {
    version = "1.0.6";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pfl5c0pyqaparxaqxi6s4gfl21bdldwiawrc0aknyvflli60lfw";
      type = "gem";
    };
  };

  date = {
    version = "3.3.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "149jknsq999gnhy865n33fkk22s0r447k76x9pmcnnwldfv2q7wp";
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

  erubi = {
    version = "1.13.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qnd6ff4az22ysnmni3730c41b979xinilahzg86bn7gv93ip9pw";
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
    version = "1.0.4";
    dependencies = [ "multipart-post" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09871c4hd7s5ws1wl4gs7js1k2wlby6v947m2bbzg43pnld044lh";
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

  globalid = {
    version = "1.2.1";
    dependencies = [ "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1sbw6b66r7cwdx3jhs46s4lr991969hvigkjpbdl7y3i31qpdgvh";
      type = "gem";
    };
  };

  google-apis-core = {
    version = "0.15.1";

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
      sha256 = "06m775rzhpdz9kalml04sysy5swgfh97jaglsgrv5x8sg4i42j4i";
      type = "gem";
    };
  };

  google-apis-monitoring_v3 = {
    version = "0.71.0";
    dependencies = [ "google-apis-core" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qzks40qfdxlgy0w72y75rlji9g225v6shf78k6q4p74f7w2ns0s";
      type = "gem";
    };
  };

  google-cloud-env = {
    version = "2.2.1";
    dependencies = [ "faraday" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ks9yv21d8bl9cw0sz5gy6npll1ig3m2bq9w7yw67j5mw2p64q1w";
      type = "gem";
    };
  };

  google-protobuf = {
    version = "4.28.3";

    dependencies = [
      "bigdecimal"
      "rake"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1d99vyhmyp2n5zd0qmfymzwbcn71dbnwwvc0m4z14msjb7b8dvf0";
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

  http-cookie = {
    version = "1.0.7";
    dependencies = [ "domain_name" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0lr2yk5g5vvf9nzlmkn3p7mhh9mn55gpdc7kl2w21xs46fgkjynb";
      type = "gem";
    };
  };

  httpclient = {
    version = "2.8.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19mxmvghp7ki3klsxwrlwr431li7hm1lczhhj8z4qihl2acy8l99";
      type = "gem";
    };
  };

  i18n = {
    version = "1.14.6";
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0k31wcgnvcvd14snz0pfqj976zv6drfsnq6x8acz10fiyms9l8nw";
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

  jwt = {
    version = "2.9.3";
    dependencies = [ "base64" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rba9mji57sfa1kjhj0bwff1377vj0i8yx2rd39j5ik4vp60gzam";
      type = "gem";
    };
  };

  loofah = {
    version = "2.23.1";

    dependencies = [
      "crass"
      "nokogiri"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ppp2cgli5avzk0z3dwnah6y65ymyr793yja28p2fs9vrci7986h";
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
    version = "1.0.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "190n2mk8m1l708kr88fh6mip9sdsh339d2s6sgrik3sbnvz4jmhd";
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

  mini_portile2 = {
    version = "2.8.7";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1q1f2sdw3y3y9mnym9dhjgsjr72sq975cfg5c4yx7gwv8nmzbvhk";
      type = "gem";
    };
  };

  minitest = {
    version = "5.25.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1n1akmc6bibkbxkzm1p1wmfb4n9vv397knkgz0ffykb3h1d7kdix";
      type = "gem";
    };
  };

  ms_rest = {
    version = "0.7.6";

    dependencies = [
      "concurrent-ruby"
      "faraday"
      "timeliness"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jiha1bda5knpjqjymwik6i41n69gb0phcrgvmgc5icl4mcisai7";
      type = "gem";
    };
  };

  ms_rest_azure = {
    version = "0.12.0";

    dependencies = [
      "concurrent-ruby"
      "faraday"
      "faraday-cookie_jar"
      "ms_rest"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06i37b84r2q206kfm5vsi9s1qiiy09091vhvc5pzb7320h0hc1ih";
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
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ma093ayps1m92q845hmpk0dmadicvifkbf05rpq9pifhin0rvxn";
      type = "gem";
    };
  };

  net-imap = {
    version = "0.5.0";

    dependencies = [
      "date"
      "net-protocol"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "182ap7y5ysmr1xqy23ygssz3as1wcy3r5qcdm1whd1n1yfc1aa5q";
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
    version = "0.5.0";
    dependencies = [ "net-protocol" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0amlhz8fhnjfmsiqcjajip57ici2xhw089x7zqyhpk51drg43h2z";
      type = "gem";
    };
  };

  nio4r = {
    version = "2.7.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1a9www524fl1ykspznz54i0phfqya4x45hqaz67in9dvw1lfwpfr";
      type = "gem";
    };
  };

  nokogiri = {
    version = "1.16.7";

    dependencies = [
      "mini_portile2"
      "racc"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15gysw8rassqgdq3kwgl4mhqmrgh7nk2qvrcqp4ijyqazgywn6gq";
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

  pg_query = {
    version = "5.1.0";
    dependencies = [ "google-protobuf" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0p8ljf694qvrf5875ljg6kp7gvmndy8490kasjzcq22ghryg9xxp";
      type = "gem";
    };
  };

  pghero = {
    version = "3.6.1";
    dependencies = [ "activerecord" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1m4wlwx37n1jsrdzxf824pz7j0p72i1al7ndmy6q5m3r77ngdm76";
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

  public_suffix = {
    version = "6.0.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vqcw3iwby3yc6avs1vb3gfd0vcp2v7q310665dvxfswmcf4xm31";
      type = "gem";
    };
  };

  puma = {
    version = "6.4.3";
    dependencies = [ "nio4r" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gml1rixrfb0naciq3mrnqkpcvm9ahgps1c04hzxh4b801f69914";
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
    version = "2.2.10";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ax778fsfvlhj7c11n0d1wdcb8bxvkb190a9lha5d91biwzyx9g4";
      type = "gem";
    };
  };

  rack-test = {
    version = "2.1.0";
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ysx29gk9k14a14zsp5a8czys140wacvp91fja8xcja0j1hzqq8c";
      type = "gem";
    };
  };

  rails = {
    version = "7.0.8.6";

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
      sha256 = "1s42lyl19h74xlqkb6ffl67h688q0slp1lhnd05g09a46z7wapri";
      type = "gem";
    };
  };

  rails-dom-testing = {
    version = "2.2.0";

    dependencies = [
      "activesupport"
      "minitest"
      "nokogiri"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fx9dx1ag0s1lr6lfr34lbx5i1bvn3bhyf3w3mx6h7yz90p725g5";
      type = "gem";
    };
  };

  rails-html-sanitizer = {
    version = "1.6.0";

    dependencies = [
      "loofah"
      "nokogiri"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pm4z853nyz1bhhqr7fzl44alnx4bjachcr6rh6qjj375sfz3sc6";
      type = "gem";
    };
  };

  railties = {
    version = "7.0.8.6";

    dependencies = [
      "actionpack"
      "activesupport"
      "method_source"
      "rake"
      "thor"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fcn0ix814074gqicc0k1178f7ahmysiv3pfq8g00phdwj0p3w0g";
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

  signet = {
    version = "0.19.0";

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
      sha256 = "0cfxa11wy1nv9slmnzjczkdgld0gqizajsb03rliy53zylwkjzsk";
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

  timeliness = {
    version = "0.3.10";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gvp9b7yn4pykn794cibylc9ys1lw7fzv7djx1433icxw4y26my3";
      type = "gem";
    };
  };

  timeout = {
    version = "0.4.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16mvvsmx90023wrhf8dxc1lpqh0m8alk65shb7xcya6a9gflw7vg";
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

  websocket-driver = {
    version = "0.7.6";
    dependencies = [ "websocket-extensions" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nyh873w4lvahcl8kzbjfca26656d5c6z3md4sbqg5y1gfz0157n";
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

  zeitwerk = {
    version = "2.7.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mi7b90hvc6nqv37q27df4i2m27yy56yfy2ki5073474a1h9hi89";
      type = "gem";
    };
  };
}
