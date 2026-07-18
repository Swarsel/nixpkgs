{
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
    version = "1.1246.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07da9w33fawd8wk6zrqjjhlgil4zry728ycq3ijym93vig9xg740";
      type = "gem";
    };
  };

  aws-sdk-autoscaling = {
    version = "1.157.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1izs8kry92cp6hrxvfc1pfdk3dzn5nc12kvfmkc45sapspr9dkkl";
      type = "gem";
    };
  };

  aws-sdk-cloudwatch = {
    version = "1.135.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fl5i8lr642xz23papxyla2aidkq4mpzfzp495r5knzanf0hvzy6";
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

  aws-sdk-dynamodb = {
    version = "1.165.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1q2yqylxlh1g22ilxlws643phpny7y3k2qb7bkxawair2af09grx";
      type = "gem";
    };
  };

  aws-sdk-ec2 = {
    version = "1.615.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1h58l0q7lav30qxligsa6p4nwdy4falnqjnklj3lbpwm7ipqy8rs";
      type = "gem";
    };
  };

  aws-sdk-efs = {
    version = "1.108.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09k5dmc2wzfm9ydny45s95rpmsgkh2g1r3sdsb085jn25y5gkv30";
      type = "gem";
    };
  };

  aws-sdk-elasticache = {
    version = "1.141.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0y2sis5df1ml105383w75q77fdpyyhdz946s7s3ls2kjs4c95p5m";
      type = "gem";
    };
  };

  aws-sdk-elasticloadbalancing = {
    version = "1.87.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0s1ahl61g0zszb7r85plpn98j1r1fqrvfl99xaghj1gilkj7j558";
      type = "gem";
    };
  };

  aws-sdk-elasticloadbalancingv2 = {
    version = "1.149.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1z1jgh4l9wbqq3yfs4pb8x2gjjlf7v49bifpcqz8lpppx1cchpsq";
      type = "gem";
    };
  };

  aws-sdk-iam = {
    version = "1.143.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14lhz5awd4g7nyaqq7vdigsw45r1vz7vbmkfhgp3946pxiib6cv5";
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

  aws-sdk-rds = {
    version = "1.311.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dz2i37rzw0g3dxwkf0n5f10cf7cps9qhgv7icgxs0l9skni05sm";
      type = "gem";
    };
  };

  aws-sdk-redshift = {
    version = "1.157.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0x3vrv3fzlrwfcdfpla7klr52ss6riwk4f4gx9mvyqddr2p0gzb4";
      type = "gem";
    };
  };

  aws-sdk-route53 = {
    version = "1.132.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mxqm5b33irbif77gmfjbbbr35bgiqndfrxr2wadagf3ibyyg6mj";
      type = "gem";
    };
  };

  aws-sdk-s3 = {
    version = "1.221.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sdk-kms"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14alz3zcb8lji49js6v73l403r35iyflf61fn281wfh8nbm8hm50";
      type = "gem";
    };
  };

  aws-sdk-sns = {
    version = "1.113.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03qva7pdyc1wyjhp6dpci50w3r9w8qy17wn2nhl4qvz82383gzhm";
      type = "gem";
    };
  };

  aws-sdk-sqs = {
    version = "1.112.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bmx3cbxsznrwq43pbvswb689fszfqxrl3zdm32a3nnkky8jsai7";
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
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yx9yn47a8lkfcjmigk79fykxvr80r4m1i35q82sxzynpbm7lcr7";
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

  multi_json = {
    version = "1.12.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1raim9ddjh672m32psaa9niw67ywzjbxbdb8iijx3wv9k5b0pk2x";
      type = "gem";
    };
  };

  terraforming = {
    version = "0.18.0";

    dependencies = [
      "aws-sdk-autoscaling"
      "aws-sdk-cloudwatch"
      "aws-sdk-dynamodb"
      "aws-sdk-ec2"
      "aws-sdk-efs"
      "aws-sdk-elasticache"
      "aws-sdk-elasticloadbalancing"
      "aws-sdk-elasticloadbalancingv2"
      "aws-sdk-iam"
      "aws-sdk-kms"
      "aws-sdk-rds"
      "aws-sdk-redshift"
      "aws-sdk-route53"
      "aws-sdk-s3"
      "aws-sdk-sns"
      "aws-sdk-sqs"
      "multi_json"
      "thor"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03fyhqx6bxpbn26pbcz748gz7rh7q3r9r0jimq7vj07fl454fmwh";
      type = "gem";
    };
  };

  thor = {
    version = "1.5.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wsy88vg2mazl039392hqrcwvs5nb9kq8jhhrrclir2px1gybag3";
      type = "gem";
    };
  };
}
