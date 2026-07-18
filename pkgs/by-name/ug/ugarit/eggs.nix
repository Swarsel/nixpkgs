{ eggDerivation, fetchegg }:
rec {
  aes = eggDerivation {
    src = fetchegg {
      sha256 = "0gjlvz5nk0fnaclljpyfk21rkf0nidjj6wcv3jbnpmfafgjny5fi";
      name = "aes";
      version = "1.5";
    };

    buildInputs = [

    ];

    name = "aes-1.5";
  };

  bind = eggDerivation {
    src = fetchegg {
      sha256 = "1x768k7dlfmkvgaf2idiaaqqgnqdnif5yb7ib6a6zndacbwz9jps";
      name = "bind";
      version = "1.5.2";
    };

    buildInputs = [
      silex
      matchable
      coops
      regex
      make
    ];

    name = "bind-1.5.2";
  };

  blob-utils = eggDerivation {
    src = fetchegg {
      sha256 = "17vdn02fnxnjx5ixgqimln93lqvzyq4y9w02fw7xnbdcjzqm0xml";
      name = "blob-utils";
      version = "1.0.3";
    };

    buildInputs = [
      setup-helper
      string-utils
    ];

    name = "blob-utils-1.0.3";
  };

  check-errors = eggDerivation {
    src = fetchegg {
      sha256 = "12a0sn82n98jybh72zb39fdddmr5k4785xglxb16750fhy8rmjwi";
      name = "check-errors";
      version = "1.13.0";
    };

    buildInputs = [
      setup-helper
    ];

    name = "check-errors-1.13.0";
  };

  coops = eggDerivation {
    src = fetchegg {
      sha256 = "0mrkk7pmn9r691svzm4113mn0xsk36zi3f15m86n29a6c7897php";
      name = "coops";
      version = "1.93";
    };

    buildInputs = [
      matchable
      record-variants
    ];

    name = "coops-1.93";
  };

  crypto-tools = eggDerivation {
    src = fetchegg {
      sha256 = "0442wly63zis19vh8xc9nhxgp9sabaccxylpzmchd5f1d48iag65";
      name = "crypto-tools";
      version = "1.3";
    };

    buildInputs = [

    ];

    name = "crypto-tools-1.3";
  };

  foreigners = eggDerivation {
    src = fetchegg {
      sha256 = "07nvyadhkd52q0kkvch1a5d7ivpmrhmyg295s4mxb1nw4wz46gfz";
      name = "foreigners";
      version = "1.4.1";
    };

    buildInputs = [
      matchable
    ];

    name = "foreigners-1.4.1";
  };

  lookup-table = eggDerivation {
    src = fetchegg {
      sha256 = "1nzly6rhynawlvzlyilk8z8cxz57cf9n5iv20glkhh28pz2izmrb";
      name = "lookup-table";
      version = "1.13.5";
    };

    buildInputs = [
      setup-helper
      check-errors
      miscmacros
      record-variants
      synch
    ];

    name = "lookup-table-1.13.5";
  };

  lru-cache = eggDerivation {
    src = fetchegg {
      sha256 = "0z6g3106c4j21v968hfzy9nnbfq2d83y0nyd20aifpq4g55c0d40";
      name = "lru-cache";
      version = "0.5.3";
    };

    buildInputs = [
      record-variants
    ];

    name = "lru-cache-0.5.3";
  };

  make = eggDerivation {
    src = fetchegg {
      sha256 = "1w6xsjyapi2x8dv21dpidkyw1kjfsbasddn554xx561pi3i0yv9h";
      name = "make";
      version = "1.8";
    };

    buildInputs = [

    ];

    name = "make-1.8";
  };

  matchable = eggDerivation {
    src = fetchegg {
      sha256 = "07y3lpzgm4djiwi9y2adc796f9kwkmdr28fkfkw65syahdax8990";
      name = "matchable";
      version = "3.3";
    };

    buildInputs = [

    ];

    name = "matchable-3.3";
  };

  message-digest = eggDerivation {
    src = fetchegg {
      sha256 = "1w6bax19dwgih78vcimiws0rja7qsd8hmbm6qqg2hf9cw3vab21s";
      name = "message-digest";
      version = "3.1.0";
    };

    buildInputs = [
      setup-helper
      miscmacros
      check-errors
      variable-item
      blob-utils
      string-utils
    ];

    name = "message-digest-3.1.0";
  };

  miscmacros = eggDerivation {
    src = fetchegg {
      sha256 = "1ajdgjrni10i2hmhcp4rawnxajjxry3kmq1krdmah4sf0kjrgajc";
      name = "miscmacros";
      version = "2.96";
    };

    buildInputs = [

    ];

    name = "miscmacros-2.96";
  };

  parley = eggDerivation {
    src = fetchegg {
      sha256 = "1vsbx4dk1240gzq02slzmavd1jrq04qj7ssnvg15h8xh81xwhbbz";
      name = "parley";
      version = "0.9.2";
    };

    buildInputs = [
      stty
      srfi-71
      miscmacros
    ];

    name = "parley-0.9.2";
  };

  pathname-expand = eggDerivation {
    src = fetchegg {
      sha256 = "14llya7l04z49xpi3iylk8aglrw968vy304ymavhhqlyzmzwkx3g";
      name = "pathname-expand";
      version = "0.1";
    };

    buildInputs = [

    ];

    name = "pathname-expand-0.1";
  };

  posix-extras = eggDerivation {
    src = fetchegg {
      sha256 = "0gnmhn2l0161ham7f8i0lx1ay94ap8l8l7ga4nw9qs86lk024abi";
      name = "posix-extras";
      version = "0.1.6";
    };

    patches = [
      # missing include <sys/sysmacros.h> since Jan 2025, cause unknown
      ./posix-extras-add-sysmacros-include.patch
    ];

    buildInputs = [

    ];

    name = "posix-extras-0.1.6";
  };

  record-variants = eggDerivation {
    src = fetchegg {
      sha256 = "15wgysxkm8m4hx9nhhw9akchzipdnqc7yj3qd3zn0z7sxg4sld1h";
      name = "record-variants";
      version = "0.5.1";
    };

    buildInputs = [

    ];

    name = "record-variants-0.5.1";
  };

  regex = eggDerivation {
    src = fetchegg {
      sha256 = "1z9bh7xvab6h5cdlsz8jk02pv5py1i6ryqarbcs3wdgkkjgmmkif";
      name = "regex";
      version = "1.0";
    };

    buildInputs = [

    ];

    name = "regex-1.0";
  };

  setup-helper = eggDerivation {
    src = fetchegg {
      sha256 = "1lpplp8f2wyc486dd98gs4wl1kkhh1cs6vdqkxrdk7f92ikmwbx3";
      name = "setup-helper";
      version = "1.5.5";
    };

    buildInputs = [

    ];

    name = "setup-helper-1.5.5";
  };

  sha2 = eggDerivation {
    src = fetchegg {
      sha256 = "01ch290f2kcv1yv8spjdaqwipl80vvgpqc4divsj3vxckvgkawq2";
      name = "sha2";
      version = "3.1.0";
    };

    buildInputs = [
      message-digest
    ];

    name = "sha2-3.1.0";
  };

  silex = eggDerivation {
    src = fetchegg {
      sha256 = "17x7f07aa3qnay3bhjr7knjivhycs54j97jyv3gjs1h8qnp63g00";
      name = "silex";
      version = "1.4";
    };

    buildInputs = [

    ];

    name = "silex-1.4";
  };

  sql-de-lite = eggDerivation {
    src = fetchegg {
      sha256 = "1mh3hpsibq2gxcpjaycqa4ckznj268xpfzsa6pn0i6iac6my3qra";
      name = "sql-de-lite";
      version = "0.6.6";
    };

    buildInputs = [
      lru-cache
      foreigners
    ];

    name = "sql-de-lite-0.6.6";
  };

  srfi-37 = eggDerivation {
    src = fetchegg {
      sha256 = "1a2zdkdzrv15fw9dfdy8067fsgh4kr8ppffm8mc3cmlczrrd58cb";
      name = "srfi-37";
      version = "1.3.1";
    };

    buildInputs = [

    ];

    name = "srfi-37-1.3.1";
  };

  srfi-71 = eggDerivation {
    src = fetchegg {
      sha256 = "01mlaxw2lfczykmx69xki2s0f4ywlg794rl4kz07plvzn0s3fbqq";
      name = "srfi-71";
      version = "1.1";
    };

    buildInputs = [

    ];

    name = "srfi-71-1.1";
  };

  ssql = eggDerivation {
    src = fetchegg {
      sha256 = "0qhnghhx1wrvav4s7l780mspwlh8s6kzq4bl0cslwp1km90fx9bk";
      name = "ssql";
      version = "0.2.4";
    };

    buildInputs = [
      matchable
    ];

    name = "ssql-0.2.4";
  };

  string-utils = eggDerivation {
    src = fetchegg {
      sha256 = "07alvghg0dahilrm4jg44bndl0x69sv1zbna9l20cbdvi35i0jp1";
      name = "string-utils";
      version = "1.2.4";
    };

    buildInputs = [
      setup-helper
      miscmacros
      lookup-table
      check-errors
    ];

    name = "string-utils-1.2.4";
  };

  stty = eggDerivation {
    src = fetchegg {
      sha256 = "09jmjpdsd3yg6d0f0imcihmn49i28x09lgl60i2dllffs25k22s4";
      name = "stty";
      version = "0.2.6";
    };

    buildInputs = [
      setup-helper
      foreigners
    ];

    name = "stty-0.2.6";
  };

  synch = eggDerivation {
    src = fetchegg {
      sha256 = "1m9mnbq0m5jsxmd1a3rqpwpxj0l1b7vn1fknvxycc047pmlcyl00";
      name = "synch";
      version = "2.1.2";
    };

    buildInputs = [
      setup-helper
      check-errors
    ];

    name = "synch-2.1.2";
  };

  tiger-hash = eggDerivation {
    src = fetchegg {
      sha256 = "0j9dsbjp9cw0y4w4srg0qwgh53jw2v3mx4y4h040ds0fkxlzzknx";
      name = "tiger-hash";
      version = "3.1.0";
    };

    buildInputs = [
      message-digest
    ];

    name = "tiger-hash-3.1.0";
  };

  ugarit = eggDerivation {
    src = fetchegg {
      sha256 = "1l5zkr6b8l5dw9p5mimbva0ncqw1sbvp3d4cywm1hqx2m03a0f1n";
      name = "ugarit";
      version = "2.0";
    };

    buildInputs = [
      miscmacros
      sql-de-lite
      crypto-tools
      srfi-37
      stty
      matchable
      regex
      tiger-hash
      message-digest
      posix-extras
      parley
      ssql
      pathname-expand
    ];

    name = "ugarit-2.0";
  };

  variable-item = eggDerivation {
    src = fetchegg {
      sha256 = "19b3mhb8kr892sz9yyzq79l0vv28dgilw9cf415kj6aq16yp4d5n";
      name = "variable-item";
      version = "1.3.1";
    };

    buildInputs = [
      setup-helper
      check-errors
    ];

    name = "variable-item-1.3.1";
  };

  z3 = eggDerivation {
    src = fetchegg {
      sha256 = "16ayp4zkgm332q4bmjj22acqg197aqp6d8ifyyjj205iv6k0f3x4";
      name = "z3";
      version = "1.44";
    };

    buildInputs = [
      bind
    ];

    name = "z3-1.44";
  };
}
