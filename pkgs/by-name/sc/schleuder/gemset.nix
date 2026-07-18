{
  activemodel = {
    version = "6.1.7.7";
    dependencies = [ "activesupport" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0zz32997k2fsyd0fzrh8f79yjr6hv3i4j9wykkxncl02j8dhrkay";
      type = "gem";
    };
  };

  activerecord = {
    version = "6.1.7.7";

    dependencies = [
      "activemodel"
      "activesupport"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qzymgyrvw2k32ldabp2jr0zgp6z9w8smyb946qgvs9zfs4n2qnn";
      type = "gem";
    };
  };

  activesupport = {
    version = "6.1.7.7";

    dependencies = [
      "concurrent-ruby"
      "i18n"
      "minitest"
      "tzinfo"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0r2i9b0pm0b1dy8fc7kyls1g7f0bcnyq53v825rykibzdqfqdfgp";
      type = "gem";
    };
  };

  bcrypt = {
    version = "3.1.20";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16a0g2q40biv93i1hch3gw8rbmhp77qnnifj1k0a6m7dng3zh444";
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

  concurrent-ruby = {
    version = "1.3.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kmhr3pz2nmhnq0nqlicqfwfmkzkcl835g7sw1gjjhjvhz8g2sf3";
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

  gpgme = {
    version = "2.0.24";
    dependencies = [ "mini_portile2" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0r1vmql7w7ka5xzj1aqf8pk2a4sv0znwj2zkg1fgvd5b89qcvv2k";
      type = "gem";
    };
  };

  i18n = {
    version = "1.14.5";
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ffix518y7976qih9k1lgnc17i3v6yrlh0a3mckpxdb4wc2vrp16";
      type = "gem";
    };
  };

  mail = {
    version = "2.7.1";
    dependencies = [ "mini_mime" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00wwz6ys0502dpk8xprwcqfwyf3hmnx6lgxaiq6vj43mkx43sapc";
      type = "gem";
    };
  };

  mail-gpg = {
    version = "0.4.4";

    dependencies = [
      "gpgme"
      "mail"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rz936m8nacy7agksvpvkf6b37d1h5qvh5xkrjqvv5wbdqs3cyfj";
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
    version = "2.8.6";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "149r94xi6b3jbp6bv72f8383b95ndn0p5sxnq11gs1j9jadv0ajf";
      type = "gem";
    };
  };

  minitest = {
    version = "5.23.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gkslxvkhh44s21rbjvka3zsvfxxrf5pcl6f75rv2vyrzzbgis7i";
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

  mustermann = {
    version = "2.0.2";
    dependencies = [ "ruby2_keywords" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0m70qz27mlv2rhk4j1li6pw797gmiwwqg02vcgxcxr1rq2v53rnb";
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

  rack = {
    version = "2.2.9";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hj0rkw2z9r1lcg2wlrcld2n3phwrcgqcp7qd1g9a7hwgalh2qzx";
      type = "gem";
    };
  };

  rack-protection = {
    version = "2.2.4";
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1d6irsigm0i4ig1m47c94kixi3wb8jnxwvwkl8qxvyngmb73srl2";
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

  schleuder = {
    version = "4.0.3";

    dependencies = [
      "activerecord"
      "bcrypt"
      "charlock_holmes"
      "gpgme"
      "mail"
      "mail-gpg"
      "rake"
      "sinatra"
      "sinatra-contrib"
      "sqlite3"
      "thin"
      "thor"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0lxmi7402v5qkajx3j5bydarxf3lbm1kzpwgy7zsmc7l28mcv8wx";
      type = "gem";
    };
  };

  sinatra = {
    version = "2.2.4";

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
      sha256 = "0wkc079h6hzq737j4wycpnv7c38mhd0rl33pszyy7768zzvyjc9y";
      type = "gem";
    };
  };

  sinatra-contrib = {
    version = "2.2.4";

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
      sha256 = "0s6c1k3zzxp3xa7libvlpqaby27124rccyyxcsly04ih904cxk33";
      type = "gem";
    };
  };

  sqlite3 = {
    version = "1.4.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1z1wa639c278bsipczn6kv8b13fj85pi8gk7x462chqx6k0wm0ax";
      type = "gem";
    };
  };

  thin = {
    version = "1.8.2";

    dependencies = [
      "daemons"
      "eventmachine"
      "rack"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08g1yq6zzvgndj8fd98ah7pp8g2diw28p8bfjgv7rvjvp8d2am8w";
      type = "gem";
    };
  };

  thor = {
    version = "0.20.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yhrnp9x8qcy5vc7g438amd5j9sw83ih7c30dr6g6slgw9zj3g29";
      type = "gem";
    };
  };

  tilt = {
    version = "2.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0p3l7v619hwfi781l3r7ypyv1l8hivp09r18kmkn6g11c4yr1pc2";
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

  zeitwerk = {
    version = "2.6.15";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kr2731z8f6cj23jxh67cdnpkrnnfwbrxj1hfhshls4mp8i8drmj";
      type = "gem";
    };
  };
}
