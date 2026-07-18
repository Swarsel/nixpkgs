{
  openssl,
  self,
}:

with self;

{

  async = janePackage {
    pname = "async";

    propagatedBuildInputs = [
      async_extra
      textutils
    ];

    hash = "0pk7z3h2gi21nfchvmjz2wx516bynf9vgwf84zf5qhvlvqqsmyrx";
    meta.description = "Monadic concurrency library";
  };

  async_extra = janePackage {
    pname = "async_extra";

    propagatedBuildInputs = [
      async_rpc_kernel
      async_unix
    ];

    hash = "10j4mwlyqvf67yrp5dwd857llqjinpnnykmlzw2gpmks9azxk6mh";
    meta.description = "Monadic concurrency library";
  };

  async_find = janePackage {
    pname = "async_find";
    propagatedBuildInputs = [ async ];
    hash = "0qsz9f15s5rlk6za10s810v6nlkdxg2g9p1827lcpa7nhjcpi673";
    meta.description = "Directory traversal with Async";
  };

  async_kernel = janePackage {
    pname = "async_kernel";
    propagatedBuildInputs = [ core_kernel ];
    hash = "1d9illx7vvpblj1i2r9y0f2yff2fbhy3rp4hhvamq1n9n3lvxmh2";
    meta.description = "Monadic concurrency library";
  };

  async_rpc_kernel = janePackage {
    pname = "async_rpc_kernel";

    propagatedBuildInputs = [
      async_kernel
      protocol_version_header
    ];

    hash = "1znhqbzx4fp58i7dbcgyv5rx7difbhb5d8cbqzv96yqvbn67lsjk";
    meta.description = "Platform-independent core of Async RPC library";
  };

  async_shell = janePackage {
    pname = "async_shell";

    propagatedBuildInputs = [
      async
      shell
    ];

    hash = "0cxln9hkc3cy522la9yi9p23qjwl69kqmadsq4lnjh5bxdad06sv";
    meta.description = "Shell helpers for Async";
  };

  async_unix = janePackage {
    pname = "async_unix";

    propagatedBuildInputs = [
      async_kernel
      core
    ];

    hash = "09h10rdyykbm88n6r9nb5a22mlb6vcxa04q6hvrcr0kys6qhhqmb";
    meta.description = "Monadic concurrency library";
  };

  base = janePackage {
    pname = "base";
    version = "0.12.2";
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ sexplib0 ];
    hash = "0gl89zpgsf3n30nb6v5cns27g2bfg4rf3s2427gqvwbkr5gcf7ri";
    meta.description = "Full standard library replacement for OCaml";
  };

  base_bigstring = janePackage {
    pname = "base_bigstring";
    propagatedBuildInputs = [ ppx_jane ];
    hash = "0rbgyg511847fbnxad40prz2dyp4da6sffzyzl88j18cxqxbh1by";
    meta.description = "String type based on [Bigarray], for use in I/O and C-bindings";
  };

  base_quickcheck = janePackage {
    pname = "base_quickcheck";
    version = "0.12.1";

    propagatedBuildInputs = [
      ppx_base
      ppx_fields_conv
      ppx_let
      splittable_random
    ];

    hash = "sha256-ABfUtOzdtGrYR6EgtVYkmxRvsH48jJwSVVOwf4Od12Y=";
    meta.description = "Randomized testing framework, designed for compatibility with Base";
  };

  bin_prot = janePackage {
    pname = "bin_prot";

    propagatedBuildInputs = [
      ppx_compare
      ppx_custom_printf
      ppx_fields_conv
      ppx_variants_conv
    ];

    hash = "0hh6s7g9s004z35hsr8z6nw5phlcvcd6g2q3bj4f0s1s0anlsswm";
    meta.description = "Binary protocol generator";
  };

  core = janePackage {
    pname = "core";
    version = "0.12.3";
    buildInputs = [ jst-config ];

    propagatedBuildInputs = [
      core_kernel
      spawn
    ];

    hash = "1vmjqiafkg45hqfvahx6jnlaww1q4a4215k8znbgprf0qn3zymnj";
    meta.description = "System-independent part of Core";
  };

  core_bench = janePackage {
    pname = "core_bench";
    propagatedBuildInputs = [ textutils ];
    hash = "00hyzbbj19dkcw0vhfnc8w0ca3zkjriwwvl00ssa0a2g9mygijdm";
    meta.description = "Benchmarking library";
  };

  core_extended = janePackage {
    pname = "core_extended";
    propagatedBuildInputs = [ core ];
    hash = "1gwx66235irpf5krb1r25a3c7w52qhmass8hp7rdv89il9jn49w4";
    meta.description = "Extra components that are not as closely vetted or as stable as Core";
  };

  core_kernel = janePackage {
    pname = "core_kernel";
    version = "0.12.3";
    buildInputs = [ jst-config ];

    propagatedBuildInputs = [
      base_bigstring
      sexplib
    ];

    hash = "sha256-bDgxuOILAs4FYB8o92ysPHDdEzflZMsU/jk5hB9xfuc=";
    meta.description = "System-independent part of Core";
  };

  ecaml = janePackage {
    pname = "ecaml";

    propagatedBuildInputs = [
      async
      expect_test_helpers_kernel
    ];

    hash = "0n9xi6agc3lgyj2nsi10cbif0xwn57xyaranad9r285rmbxrgjh7";
    meta.description = "Library for writing Emacs plugin in OCaml";
  };

  expect_test_helpers = janePackage {
    pname = "expect_test_helpers";

    propagatedBuildInputs = [
      async
      expect_test_helpers_kernel
    ];

    hash = "0ixqck2lnsmz107yw0q2sr8va80skjpldx7lz4ymjiq2vsghk0rb";
    meta.description = "Async helpers for writing expectation tests";
  };

  expect_test_helpers_kernel = janePackage {
    pname = "expect_test_helpers_kernel";
    buildInputs = [ ppx_jane ];

    propagatedBuildInputs = [
      core_kernel
      sexp_pretty
    ];

    hash = "18ya187y2i2hfxr771sd9vy5jdsa30vhs56yjdhwk06v01b2fzbq";
    meta.description = "Helpers for writing expectation tests";
  };

  fieldslib = janePackage {
    pname = "fieldslib";
    propagatedBuildInputs = [ base ];
    hash = "0dlgr7cimqmjlcymk3bdcyzqzvdy12q5lqa844nqix0k2ymhyphf";
    meta.description = "Syntax extension to define first class values representing record fields, to get and set record fields, iterate and fold over all fields of a record and create new record values";
  };

  jane-street-headers = janePackage {
    pname = "jane-street-headers";
    hash = "0qa4llf812rjqa8nb63snmy8d8ny91p3anwhb50afb7vjaby8m34";
    meta.description = "Jane Street C header files";
  };

  jst-config = janePackage {
    pname = "jst-config";

    buildInputs = [
      dune-configurator
      ppx_assert
    ];

    hash = "0yxcz13vda1mdh9ah7qqxwfxpcqang5sgdssd8721rszbwqqaw93";
    meta.description = "Compile-time configuration for Jane Street libraries";
  };

  ocaml-compiler-libs = janePackage {
    pname = "ocaml-compiler-libs";
    hash = "0g9y1ljjsj1nw0lz460ivb6qmz9vhcmfl8krlmqfrni6pc7b0r6f";
    meta.description = "OCaml compiler libraries repackaged";
  };

  parsexp = janePackage {
    pname = "parsexp";

    propagatedBuildInputs = [
      base
      sexplib0
    ];

    hash = "1974i9s2c2n03iffxrm6ncwbd2gg6j6avz5jsxfd35scc2zxcd4l";
    meta.description = "S-expression parsing library";
  };

  patience_diff = janePackage {
    pname = "patience_diff";
    propagatedBuildInputs = [ core_kernel ];
    hash = "055kd3piadjnplip8c8q99ssh79d4irmhg2wng7aida5pbqp2p9f";
    meta.description = "Diff library using Bram Cohen's patience diff algorithm";
  };

  ppx_assert = janePackage {
    pname = "ppx_assert";

    propagatedBuildInputs = [
      ppx_compare
      ppx_here
      ppx_sexp_conv
    ];

    hash = "0as6mzr6ki2a9d4k6132p9dskn0qssla1s7j5rkzp75bfikd0ip8";
    meta.description = "Assert-like extension nodes that raise useful errors on failure";
  };

  ppx_base = janePackage {
    pname = "ppx_base";

    propagatedBuildInputs = [
      ppx_enumerate
      ppx_hash
      ppx_js_style
    ];

    hash = "0vd96rp2l084iamkwmvizzhl9625cagjb6gzzbir06czii5mlq2p";
    meta.description = "Base set of ppx rewriters";
  };

  ppx_bench = janePackage {
    pname = "ppx_bench";
    propagatedBuildInputs = [ ppx_inline_test ];
    hash = "1ib81irawxzq091bmpi50z0kmpx6z2drg14k2xcgmwbb1d4063xn";
    meta.description = "Syntax extension for writing in-line benchmarks in ocaml code";
  };

  ppx_bin_prot = janePackage {
    pname = "ppx_bin_prot";
    version = "0.12.1";

    propagatedBuildInputs = [
      bin_prot
      ppx_here
    ];

    hash = "1j0kjgmv58dmg3x5dj5zrfbm920rwq21lvkkaqq493y76cd0x8xg";
    meta.description = "Generation of bin_prot readers and writers from types";
  };

  ppx_compare = janePackage {
    pname = "ppx_compare";
    propagatedBuildInputs = [ ppxlib ];
    hash = "0n1ax4k2smhps9hc2v58lc06a0fgimwvbi1aj4x78vwh5j492bys";
    meta.description = "Generation of comparison functions from types";
  };

  ppx_custom_printf = janePackage {
    pname = "ppx_custom_printf";
    version = "0.12.1";
    propagatedBuildInputs = [ ppx_sexp_conv ];
    hash = "0q7591agvd3qy9ihhbyk4db48r0ng7yxspfj8afxxiawl7k5bas6";
    meta.description = "Printf-style format-strings for user-defined string conversion";
  };

  ppx_enumerate = janePackage {
    pname = "ppx_enumerate";
    propagatedBuildInputs = [ ppxlib ];
    hash = "08zfpq6bdm5lh7xj9k72iz9f2ihv3aznl3nypw3x78vz1chj8dqa";
    meta.description = "Generate a list containing all values of a finite type";
  };

  ppx_expect = janePackage {
    pname = "ppx_expect";

    propagatedBuildInputs = [
      ppx_assert
      ppx_custom_printf
      ppx_fields_conv
      ppx_inline_test
      ppx_variants_conv
      re
    ];

    hash = "1wawsbjfkri4sw52n8xqrzihxc3xfpdicv3ahz83a1rsn4lb8j5q";
    meta.description = "Cram like framework for OCaml";
  };

  ppx_fail = janePackage {
    pname = "ppx_fail";
    propagatedBuildInputs = [ ppx_here ];
    hash = "0krsv6z9gi0ifxmw5ss6gwn108qhywyhbs41an10x9d5zpgf4l1n";
    meta.description = "Add location to calls to failwiths";
  };

  ppx_fields_conv = janePackage {
    pname = "ppx_fields_conv";

    propagatedBuildInputs = [
      fieldslib
      ppxlib
    ];

    hash = "0flrdyxdfcqcmdrbipxdjq0s3djdgs7z5pvjdycsvs6czbixz70v";
    meta.description = "Generation of accessor and iteration functions for ocaml records";
  };

  ppx_hash = janePackage {
    pname = "ppx_hash";

    propagatedBuildInputs = [
      ppx_compare
      ppx_sexp_conv
    ];

    hash = "1dfsfvhiyp1mnf24mr93svpdn432kla0y7x631lssacxxp2sadbg";
    meta.description = "PPX rewriter that generates hash functions from type expressions and definitions";
  };

  ppx_here = janePackage {
    pname = "ppx_here";
    propagatedBuildInputs = [ ppxlib ];
    hash = "07qbchwif1i9ii8z7v1bib57d3mjv0b27i8iixw78i83wnsycmdx";
    meta.description = "Expands [%here] into its location";
  };

  ppx_inline_test = janePackage {
    pname = "ppx_inline_test";
    propagatedBuildInputs = [ ppxlib ];
    hash = "0nyz411zim94pzbxm2l2v2l9jishcxwvxhh142792g2s18r4vn50";
    meta.description = "Syntax extension for writing in-line tests in ocaml code";
  };

  ppx_jane = janePackage {
    pname = "ppx_jane";

    propagatedBuildInputs = [
      base_quickcheck
      ppx_bench
      ppx_bin_prot
      ppx_expect
      ppx_fail
      ppx_module_timer
      ppx_optcomp
      ppx_optional
      ppx_pipebang
      ppx_sexp_value
      ppx_stable
      ppx_typerep_conv
    ];

    hash = "1a2602isqzsh640q20qbmarx0sc316mlsqc3i25ysv2kdyhh0kyw";
    meta.description = "Standard Jane Street ppx rewriters";
  };

  ppx_js_style = janePackage {
    pname = "ppx_js_style";

    propagatedBuildInputs = [
      octavius
      ppxlib
    ];

    hash = "1lz931m3qdv3yzqy6dnb8fq1d99r61w0n7cwf3b9fl9rhk0pggwh";
    meta.description = "Code style checker for Jane Street Packages";
  };

  ppx_let = janePackage {
    pname = "ppx_let";
    propagatedBuildInputs = [ ppxlib ];
    hash = "146dmyzkbmafa3giz69gpxccvdihg19cvk4xsg8krbbmlkvdda22";
    meta.description = "Monadic let-bindings";
  };

  ppx_module_timer = janePackage {
    pname = "ppx_module_timer";
    propagatedBuildInputs = [ time_now ];
    hash = "0yziakm7f4c894na76k1z4bp7azy82xc33mh36fj761w1j9zy3wm";
    meta.description = "Ppx rewriter that records top-level module startup times";
  };

  ppx_optcomp = janePackage {
    pname = "ppx_optcomp";
    propagatedBuildInputs = [ ppxlib ];
    hash = "0bdbx01kz0174g1szdhv3mcfqxqqf2frxq7hk13xaf6fsz04kwmj";
    meta.description = "Optional compilation for OCaml";
  };

  ppx_optional = janePackage {
    pname = "ppx_optional";
    propagatedBuildInputs = [ ppxlib ];
    hash = "07i0iipbd5xw2bc604qkwlcxmhncfpm3xmrr6svyj2ij86pyssh8";
    meta.description = "Pattern matching on flat options";
  };

  ppx_pipebang = janePackage {
    pname = "ppx_pipebang";
    propagatedBuildInputs = [ ppxlib ];
    hash = "1p4pdpl8h2bblbhpn5nk17ri4rxpz0aih0gffg3cl1186irkj0xj";
    meta.description = "PPX rewriter that inlines reverse application operators `|>` and `|!`";
  };

  ppx_sexp_conv = janePackage {
    pname = "ppx_sexp_conv";
    propagatedBuildInputs = [ ppxlib ];
    hash = "0idzp1kzds0gnilschzs9ydi54if8y5xpn6ajn710vkipq26qcld";
    meta.description = "[@@deriving] plugin to generate S-expression conversion functions";
  };

  ppx_sexp_message = janePackage {
    pname = "ppx_sexp_message";

    propagatedBuildInputs = [
      ppx_here
      ppx_sexp_conv
    ];

    hash = "0yskd6v48jc6wa0nhg685kylh1n9qb6b7d1wglr9wnhl9sw990mc";
    meta.description = "PPX rewriter for easy construction of s-expressions";
  };

  ppx_sexp_value = janePackage {
    pname = "ppx_sexp_value";

    propagatedBuildInputs = [
      ppx_here
      ppx_sexp_conv
    ];

    hash = "1mg81834a6dx1x7x9zb9wc58438cabjjw08yhkx6i386hxfy891p";
    meta.description = "PPX rewriter that simplifies building s-expressions from ocaml values";
  };

  ppx_stable = janePackage {
    pname = "ppx_stable";
    propagatedBuildInputs = [ ppxlib ];
    hash = "15zvf66wlkvz0yd4bkvndkpq74dj20jv1qkljp9n52hh7d0f9ykh";
    meta.description = "Stable types conversions generator";
  };

  ppx_typerep_conv = janePackage {
    pname = "ppx_typerep_conv";

    propagatedBuildInputs = [
      ppxlib
      typerep
    ];

    hash = "09vik6qma1id44k8nz87y48l9wbjhqhap1ar1hpfdfkjai1hrzzq";
    meta.description = "Generation of runtime types from type declarations";
  };

  ppx_variants_conv = janePackage {
    pname = "ppx_variants_conv";

    propagatedBuildInputs = [
      variantslib
      ppxlib
    ];

    hash = "05j9bgra8xq6fcp12ch3z9vjrk139p2wrcjjcs4h52n5hhc8vzbz";
    meta.description = "Generation of accessor and iteration functions for ocaml variant types";
  };

  protocol_version_header = janePackage {
    pname = "protocol_version_header";
    propagatedBuildInputs = [ core_kernel ];
    hash = "14vqhx3r84rlfhcjq52gxdqksckiaswlck9s47g7y2z1lsc17v7r";
    meta.description = "Protocol versioning";
  };

  re2 = janePackage {
    pname = "re2";
    version = "0.12.1";
    propagatedBuildInputs = [ core_kernel ];
    hash = "sha256-NPQKKUSwckZx4GN4wX2sc0Mn7bes6p79oZrN6xouc6o=";

    prePatch = ''
      substituteInPlace src/re2_c/dune --replace 'CXX=g++' 'CXX=c++'
      substituteInPlace src/dune --replace '(cxx_flags (:standard \ -pedantic) (-I re2_c/libre2))' '(cxx_flags (:standard \ -pedantic) (-I re2_c/libre2) (-x c++))'
    '';

    meta.description = "OCaml bindings for RE2, Google's regular expression library";
  };

  sexp_pretty = janePackage {
    pname = "sexp_pretty";

    propagatedBuildInputs = [
      ppx_base
      re
      sexplib
    ];

    hash = "06hdsaszc5cd7fphiblbn4r1sh36xgjwf2igzr2rvlzqs7jiv2v4";
    meta.description = "S-expression pretty-printer";
  };

  sexplib = janePackage {
    pname = "sexplib";

    propagatedBuildInputs = [
      num
      parsexp
    ];

    hash = "0780klc5nnv0ij6aklzra517cfnfkjdlp8ylwjrqwr8dl9rvxza2";
    meta.description = "Library for serializing OCaml values to and from S-expressions";
  };

  sexplib0 = janePackage {
    pname = "sexplib0";
    hash = "13xdd0pvypxqn0ldwdgikmlinrp3yfh8ixknv1xrpxbx3np4qp0g";
    meta.description = "Library containing the definition of S-expressions and some base converters";
  };

  shell = janePackage {
    pname = "shell";
    buildInputs = [ jst-config ];

    propagatedBuildInputs = [
      re2
      textutils
    ];

    hash = "158857rdr6qgglc5iksg0l54jgf51b5lmsw7nlazpxwdwc9fcn5n";
    meta.description = "Yet another implementation of fork&exec and related functionality";
  };

  spawn = janePackage {
    pname = "spawn";
    version = "0.13.0";
    buildInputs = [ ppx_expect ];
    hash = "1w003k1kw1lmyiqlk58gkxx8rac7dchiqlz6ah7aj7bh49b36ppf";
    meta.description = "Spawning sub-processes";
  };

  splittable_random = janePackage {
    pname = "splittable_random";

    propagatedBuildInputs = [
      base
      ppx_assert
      ppx_bench
      ppx_sexp_message
    ];

    hash = "1wpyz7807cgj8b50gdx4rw6f1zsznp4ni5lzjbnqdwa66na6ynr4";
    meta.description = "PRNG that can be split into independent streams";
  };

  stdio = janePackage {
    pname = "stdio";
    propagatedBuildInputs = [ base ];
    hash = "1pn8jjcb79n6crpw7dkp68s4lz2mw103lwmfslil66f05jsxhjhg";
    meta.description = "Standard IO library for OCaml";
  };

  textutils = janePackage {
    pname = "textutils";
    propagatedBuildInputs = [ core ];
    hash = "0302awqihf3abib9mvzvn4g8m364hm6jxry1r3kc01hzybhy9acq";
    meta.description = "Text output utilities";
  };

  time_now = janePackage {
    pname = "time_now";

    buildInputs = [
      jst-config
      ppx_optcomp
    ];

    propagatedBuildInputs = [
      jane-street-headers
      base
      ppx_base
    ];

    hash = "169mgsb3rja4j1j9nj5xa7bbkd21p9kfpskqz0wjf9x2fpxqsniq";
    meta.description = "Reports the current time";
  };

  typerep = janePackage {
    pname = "typerep";
    propagatedBuildInputs = [ base ];
    hash = "1psl6gsk06a62szh60y5sc1s92xpmrl1wpw3rhha09v884b7arbc";
    meta.description = "Typerep is a library for runtime types";
  };

  variantslib = janePackage {
    pname = "variantslib";
    propagatedBuildInputs = [ base ];
    hash = "1cclb5magk63gyqmkci8abhs05g2pyhyr60a2c1bvmig0faqcnsf";
    meta.description = "Part of Jane Street's Core library";
  };

}
