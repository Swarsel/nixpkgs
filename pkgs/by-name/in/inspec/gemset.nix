{
  activesupport = {
    version = "7.2.3";

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
      sha256 = "043vbilaw855c91n5l7g0k0wxj63kngj911685qy74xc1mvwjxan";
      type = "gem";
    };
  };

  addressable = {
    version = "2.8.8";
    dependencies = [ "public_suffix" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mxhjgihzsx45l9wh2n0ywl9w0c6k70igm5r0d63dxkcagwvh4vw";
      type = "gem";
    };
  };

  ast = {
    version = "2.4.3";
    groups = [ "default" ];
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
    version = "1.863.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jgzsjdl1m9krycj0vx4riiiy0a6ydfbsmgalfgvkh6z0n02xcib";
      type = "gem";
    };
  };

  aws-sdk-accessanalyzer = {
    version = "1.44.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11qs9j3dkh09i0wi15yq51b3kx90df6w9fd5qjpqxgyhq1qiaczn";
      type = "gem";
    };
  };

  aws-sdk-account = {
    version = "1.20.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1h6fqfq5pgsmnchmg4w4l9mypv2ggix1d0a8b8w66a9xvsk8bkxd";
      type = "gem";
    };
  };

  aws-sdk-alexaforbusiness = {
    version = "1.67.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ps37857dgnydnih2gxrl3a5fr571242006l9634jzm8w91jpb80";
      type = "gem";
    };
  };

  aws-sdk-amplify = {
    version = "1.54.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ix419jmwiag94s3m7hcz8hdmz4hj31dsq03asxgdf8j6znsfymz";
      type = "gem";
    };
  };

  aws-sdk-apigateway = {
    version = "1.90.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gqd04rdzz487bgy64gq2fqm20wcdd2zk8rnl51nyq6cfxsslbvw";
      type = "gem";
    };
  };

  aws-sdk-apigatewayv2 = {
    version = "1.53.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1dq11njjh05dm6dc2gjrbhl6ga6a9mxaisr7bgk0gv295b5nfiwp";
      type = "gem";
    };
  };

  aws-sdk-applicationautoscaling = {
    version = "1.79.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1php0vwwrxpypxmwwwhlnsmj2prd7qsck63vh6r80s08g9m87v94";
      type = "gem";
    };
  };

  aws-sdk-athena = {
    version = "1.79.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19fs835xm7pls49yryayh80m6dap44g4r2qk94ssvck5paxyylk3";
      type = "gem";
    };
  };

  aws-sdk-autoscaling = {
    version = "1.102.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04l1gjsq5m0psf82cwl4kbwyzikip1lf9fg37j77bl30cgdjqfpy";
      type = "gem";
    };
  };

  aws-sdk-batch = {
    version = "1.79.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0y9k1j4k2fw3d0grp8pk3wjvgl5cll0j5hsz80187wwr2i0ar7q8";
      type = "gem";
    };
  };

  aws-sdk-budgets = {
    version = "1.62.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0689sck8d49smzavhipl2i3nrr5lrw3miam88a7h7qckwmlsp098";
      type = "gem";
    };
  };

  aws-sdk-cloudformation = {
    version = "1.97.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0sgsyzsyjdw795k81sc0qy1h4rd3ksxszcxp93wx07vrl8nv5i0a";
      type = "gem";
    };
  };

  aws-sdk-cloudfront = {
    version = "1.86.1";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0g5zwy8s4g1ml48dxqix7sjrbadgygj02zvv7jd5x23xj71wmwb2";
      type = "gem";
    };
  };

  aws-sdk-cloudhsm = {
    version = "1.50.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ijcid6qpz49vmsp7zig0h7qzgx5rc027iqwl4bnyic6vmgir6ai";
      type = "gem";
    };
  };

  aws-sdk-cloudhsmv2 = {
    version = "1.53.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hmjkz09xldacq12l1b924gkfyzx6s0zvigmw2dvbxf3v1imainn";
      type = "gem";
    };
  };

  aws-sdk-cloudtrail = {
    version = "1.74.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03nr4qpv6678b3lpgbfvlaxydg7m72r1l2ml0mv14z5h066i964s";
      type = "gem";
    };
  };

  aws-sdk-cloudwatch = {
    version = "1.83.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18vvn1p3fyy1rv3hdihih9gjshrkxw5bvbz8bhpv1n0av9aq0y2j";
      type = "gem";
    };
  };

  aws-sdk-cloudwatchevents = {
    version = "1.69.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ws7dm4x4igjzgbq84f5ifymr7nh3861gnrwy5fqghdq5ffjfhjc";
      type = "gem";
    };
  };

  aws-sdk-cloudwatchlogs = {
    version = "1.77.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12w3rs5aihxz6z76q6vmn6024pw1wpzvxl5l24jv543z563cpzzg";
      type = "gem";
    };
  };

  aws-sdk-codecommit = {
    version = "1.62.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0blk86gvg74s7imhz07brrgc4q71ddnwd5nf1a86vyn8rdcq0dxx";
      type = "gem";
    };
  };

  aws-sdk-codedeploy = {
    version = "1.62.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hx9hsqj90nbngkmd833ah7mfwdll1j6i1dn5x0w0h2gpqdpiamw";
      type = "gem";
    };
  };

  aws-sdk-codepipeline = {
    version = "1.67.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d0finvyv46h9bqyds092pnjspg6hcr2rakk54w3y84smyzaawp3";
      type = "gem";
    };
  };

  aws-sdk-cognitoidentity = {
    version = "1.51.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wxa2zwj0gyw8cn5k8287a0h4p6lhvbkxrd8crp3959dgy10lnjv";
      type = "gem";
    };
  };

  aws-sdk-cognitoidentityprovider = {
    version = "1.85.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04i9npmdcdcidwsiqgy55p50r4y0baivmmj6cp2fcjpjp0jxncz1";
      type = "gem";
    };
  };

  aws-sdk-configservice = {
    version = "1.103.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11xb46y5glq0bqlhbhpkr9mf1p17jsxb5l0wq3hpvzxw376ip6hl";
      type = "gem";
    };
  };

  aws-sdk-core = {
    version = "3.190.3";

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
      sha256 = "0h9x1wk3axjmf8f7p49dz8cihaxcgb4s46h3rpzvq4lisxsngdpr";
      type = "gem";
    };
  };

  aws-sdk-costandusagereportservice = {
    version = "1.53.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jps30r7l5g7j4b1lss9m1isyk5h8k469hq9dp4yljis0jdlmy3c";
      type = "gem";
    };
  };

  aws-sdk-databasemigrationservice = {
    version = "1.91.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "192lgmd5jfh83a3fa9nyynz64l32yh64ia4xmpjrznfq8rdhjan2";
      type = "gem";
    };
  };

  aws-sdk-dynamodb = {
    version = "1.98.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ib8iwgp7ddhcgmqmzjq9js0kw8m5mm4mi7klrl84925lgvlvk65";
      type = "gem";
    };
  };

  aws-sdk-ec2 = {
    version = "1.429.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ra3lzgd7nzird8blxjj44bjq3aly929bfjrjyryb43xvc5mp3dj";
      type = "gem";
    };
  };

  aws-sdk-ecr = {
    version = "1.68.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "103ycwxv367bkrqzdpypd0p650r62ka3azw2pzdwc38pj5r3nxl6";
      type = "gem";
    };
  };

  aws-sdk-ecrpublic = {
    version = "1.25.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1a5j7v70gwwy1md4awz37k77qlwgls390xlwbri8lkcxmaw2x5bp";
      type = "gem";
    };
  };

  aws-sdk-ecs = {
    version = "1.135.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0s4yyi22v0vv3pyskpz4qzahngfxawxjx8x4ch2aj8c8wffkfclk";
      type = "gem";
    };
  };

  aws-sdk-efs = {
    version = "1.71.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1m8ymz0wq1p6iz126qcdsrz0ss730p1inb6g1w07r9ganjdzbplx";
      type = "gem";
    };
  };

  aws-sdk-eks = {
    version = "1.95.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13aac0gpyxm660pbcbpvpcpw20db28p5lbwjs45rczc9l3yl9aw1";
      type = "gem";
    };
  };

  aws-sdk-elasticache = {
    version = "1.95.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "061zg2k3kvayrnih0qiilcdarwjap37bzf1a0v5n6a57606hc40s";
      type = "gem";
    };
  };

  aws-sdk-elasticbeanstalk = {
    version = "1.63.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ysn5cj4rwqj2jvsg02i8qs9j3z6c6lwhici58q09m62xzrhr3qg";
      type = "gem";
    };
  };

  aws-sdk-elasticloadbalancing = {
    version = "1.51.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09zvryq7121c05cswzwv337qylza33dwlqd97c11ii3y8pg2bsla";
      type = "gem";
    };
  };

  aws-sdk-elasticloadbalancingv2 = {
    version = "1.96.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mgik7lhch27j4q4nzxci0rhrgybh0bx7bzcq48c5sggpm999qkr";
      type = "gem";
    };
  };

  aws-sdk-elasticsearchservice = {
    version = "1.79.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nqrx6vm4yi1amk7677rw6jvwrdhv7pj4g507r5hqcfmilr5z1gx";
      type = "gem";
    };
  };

  aws-sdk-emr = {
    version = "1.81.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hbfwpas2cf8x0v5mf2iwcbcwgadbmz1rkhf29csygjjgc7m39xm";
      type = "gem";
    };
  };

  aws-sdk-eventbridge = {
    version = "1.54.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0iz3xpfxiwm75cllbsyhlvp3af6xxjab0nb86ws69gqbrrjlvpq7";
      type = "gem";
    };
  };

  aws-sdk-firehose = {
    version = "1.60.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0n4iz5bv80gd7m070jyr5kv36yx8qyq1i8ljh5bfj3cr57vvdw89";
      type = "gem";
    };
  };

  aws-sdk-glue = {
    version = "1.165.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bwarv5p3nhbwb6kqhp0wlr7bzbqsg25i783dlq5xb392g57az7n";
      type = "gem";
    };
  };

  aws-sdk-guardduty = {
    version = "1.85.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ya8q0hgh7293jlz1pchci5qvywnmg87h3x3k9hsbqf1023bz9nz";
      type = "gem";
    };
  };

  aws-sdk-iam = {
    version = "1.92.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0whclpcvbdy7gzvqpk8734nxjfxs3362k197xl1wnrpixklkacyz";
      type = "gem";
    };
  };

  aws-sdk-kafka = {
    version = "1.67.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gg28ixfr681sxjffp28wy47siz7jypvm04ldqarlcvgaqnk08ds";
      type = "gem";
    };
  };

  aws-sdk-kinesis = {
    version = "1.54.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19xzw7i6i4f0yn604is07w3zf3q6lch2ki29bg31m0jd2jdj2rn0";
      type = "gem";
    };
  };

  aws-sdk-kms = {
    version = "1.76.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jfgw9a9c8xyjhkmgpd9rpi95h9i0rhbqszn8iqkbfm9rc9m1xz7";
      type = "gem";
    };
  };

  aws-sdk-lambda = {
    version = "1.113.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gfysixcf5wsaqk0cycg3zryybs9zwvg0v6j9hn7zc99x27qjca4";
      type = "gem";
    };
  };

  aws-sdk-macie2 = {
    version = "1.64.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bfikv74x6mhdcddj1fx0dfgvg3h5ywcwdgdhzshqglk7ifw2wvd";
      type = "gem";
    };
  };

  aws-sdk-mq = {
    version = "1.58.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "076hak1wl7kzyfqip423w4r5h3sxnca6q1k7kqm2bphskqdnvfkg";
      type = "gem";
    };
  };

  aws-sdk-networkfirewall = {
    version = "1.39.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02bq2flz4kqcr9fvk09mvn6r7h1arnjjw87l0qkgyr94x8ngidpy";
      type = "gem";
    };
  };

  aws-sdk-networkmanager = {
    version = "1.40.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qpi693cjnzy91yyavmhgj6047kk04hslbqb7hgiqvz1ki4qr9q9";
      type = "gem";
    };
  };

  aws-sdk-organizations = {
    version = "1.83.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kdy6sic2g6rihidfd7mpz35ky898nacq4mjr9s1khmwa62cnr55";
      type = "gem";
    };
  };

  aws-sdk-ram = {
    version = "1.52.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yk7brap5977q9np30mibal09b64q5rr20x193qly4azf5vxic1b";
      type = "gem";
    };
  };

  aws-sdk-rds = {
    version = "1.208.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yrc7ivykdcrq8s6isd368gr02jclwc140pckf1vyii2f2g79k30";
      type = "gem";
    };
  };

  aws-sdk-redshift = {
    version = "1.107.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08rgpxknp11q4dxzncn4x30bpqkd4ssi78wq2j0kfgl5qbid48y8";
      type = "gem";
    };
  };

  aws-sdk-route53 = {
    version = "1.83.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1p7py5g5bk9yxlg6h04rkvgzgbysj7zm63bpdrswxwzhynmb8p9v";
      type = "gem";
    };
  };

  aws-sdk-route53domains = {
    version = "1.54.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15v2fbm9563kad3hnac5372xr7lvhxdyggrjzx1rbn56kf7bcb6n";
      type = "gem";
    };
  };

  aws-sdk-route53resolver = {
    version = "1.51.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0i57m3vysjlbvfrf0jpyi343bi8nw1j9gjcm50sv3lzx0ix66bpi";
      type = "gem";
    };
  };

  aws-sdk-s3 = {
    version = "1.141.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sdk-kms"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bnhpmi0iiaj88rqc5lhhnp2gyrk4fs8xz51lj36wwzng94qinya";
      type = "gem";
    };
  };

  aws-sdk-s3control = {
    version = "1.74.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lqvqbn8r55hy6v9860i1n1z0zajrmmwaf3pzalxahj5w1b0r5pl";
      type = "gem";
    };
  };

  aws-sdk-secretsmanager = {
    version = "1.87.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gmf1kn158a5l0nqyia3ij6jcafx0yalv8bjxyq8fgxm4l7gqwc8";
      type = "gem";
    };
  };

  aws-sdk-securityhub = {
    version = "1.98.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0awrb062w4dfhmjjcxj30k1jfy8nh8kd2r7p7a0zc78w6435fixj";
      type = "gem";
    };
  };

  aws-sdk-servicecatalog = {
    version = "1.90.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mvq5r15rv42y6kdvvxrpjzw133j1n71gmi0xrrj4x5n1sqhs2zy";
      type = "gem";
    };
  };

  aws-sdk-ses = {
    version = "1.58.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1sm23q972pv0wpfm899qdgg8vjg6y2fzyv621j71dl33gm74p6b1";
      type = "gem";
    };
  };

  aws-sdk-shield = {
    version = "1.60.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gk003vj7gs7a3rs79rs5bv5wcsyk9fsf3cc6ci3kbj5y5kbzabc";
      type = "gem";
    };
  };

  aws-sdk-signer = {
    version = "1.50.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "168ns2kgglh43024dr5q92l3m5358g9xcihilqbqqch3cnicnqv9";
      type = "gem";
    };
  };

  aws-sdk-simpledb = {
    version = "1.42.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv2"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "080w8irq490ydd1dx70x5ynymksjvsv589a1mmpgrqrnph0s4jlk";
      type = "gem";
    };
  };

  aws-sdk-sms = {
    version = "1.52.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17rmy3hzs3cv3vzr5j2swninwqdxf33hcci96pmy88wrcx4nav5x";
      type = "gem";
    };
  };

  aws-sdk-sns = {
    version = "1.70.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0zbn3gfksbszgdk806l96fmqa9npqm2gqgvjrqm4x44hl1a5cf8z";
      type = "gem";
    };
  };

  aws-sdk-sqs = {
    version = "1.69.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nsr4q2g7sfap9vx8vk5532mkyww8an25qabwplsdy9s625p8ahl";
      type = "gem";
    };
  };

  aws-sdk-ssm = {
    version = "1.162.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xz10344dwm4pj8qnl19bnh99arxp7cd9mn2alslrnw7y2gipzz1";
      type = "gem";
    };
  };

  aws-sdk-states = {
    version = "1.63.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mkhn7pxp9pmljw7ajc886fgijzpbai4qz8m4hriag7j81rj6amz";
      type = "gem";
    };
  };

  aws-sdk-synthetics = {
    version = "1.39.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05ygy884vd4i81qz9h3hr21v36d5cvpzbcf2grjwg49x7nj486jj";
      type = "gem";
    };
  };

  aws-sdk-transfer = {
    version = "1.86.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16dvaxicsmvm4fm0mfndmkx5qd3v94xnanm3xz7kgvb5q99y994p";
      type = "gem";
    };
  };

  aws-sdk-waf = {
    version = "1.58.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1phvaqliq870cih8ynwi97kzam3wv7408kak6i3zw5zxffvvfvrq";
      type = "gem";
    };
  };

  aws-sdk-wafv2 = {
    version = "1.74.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04xngypqsc8q0i545dlfy626mqc98szbiqi9jzflzcgv1fagdisz";
      type = "gem";
    };
  };

  aws-sigv2 = {
    version = "1.3.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "044l9ji1y73dab9f7xvhrkackiki43p8pg8f67da04fnczl74yyx";
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

  azure_graph_rbac = {
    version = "0.17.2";
    dependencies = [ "ms_rest_azure" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mmx8jp85xa13j3asa9xnfi6wa8a9wwlp0hz0nj70fi3ydmcpdag";
      type = "gem";
    };
  };

  azure_mgmt_key_vault = {
    version = "0.17.7";
    dependencies = [ "ms_rest_azure" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0f4fai5l3453yirrwajds0jgah60gvawffx53a0jyv3b93ag88mz";
      type = "gem";
    };
  };

  azure_mgmt_resources = {
    version = "0.18.2";
    dependencies = [ "ms_rest_azure" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1p4hsa7xha8ifml58hmkxdkp7vyhm7sw624xam1mrq0hvzawvkm3";
      type = "gem";
    };
  };

  azure_mgmt_security = {
    version = "0.19.0";
    dependencies = [ "ms_rest_azure" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11h2dyz4awzidvfj41h7k2q7mcqqcgzvm95fxpfxz609pbvck0g2";
      type = "gem";
    };
  };

  azure_mgmt_storage = {
    version = "0.23.0";
    dependencies = [ "ms_rest_azure" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ik06knz7fxn9q2x874d7q1v2fb00askwh36wbl75fnsi2m5m6rq";
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
    version = "3.3.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0612spks81fvpv2zrrv3371lbs6mwd7w6g5zafglyk75ici1x87a";
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

  chef-config = {
    version = "18.8.54";

    dependencies = [
      "addressable"
      "chef-utils"
      "fuzzyurl"
      "mixlib-config"
      "mixlib-shellout"
      "tomlrb"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rhifk1ngqjx99cp2j9jw969cbnmznrd4vs60cmf0mwp0rwipc9f";
      type = "gem";
    };
  };

  chef-gyoku = {
    version = "1.5.0";

    dependencies = [
      "builder"
      "rexml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dpqrxpn5xx0jahga8kny2vagx7vxiinw4xcz6xwjg14z37s6m3k";
      type = "gem";
    };
  };

  chef-licensing = {
    version = "1.3.0";

    dependencies = [
      "chef-config"
      "faraday"
      "faraday-http-cache"
      "faraday_middleware"
      "mixlib-log"
      "ostruct"
      "pstore"
      "tty-prompt"
      "tty-spinner"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13z7rfrdfagxr5a0bgcy7dayg7q4zi2r1zawdc6847x3h7ckldcv";
      type = "gem";
    };
  };

  chef-telemetry = {
    version = "1.1.1";

    dependencies = [
      "chef-config"
      "concurrent-ruby"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l9icc3nfdj28mip85vf31v5l60qsfqq3a5dscv7jryh1k94y05x";
      type = "gem";
    };
  };

  chef-utils = {
    version = "18.8.54";
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1iqdxg0n58p2w8snnw21gjh55yk9h5cvxirnyvfhwlhs559nq735";
      type = "gem";
    };
  };

  chef-winrm = {
    version = "2.4.4";

    dependencies = [
      "builder"
      "chef-gyoku"
      "erubi"
      "gssapi"
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
      sha256 = "1sdddiwxf6lwrqnhwzi0m1b30bm01hshlyka88flqvbalgr58skz";
      type = "gem";
    };
  };

  chef-winrm-elevated = {
    version = "1.2.5";

    dependencies = [
      "chef-winrm"
      "chef-winrm-fs"
      "erubi"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01sqzw2vdjkvg2wznb6mwzkfjpkplllymfz4p4fvxgsv3vmv91cr";
      type = "gem";
    };
  };

  chef-winrm-fs = {
    version = "1.4.2";

    dependencies = [
      "benchmark"
      "chef-winrm"
      "csv"
      "erubi"
      "logging"
      "rubyzip"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fk8p20cgz392h03l6nilk8wpwwwkx3819c8svy0q1zbz3x9dmp8";
      type = "gem";
    };
  };

  coderay = {
    version = "1.1.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jvxqxzply1lwp7ysn94zjhh57vc14mcshw1ygw14ib8lhc00lyw";
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
    version = "2.5.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1b8nlxr5z843ii7hfk6igpr5acw3k2ih9yjrgkyz2gbmallgjkz5";
      type = "gem";
    };
  };

  cookstyle = {
    version = "8.5.2";
    dependencies = [ "rubocop" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "159l8d5c5d8awzaxhqc0c2zrb211wq751rr1r490c5vspmflpszg";
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

  docker-api = {
    version = "2.4.0";

    dependencies = [
      "excon"
      "multi_json"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rk3vpc7v8jrz432l24bgszwnjj1nsaygj79kcc1i1ycyhsffjw2";
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
    version = "1.3.0";

    dependencies = [
      "dry-core"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1a5g30p7kzp37n9w3idp3gy70hzkj30d8j951lhw2zsnb0l8cbc8";
      type = "gem";
    };
  };

  dry-core = {
    version = "1.1.0";

    dependencies = [
      "concurrent-ruby"
      "logger"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15di39ssfkwigyyqla65n4x6cfhgwa4cv8j5lmyrlr07jwd840q9";
      type = "gem";
    };
  };

  dry-inflector = {
    version = "1.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0blgyg9l4gpzhb7rs9hqq9j7br80ngiigjp2ayp78w6m1ysx1x92";
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
    version = "1.8.0";

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
      sha256 = "0ri9iqxknxvvhpbshf6jn7bq581k8l67iv23mii69yr4k5aqphvl";
      type = "gem";
    };
  };

  dry-types = {
    version = "1.8.3";

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
      sha256 = "1g61cnmmwzff05sf8bh95qjd3hikasgvrmf3q0qk29zdw12pmndm";
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

  faraday-follow_redirects = {
    version = "0.4.0";
    dependencies = [ "faraday" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nfmmnmqgbxci7dlca0qnwxn8j29yv7v8wm26m0f4l0kmcc13ynk";
      type = "gem";
    };
  };

  faraday-http-cache = {
    version = "2.5.1";
    dependencies = [ "faraday" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10wld3vk3i8zsr3pa9zyjiyi2zlyyln872812f08bbg1hnd15z6b";
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

  ffi = {
    version = "1.16.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yvii03hcgqj30maavddqamqy50h7y6xcn2wcyq72wn823zl4ckd";
      type = "gem";
    };
  };

  fuzzyurl = {
    version = "0.9.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03qchs33vfwbsv5awxg3acfmlcrf5xbhnbrc83fdpamwya0glbjl";
      type = "gem";
    };
  };

  google-apis-admin_directory_v1 = {
    version = "0.46.0";
    dependencies = [ "google-apis-core" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19hp4wgl4b1zdvs3vhwxdwlqv7lci2mnjvli5pzszqkbzfixk4dx";
      type = "gem";
    };
  };

  google-apis-cloudkms_v1 = {
    version = "0.41.0";
    dependencies = [ "google-apis-core" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1sjsidzv5hp84sbvmkwaw91kiv3ra7knqzckknyibl7lnhd2yjbw";
      type = "gem";
    };
  };

  google-apis-cloudresourcemanager_v1 = {
    version = "0.35.0";
    dependencies = [ "google-apis-core" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19028lhgcwgm71vpckw2kprzalqgp3h0sxv2vzalhqwkgq1h3zgf";
      type = "gem";
    };
  };

  google-apis-compute_v1 = {
    version = "0.83.0";
    dependencies = [ "google-apis-core" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10rpg3bk63g45bidhqxvybzf1g4bvys3yjg3wz76jl42kd1z9ljx";
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

  google-apis-iam_v1 = {
    version = "0.50.0";
    dependencies = [ "google-apis-core" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0b31jcbrzsp3lgf9vfgn8sx4pvwyi65cnv1qcq7i7jz1iqbyjdp2";
      type = "gem";
    };
  };

  google-apis-monitoring_v3 = {
    version = "0.51.0";
    dependencies = [ "google-apis-core" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xazqc3j5452q8rxa35ryi4glkd34g6r5ghxwrj7a84a2fspmgb5";
      type = "gem";
    };
  };

  google-apis-storage_v1 = {
    version = "0.30.0";
    dependencies = [ "google-apis-core" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vw8a2750ji5gnjil8nbkrmz3gjlap0q0gagzn9k0hl5m7143nag";
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

  hashdiff = {
    version = "1.2.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lbw8lqzjv17vnwb9vy5ki4jiyihybcc5h2rmcrqiz1xa6y9s1ww";
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

  highline = {
    version = "3.1.2";
    dependencies = [ "reline" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jmvyhjp2v3iq47la7w6psrxbprnbnmzz0hxxski3vzn356x7jv7";
      type = "gem";
    };
  };

  http-cookie = {
    version = "1.1.0";
    dependencies = [ "domain_name" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06dvmngd4hwrr6k774i1h6c50h2l8nww9f1id0wvrvi72l6yd99q";
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

  inifile = {
    version = "3.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1c5zmk7ia63yw5l2k14qhfdydxwi1sah1ppjdiicr4zcalvfn0xi";
      type = "gem";
    };
  };

  inspec = {
    version = "7.0.95";

    dependencies = [
      "faraday_middleware"
      "inspec-core"
      "progress_bar"
      "rake"
      "train"
      "train-aws"
      "train-habitat"
      "train-kubernetes"
      "train-winrm"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gz6frd1hpzyxprgi9m1g9sw4xybglfgwc4h7qjsn6wsjcw72n2i";
      type = "gem";
    };
  };

  inspec-bin = {
    version = "7.0.95";
    dependencies = [ "inspec" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13l71qnj6dwlbkasa6rnxf73yb2fiy9vvd68cb3m2lp2nx35z1g2";
      type = "gem";
    };
  };

  inspec-core = {
    version = "7.0.95";

    dependencies = [
      "addressable"
      "chef-licensing"
      "chef-telemetry"
      "cookstyle"
      "csv"
      "faraday"
      "faraday-follow_redirects"
      "hashie"
      "license-acceptance"
      "method_source"
      "mixlib-log"
      "multipart-post"
      "ostruct"
      "parallel"
      "parslet"
      "pry"
      "rspec"
      "rspec-its"
      "rubyzip"
      "semverse"
      "sslshake"
      "syslog"
      "thor"
      "tomlrb"
      "train-core"
      "tty-prompt"
      "tty-table"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mghshl98py0q1wwd2dbmx72b1641y0nqz7y68bpws1b8n2hy5df";
      type = "gem";
    };
  };

  io-console = {
    version = "0.8.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jszj95hazqqpnrjjzr326nn1j32xmsc9xvd97mbcrrgdc54858y";
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
    version = "2.17.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cc8sz1zciy6yhn291b4kn6r0kyzpi45gbnvgl63zibmvxk592ch";
      type = "gem";
    };
  };

  jsonpath = {
    version = "1.1.5";
    dependencies = [ "multi_json" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ghxjcs9rss0fd43yqnc3ab6fhnm4qrkvv34p0xcjb9s35kh9xr9";
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

  k8s-ruby = {
    version = "0.17.2";

    dependencies = [
      "base64"
      "dry-configurable"
      "dry-struct"
      "dry-types"
      "excon"
      "hashdiff"
      "jsonpath"
      "recursive-open-struct"
      "yajl-ruby"
      "yaml-safe_load_stream3"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06q7b4di9bq6dky1c95irw62lqj00yq82k2kqpyhcyjllw7cg5wi";
      type = "gem";
    };
  };

  language_server-protocol = {
    version = "3.17.0.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k0311vah76kg5m6zr7wmkwyk5p2f9d9hyckjpn3xgr83ajkj7px";
      type = "gem";
    };
  };

  license-acceptance = {
    version = "2.1.13";

    dependencies = [
      "pastel"
      "tomlrb"
      "tty-box"
      "tty-prompt"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12h5a3j57h50xkfpdz9gr42k0v8g1qxn2pnj5hbbzbmdhydjbjzf";
      type = "gem";
    };
  };

  lint_roller = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11yc0d84hsnlvx8cpk4cbj6a4dz9pk0r1k29p0n1fz9acddq831c";
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

  minitest = {
    version = "5.26.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qyda32pf9jivaw2m7yymxshqxxd0fhjn7zpbagvmfc5c65128gh";
      type = "gem";
    };
  };

  mixlib-config = {
    version = "3.0.27";
    dependencies = [ "tomlrb" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0j0122lv2qgccl61njqi0pj6sp6nb85y07gcmw16bwg4k0c8nx6p";
      type = "gem";
    };
  };

  mixlib-log = {
    version = "3.2.3";
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0s57cq8qx3823pcfzizshp8vagvp3f87r0lksknj18r26nl3y79a";
      type = "gem";
    };
  };

  mixlib-shellout = {
    version = "3.3.9";
    dependencies = [ "chef-utils" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "126k9zgxwj726gi0q0ywj4kdzf1gfm8z16i1nn7dw9kmn3imxpqf";
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
    version = "1.18.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vsrfm36zlg7jbrd1fjbr8kmdvr8bfayrw0hdlza75987vvhrxr3";
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
    version = "2.7.0";
    dependencies = [ "bigdecimal" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12wfv36jzc0978ij5c56nnfh5k8ax574njawigs98ysmp1x5s2ql";
      type = "gem";
    };
  };

  options = {
    version = "2.3.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1s650nwnabx66w584m1cyw82icyym6hv5kzfsbp38cinkr5klh9j";
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
    version = "0.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zxx3mx34vcgc77rpxn55mldaf45389880m1sppr4wgmcg2mx42y";
      type = "gem";
    };
  };

  parallel = {
    version = "1.27.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0c719bfgcszqvk9z47w2p8j2wkz5y35k48ywwas5yxbbh3hm3haa";
      type = "gem";
    };
  };

  parser = {
    version = "3.3.10.0";

    dependencies = [
      "ast"
      "racc"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mmb59323ldv6vxfmy98azgsla9k3di3fasvpb28hnn5bkx8fdff";
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

  prism = {
    version = "1.6.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0sqwckzzpj1mmmjnqcvqmq6adlxbhkf5ij3b6ir4i33ih4d2ih5z";
      type = "gem";
    };
  };

  progress_bar = {
    version = "1.3.4";

    dependencies = [
      "highline"
      "options"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "130w0yf9x5minkf2yscfbv8izc74hjap81g4zfnqxq3m0820xcdd";
      type = "gem";
    };
  };

  pry = {
    version = "0.15.2";

    dependencies = [
      "coderay"
      "method_source"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ssv704qg75mwlyagdfr9xxbzn1ziyqgzm0x474jkynk8234pm8j";
      type = "gem";
    };
  };

  pstore = {
    version = "0.1.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11mvc9s72fq7bl6h3f1rcng4ffa0nbjy1fr9wpshgzn4b9zznxm2";
      type = "gem";
    };
  };

  public_suffix = {
    version = "7.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15dhl6k4gbax0xz8frfs4nsb6lg5zgax9vkr1pqzjmhfxddhn2gp";
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

  recursive-open-struct = {
    version = "1.3.1";
    dependencies = [ "ostruct" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0847mn846fddfmm6vpdpz4ds9azbbcdxnnjw4zs31fqpi2f4l6ql";
      type = "gem";
    };
  };

  regexp_parser = {
    version = "2.11.3";
    groups = [ "default" ];
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
    groups = [ "default" ];
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
    version = "3.13.2";

    dependencies = [
      "rspec-core"
      "rspec-expectations"
      "rspec-mocks"
    ];

    groups = [ "default" ];
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
    groups = [ "default" ];
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

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dl8npj0jfpy31bxi6syc7jymyd861q277sfr6jawq2hv6hx791k";
      type = "gem";
    };
  };

  rspec-its = {
    version = "2.0.0";

    dependencies = [
      "rspec-core"
      "rspec-expectations"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pv0a8pvixgrwsi6j4nlpyn9m0jw9zn92dakjdg87wj9h71qp3m8";
      type = "gem";
    };
  };

  rspec-mocks = {
    version = "3.13.7";

    dependencies = [
      "diff-lcs"
      "rspec-support"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "071bqrk2rblk3zq3jk1xxx0dr92y0szi5pxdm8waimxici706y89";
      type = "gem";
    };
  };

  rspec-support = {
    version = "3.13.6";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cmgz34hwj5s3jwxhyl8mszs24nci12ffbrmr5jb1si74iqf739f";
      type = "gem";
    };
  };

  rubocop = {
    version = "1.81.6";

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

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hpgpyzpzgmp28pirlyrif3albsk5kni2k67h5yvxfvr3g55w2d7";
      type = "gem";
    };
  };

  rubocop-ast = {
    version = "1.48.0";

    dependencies = [
      "parser"
      "prism"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xifbp09jfl1hdy9wwgq9dq2l7mf8y2ycm5d1zgcqvks7yzrppr2";
      type = "gem";
    };
  };

  ruby-progressbar = {
    version = "1.13.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cwvyb7j47m7wihpfaq7rc47zwwx9k4v7iqd9s1xch5nm53rrz40";
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

  semverse = {
    version = "3.0.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vrh6p0756n3gjnk6am1cc4kmw6wzzd02hcajj27rlsqg3p6lwn9";
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

  socksify = {
    version = "1.8.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mm8m7zfvszbf9l750c2x693p8100rrk6ckvcp6909631ir02ang";
      type = "gem";
    };
  };

  sslshake = {
    version = "1.3.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0r3ifksx8a05yqhv7nc4cwan8bwmxgq5kyv7q7hy2h9lv5zcjs8h";
      type = "gem";
    };
  };

  strings = {
    version = "0.2.1";

    dependencies = [
      "strings-ansi"
      "unicode-display_width"
      "unicode_utils"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yynb0qhhhplmpzavfrrlwdnd1rh7rkwzcs4xf0mpy2wr6rr6clk";
      type = "gem";
    };
  };

  strings-ansi = {
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "120wa6yjc63b84lprglc52f40hx3fx920n4dmv14rad41rv2s9lh";
      type = "gem";
    };
  };

  syslog = {
    version = "0.3.0";
    dependencies = [ "logger" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "023lbh48fcn72gwyh1x52ycs1wx1bnhdajmv0qvkidmdsmxnxzjd";
      type = "gem";
    };
  };

  thor = {
    version = "1.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gcarlmpfbmqnjvwfz44gdjhcmm634di7plcx2zdgwdhrhifhqw7";
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

  tomlrb = {
    version = "1.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00x5y9h4fbvrv4xrjk4cqlkm4vq8gv73ax4alj3ac2x77zsnnrk8";
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

  train = {
    version = "3.13.4";

    dependencies = [
      "activesupport"
      "azure_graph_rbac"
      "azure_mgmt_key_vault"
      "azure_mgmt_resources"
      "azure_mgmt_security"
      "azure_mgmt_storage"
      "docker-api"
      "google-apis-admin_directory_v1"
      "google-apis-cloudkms_v1"
      "google-apis-cloudresourcemanager_v1"
      "google-apis-compute_v1"
      "google-apis-iam_v1"
      "google-apis-monitoring_v3"
      "google-apis-storage_v1"
      "googleauth"
      "inifile"
      "ostruct"
      "train-core"
      "train-winrm"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nxcfi1ffpav3wdggig2g2flh3apnzygxbfa20ry3d12s99ay4b1";
      type = "gem";
    };
  };

  train-aws = {
    version = "0.2.41";

    dependencies = [
      "aws-partitions"
      "aws-sdk-accessanalyzer"
      "aws-sdk-account"
      "aws-sdk-alexaforbusiness"
      "aws-sdk-amplify"
      "aws-sdk-apigateway"
      "aws-sdk-apigatewayv2"
      "aws-sdk-applicationautoscaling"
      "aws-sdk-athena"
      "aws-sdk-autoscaling"
      "aws-sdk-batch"
      "aws-sdk-budgets"
      "aws-sdk-cloudformation"
      "aws-sdk-cloudfront"
      "aws-sdk-cloudhsm"
      "aws-sdk-cloudhsmv2"
      "aws-sdk-cloudtrail"
      "aws-sdk-cloudwatch"
      "aws-sdk-cloudwatchevents"
      "aws-sdk-cloudwatchlogs"
      "aws-sdk-codecommit"
      "aws-sdk-codedeploy"
      "aws-sdk-codepipeline"
      "aws-sdk-cognitoidentity"
      "aws-sdk-cognitoidentityprovider"
      "aws-sdk-configservice"
      "aws-sdk-core"
      "aws-sdk-costandusagereportservice"
      "aws-sdk-databasemigrationservice"
      "aws-sdk-dynamodb"
      "aws-sdk-ec2"
      "aws-sdk-ecr"
      "aws-sdk-ecrpublic"
      "aws-sdk-ecs"
      "aws-sdk-efs"
      "aws-sdk-eks"
      "aws-sdk-elasticache"
      "aws-sdk-elasticbeanstalk"
      "aws-sdk-elasticloadbalancing"
      "aws-sdk-elasticloadbalancingv2"
      "aws-sdk-elasticsearchservice"
      "aws-sdk-emr"
      "aws-sdk-eventbridge"
      "aws-sdk-firehose"
      "aws-sdk-glue"
      "aws-sdk-guardduty"
      "aws-sdk-iam"
      "aws-sdk-kafka"
      "aws-sdk-kinesis"
      "aws-sdk-kms"
      "aws-sdk-lambda"
      "aws-sdk-macie2"
      "aws-sdk-mq"
      "aws-sdk-networkfirewall"
      "aws-sdk-networkmanager"
      "aws-sdk-organizations"
      "aws-sdk-ram"
      "aws-sdk-rds"
      "aws-sdk-redshift"
      "aws-sdk-route53"
      "aws-sdk-route53domains"
      "aws-sdk-route53resolver"
      "aws-sdk-s3"
      "aws-sdk-s3control"
      "aws-sdk-secretsmanager"
      "aws-sdk-securityhub"
      "aws-sdk-servicecatalog"
      "aws-sdk-ses"
      "aws-sdk-shield"
      "aws-sdk-signer"
      "aws-sdk-simpledb"
      "aws-sdk-sms"
      "aws-sdk-sns"
      "aws-sdk-sqs"
      "aws-sdk-ssm"
      "aws-sdk-states"
      "aws-sdk-synthetics"
      "aws-sdk-transfer"
      "aws-sdk-waf"
      "aws-sdk-wafv2"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18lwwmbq4l0b6k48gbd1frcdzk6k95alcwvrxraic56fmfdxzsiz";
      type = "gem";
    };
  };

  train-core = {
    version = "3.13.4";

    dependencies = [
      "addressable"
      "ffi"
      "json"
      "mixlib-shellout"
      "net-scp"
      "net-ssh"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pimza1lq703awwsnxsl1kb014lxkr2saxz031grjsf81098108d";
      type = "gem";
    };
  };

  train-habitat = {
    version = "0.2.22";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qdi2q5djzfl6x3fv2vrvybjdvrnx53nfh4vzrcl2h7nrf801n6v";
      type = "gem";
    };
  };

  train-kubernetes = {
    version = "0.3.1";

    dependencies = [
      "k8s-ruby"
      "train"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11g999llcda73f4s0lj0xh1158hfk8m7n7brm373fpyf3gsd15c5";
      type = "gem";
    };
  };

  train-winrm = {
    version = "0.4.0";

    dependencies = [
      "chef-winrm"
      "chef-winrm-elevated"
      "chef-winrm-fs"
      "socksify"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nbzs6j6fnfmlhdpcqfh6d7iazb5l6xvan57krznlzvh00cr3c87";
      type = "gem";
    };
  };

  tty-box = {
    version = "0.7.0";

    dependencies = [
      "pastel"
      "strings"
      "tty-cursor"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12yzhl3s165fl8pkfln6mi6mfy3vg7p63r3dvcgqfhyzq6h57x0p";
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

  tty-table = {
    version = "0.12.0";

    dependencies = [
      "pastel"
      "strings"
      "tty-screen"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fcrbfb0hjd9vkkazkksri93dv9wgs2hp6p1xwb1lp43a13pmhpx";
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

  unicode_utils = {
    version = "1.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0h1a5yvrxzlf0lxxa1ya31jcizslf774arnsd89vgdhk4g7x08mr";
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

  yajl-ruby = {
    version = "1.4.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lni4jbyrlph7sz8y49q84pb0sbj82lgwvnjnsiv01xf26f4v5wc";
      type = "gem";
    };
  };

  yaml-safe_load_stream3 = {
    version = "0.1.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10g4wy0vmggxnb3bz1zz74rfhhzqa50hc553sn7yqrbywpzn6kzx";
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
}
