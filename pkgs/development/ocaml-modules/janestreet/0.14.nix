{
  lib,
  fetchpatch,
  openssl,
  self,
  zstd,
}:

with self;

{

  accessor = janePackage {
    pname = "accessor";
    version = "0.14.1";
    propagatedBuildInputs = [ higher_kinded ];
    hash = "0wm2081kzd5zsqs516cn3f975bnnmnyynv8fa818gmfa65i6mxm8";
    minimalOCamlVersion = "4.09";
    meta.description = "Library that makes it nicer to work with nested functional data structures";
  };

  accessor_async = janePackage {
    pname = "accessor_async";
    version = "0.14.1";

    propagatedBuildInputs = [
      accessor_core
      async_kernel
    ];

    hash = "1193hzvlzm7vcl9p67fs8al2pvkw9n2wz009m2l3lp35mrx8aq1w";
    minimalOCamlVersion = "4.09";
    meta.description = "Accessors for Async types, for use with the Accessor library";
  };

  accessor_base = janePackage {
    pname = "accessor_base";
    version = "0.14.1";
    propagatedBuildInputs = [ ppx_accessor ];
    hash = "1xjbvvijkyw4dlys47x4896y3kqm2zn0yg60cqrp57i2dwxg0nsj";
    minimalOCamlVersion = "4.09";
    meta.description = "Accessors for Base types, for use with the Accessor library";
  };

  accessor_core = janePackage {
    pname = "accessor_core";
    version = "0.14.1";

    propagatedBuildInputs = [
      accessor_base
      core_kernel
    ];

    hash = "1cdkv34m6czhacivpbb2sasj83fgcid6gnqk30ig9i84z8nh2gw2";
    minimalOCamlVersion = "4.09";
    meta.broken = true; # Not compatible with ppxlib ≥ 0.23
    meta.description = "Accessors for Core types, for use with the Accessor library";
  };

  async = janePackage {
    pname = "async";

    propagatedBuildInputs = [
      async_rpc_kernel
      async_unix
      textutils
    ];

    doCheck = false; # we don't have netkit_sockets
    hash = "086v93div4h9l02n7wzv3xx3i6xvddazydm9qlfa72ad55x3vzy0";
    meta.description = "Monadic concurrency library";
  };

  async_extra = janePackage {
    pname = "async_extra";
    propagatedBuildInputs = [ async_kernel ];
    hash = "16cnz9h4jkc3b0837s5z0iv92q7n5nw77g8qshq8pwq639y8ail4";
    meta.description = "Monadic concurrency library";
  };

  async_find = janePackage {
    pname = "async_find";
    propagatedBuildInputs = [ async ];
    hash = "0vlcpdr15bgrwrmixvs6ij88kvk8vzzrijz3zm0svxih0naf8ylx";
    meta.description = "Directory traversal with Async";
  };

  async_inotify = janePackage {
    pname = "async_inotify";

    propagatedBuildInputs = [
      async_find
      inotify
    ];

    hash = "0i0hf7nsir316ijixdj43qf0p3b6yapvcm2jzp7bhpf4r2kxislv";
    meta.description = "Async wrapper for inotify";
  };

  async_interactive = janePackage {
    pname = "async_interactive";
    propagatedBuildInputs = [ async ];
    hash = "1cnmv9mipa6k6xd303ngdbxmiab2202f3w3pgq8l1970w8hb78il";
    meta.description = "Utilities for building simple command-line based user interfaces";
  };

  async_js = janePackage {
    pname = "async_js";
    buildInputs = [ js_of_ocaml-ppx ];

    propagatedBuildInputs = [
      async_rpc_kernel
      js_of_ocaml
      uri-sexp
    ];

    hash = "0rld8792lfwbinn9rhrgacivz49vppgy29smpqnvpga89wchjv0v";
    meta.description = "Small library that provide Async support for JavaScript platforms";
  };

  async_kernel = janePackage {
    pname = "async_kernel";
    propagatedBuildInputs = [ core_kernel ];
    hash = "17giakwl0xhyxvxrkn12dwjdghc53q8px81z7cc3k6f102bsbdy6";
    meta.description = "Monadic concurrency library";
  };

  async_rpc_kernel = janePackage {
    pname = "async_rpc_kernel";

    propagatedBuildInputs = [
      async_kernel
      protocol_version_header
    ];

    hash = "1bwq3gkq057dd1fhrqz9kqq8a956nn87zaxvr0qcpiczzjv3zmvm";
    meta.description = "Platform-independent core of Async RPC library";
  };

  async_sendfile = janePackage {
    pname = "async_sendfile";
    propagatedBuildInputs = [ async_unix ];
    hash = "1w3gwwpgfzqjhblxnxh64g64q6kgjzzxx90inswfhycc88pnvdna";
    meta.description = "Thin wrapper around [Linux_ext.sendfile] to send full files";
  };

  async_shell = janePackage {
    pname = "async_shell";

    propagatedBuildInputs = [
      async
      shell
    ];

    hash = "1r00z620nqv2jxz2xrp2gsyc30h8dd2w9qsnys2fkqbgpxlbgdc7";
    meta.description = "Shell helpers for Async";
  };

  async_smtp = janePackage {
    pname = "async_smtp";

    propagatedBuildInputs = [
      async_extra
      async_inotify
      async_sendfile
      async_shell
      async_ssl
      email_message
      resource_cache
      re2_stable
      sexp_macro
    ];

    hash = "1xf3illn7vikdxldpnc29n4z8sv9f0wsdgdvl4iv93qlvjk8gzck";
    meta.description = "SMTP client and server";
  };

  async_ssl = janePackage {
    pname = "async_ssl";

    # in ctypes.foreign 0.18.0 threaded and unthreaded have been merged
    postPatch = ''
      substituteInPlace bindings/dune \
        --replace "ctypes.foreign.threaded" "ctypes.foreign"
    '';

    buildInputs = [ dune-configurator ];

    propagatedBuildInputs = [
      async
      ctypes
      ctypes-foreign
      openssl
    ];

    hash = "0ykys3ckpsx5crfgj26v2q3gy6wf684aq0bfb4q8p92ivwznvlzy";
    meta.broken = true;
    meta.description = "Async wrappers for SSL";
  };

  async_unix = janePackage {
    pname = "async_unix";

    propagatedBuildInputs = [
      async_kernel
      core
    ];

    hash = "1wgnr0vdsknqrfnf6irmwnvyngndsnvvl1sfnj3v6fhwk4nswnrs";
    meta.description = "Monadic concurrency library";
  };

  base = janePackage {
    pname = "base";
    version = "0.14.1";
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ sexplib0 ];
    checkInputs = [ alcotest ];
    hash = "1hizjxmiqlj2zzkwplzjamw9rbnl0kh44sxgjpzdij99qnfkzylf";
    minimalOCamlVersion = "4.07";
    meta.description = "Full standard library replacement for OCaml";
  };

  base_bigstring = janePackage {
    pname = "base_bigstring";
    propagatedBuildInputs = [ ppx_jane ];
    hash = "1ald2m7qywhxbygv58dzpgaj54p38zn0aiqd1z7i95kf3bsnsjqa";
    minimalOCamlVersion = "4.07";
    meta.description = "String type based on [Bigarray], for use in I/O and C-bindings";
  };

  base_quickcheck = janePackage {
    pname = "base_quickcheck";
    version = "0.14.1";

    propagatedBuildInputs = [
      ppx_base
      ppx_fields_conv
      ppx_let
      ppx_sexp_value
      splittable_random
    ];

    hash = "0apq3d9xb0zdaqsl4cjk5skyig57ff1plndb2mh0nn3czvfhifxs";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Randomized testing framework, designed for compatibility with Base";
  };

  bignum = janePackage {
    pname = "bignum";

    propagatedBuildInputs = [
      core_kernel
      zarith
      zarith_stubs_js
    ];

    hash = "009ygr64q810p9iq4mykzz4ci00i5mzgpmq35jiyaiqm27bjam21";
    meta.description = "Core-flavoured wrapper around zarith's arbitrary-precision rationals";
  };

  bin_prot = janePackage {
    pname = "bin_prot";

    propagatedBuildInputs = [
      ppx_compare
      ppx_custom_printf
      ppx_fields_conv
      ppx_optcomp
      ppx_variants_conv
    ];

    hash = "1qyqbfp4zdc2jb87370cdgancisqffhf9x60zgh2m31kqik8annr";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Binary protocol generator";
  };

  bonsai = janePackage {
    pname = "bonsai";
    buildInputs = [ ppx_pattern_bind ];
    propagatedBuildInputs = [ incr_dom ];
    hash = "0k4grabwqc9sy4shzp77bgfvyajvvc0l8qq89ia7cvlwvly7gv6a";
    meta.description = "Library for building dynamic webapps, using Js_of_ocaml";
  };

  cinaps = janePackage {
    pname = "cinaps";
    propagatedBuildInputs = [ re ];
    checkInputs = [ ppx_jane ];
    hash = "0ms1j2kh7i5slyw9v4w9kdz52dkwl5gqcnvn89prgimhk2vmichj";
    minimalOCamlVersion = "4.07";
    meta.description = "Trivial metaprogramming tool";
  };

  core = janePackage {
    pname = "core";
    version = "0.14.1";
    buildInputs = [ jst-config ];

    propagatedBuildInputs = [
      core_kernel
      spawn
      timezone
    ];

    doCheck = false; # we don't have quickcheck_deprecated
    hash = "1isrcl07nkmdm6akqsqs9z8s6zvva2lvg47kaagy7gsbyszrqb82";
    meta.description = "System-independent part of Core";
  };

  core_bench = janePackage {
    pname = "core_bench";
    propagatedBuildInputs = [ textutils ];
    hash = "04h6hzxk347pqyrrbgqrw9576sq4yf70fgq9xam3kajrqwdh3dhx";
    meta.description = "Benchmarking library";
  };

  core_extended = janePackage {
    pname = "core_extended";
    propagatedBuildInputs = [ core ];
    hash = "1pbm6xbc3h0fhrymyr1yb9b1jk7n88gfi3pylqz2cs8haxr2pb3a";
    meta.description = "Extra components that are not as closely vetted or as stable as Core";
  };

  core_kernel = janePackage {
    pname = "core_kernel";
    version = "0.14.1";
    buildInputs = [ jst-config ];

    propagatedBuildInputs = [
      base_bigstring
      sexplib
    ];

    doCheck = false; # we don't have quickcheck_deprecated
    hash = "0pikg4ln6177gbs0jfix7xj50zlcm7058h64lxnd7wspnj7mq8sd";
    meta.description = "System-independent part of Core";
  };

  core_unix = janePackage {
    pname = "core_unix";
    propagatedBuildInputs = [ core ];
    hash = "0irfmpx6iksxk2r8mdizjn75h71qh4p2f1s9x2ggckzqj9y904ck";
    meta.description = "Unix-specific portions of Core";
  };

  csvfields = janePackage {
    pname = "csvfields";

    propagatedBuildInputs = [
      core
      num
    ];

    hash = "09jmz6y6nwd96dcx6g8ydicxssi72v1ks276phbc9n19wwg9hkaz";
    meta.description = "Runtime support for ppx_xml_conv and ppx_csv_conv";
  };

  delimited_parsing = janePackage {
    pname = "delimited_parsing";

    propagatedBuildInputs = [
      async
      core_extended
    ];

    hash = "1dnr5wqacryx1kj38i9iifc3457pchr887xphzz2nhlbizq3d7qa";
    meta.description = "Parsing of character (e.g., comma) separated and fixed-width values";
  };

  ecaml = janePackage {
    pname = "ecaml";

    propagatedBuildInputs = [
      async
      expect_test_helpers_core
    ];

    hash = "052qglpwzrx3c4gy3zr6dmsmfbi5gj4fs2jhx9yrsqb9hj8g36mj";
    meta.description = "Library for writing Emacs plugin in OCaml";
  };

  email_message = janePackage {
    pname = "email_message";

    propagatedBuildInputs = [
      angstrom
      async
      base64
      cryptokit
      magic-mime
      re2
    ];

    hash = "0k8hjkq91ikl7wjxs04k523jbkhl6q4abj6v0lzlbjiybmrpp69n";
    meta.description = "E-mail message parser";
  };

  expect_test_helpers_async = janePackage {
    pname = "expect_test_helpers_async";

    propagatedBuildInputs = [
      async
      expect_test_helpers_core
    ];

    hash = "175sjkx3b10d8vacp369rv53nxbiaxw1xhwy832g7ffk1by8l2m1";
    meta.description = "Async helpers for writing expectation tests";
  };

  expect_test_helpers_core = janePackage {
    pname = "expect_test_helpers_core";

    propagatedBuildInputs = [
      core_kernel
      sexp_pretty
    ];

    hash = "1drl15akp4jz4wf26dr2y2nblvnhz14xsnb3ai8dg45y711svs2i";
    meta.description = "Helpers for writing expectation tests";
  };

  fieldslib = janePackage {
    pname = "fieldslib";
    propagatedBuildInputs = [ base ];
    hash = "0nxx35lrb4f6zfs5l80a7cg7azf19c6g31vn9qjjpaxf6lgkck2n";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Syntax extension to define first class values representing record fields, to get and set record fields, iterate and fold over all fields of a record and create new record values";
  };

  higher_kinded = janePackage {
    pname = "higher_kinded";
    version = "0.14.1";

    propagatedBuildInputs = [
      base
      ppx_jane
    ];

    hash = "05jvxgqsx3j2v8rqpd91ah76dgc1q2dz38kjklmx0vms4r4gvlsx";
    minimalOCamlVersion = "4.09";
    meta.description = "Library with an encoding of higher kinded types in OCaml";
  };

  incr_dom = janePackage {
    pname = "incr_dom";
    patches = [ ./incr_dom_jsoo_4_0.patch ];
    buildInputs = [ js_of_ocaml-ppx ];

    propagatedBuildInputs = [
      async_js
      incr_map
      incr_select
      virtual_dom
    ];

    hash = "0mi98cwi4npdh5vvcz0pb4sbb9j9dydl52s51rswwc3kn8mipxfx";
    meta.description = "Library for building dynamic webapps, using Js_of_ocaml";
  };

  incr_map = janePackage {
    pname = "incr_map";
    buildInputs = [ ppx_pattern_bind ];
    propagatedBuildInputs = [ incremental ];
    hash = "0s0s7qfydvvvnqby4v5by5jdnd5kxqsdr65mhm11w4fn125skryz";
    meta.description = "Helpers for incremental operations on map like data structures";
  };

  incr_select = janePackage {
    pname = "incr_select";
    propagatedBuildInputs = [ incremental ];
    hash = "18ril6z57mw89gzc9zhz6p1phwm1xr6phppicvqpqmi0skvvnrg6";
    meta.description = "Handling of large set of incremental outputs from a single input";
  };

  incremental = janePackage {
    pname = "incremental";
    propagatedBuildInputs = [ core_kernel ];
    hash = "0nyaiy7r2spvn2ij9z5rghd5gbjk1y3ai4jn0i8q81arp7cf6zc7";
    meta.description = "Library for incremental computations";
  };

  jane-street-headers = janePackage {
    pname = "jane-street-headers";
    hash = "12n40mlgjnc09fxc0hp0npsxdlxja2w828683zpb32nrzqkg6z4c";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Jane Street C header files";
  };

  jst-config = janePackage {
    pname = "jst-config";

    buildInputs = [
      dune-configurator
      ppx_assert
      stdio
    ];

    hash = "0hzw0crgj0kjxsvr10wng7gqy948v98hnijh30lgq3v62jdsjra8";
    meta.description = "Compile-time configuration for Jane Street libraries";
  };

  ocaml-compiler-libs = janePackage {
    pname = "ocaml-compiler-libs";
    version = "0.12.4";
    hash = "sha256-W+KUguz55yYAriHRMcQy8gRPzh2TZSJnexG1JI8TLgI=";
    minimalOCamlVersion = "4.04.1";
    meta.description = "OCaml compiler libraries repackaged";
  };

  parsexp = janePackage {
    pname = "parsexp";
    version = "0.14.1";

    propagatedBuildInputs = [
      base
      sexplib0
    ];

    hash = "1nr0ncb8l2mkk8pqzknr7fsqw5kpz8y102kyv5bc0x7c36v0d4zy";
    minimalOCamlVersion = "4.04.2";
    meta.description = "S-expression parsing library";
  };

  patience_diff = janePackage {
    pname = "patience_diff";
    propagatedBuildInputs = [ core_kernel ];
    hash = "1np88s226ndhbwynpdqygrycahp8m1mx28f1xk54kvds8znnq2i0";
    meta.description = "Diff library using Bram Cohen's patience diff algorithm";
  };

  posixat = janePackage {
    pname = "posixat";

    propagatedBuildInputs = [
      ppx_optcomp
      ppx_sexp_conv
    ];

    hash = "0aana1lzq4514kna7hr301b5iv6gcg6zhgrx8s8vaad1q38yfp6c";
    minimalOCamlVersion = "4.07";
    meta.description = "Binding to the posix *at functions";
  };

  ppx_accessor = janePackage {
    pname = "ppx_accessor";
    version = "0.14.3";
    propagatedBuildInputs = [ accessor ];
    hash = "sha256:1c8blzh2f34vbm1z3mnvh670c6vda70chw805n2hmkd9j46l0cll";
    minimalOCamlVersion = "4.09";
    meta.description = "[@@deriving] plugin to generate accessors for use with the Accessor libraries";
  };

  ppx_assert = janePackage {
    pname = "ppx_assert";

    propagatedBuildInputs = [
      ppx_cold
      ppx_compare
      ppx_here
      ppx_sexp_conv
    ];

    hash = "03mzgm4smrczp5dg3mpr6zc2v6a54n0r01k4ww820yrr25hcf8ip";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Assert-like extension nodes that raise useful errors on failure";
  };

  ppx_base = janePackage {
    pname = "ppx_base";

    propagatedBuildInputs = [
      ppx_cold
      ppx_enumerate
      ppx_hash
      ppx_js_style
    ];

    hash = "1wv3q0qyghm0c5izq03y97lv3czqk116059mg62wx6valn22a000";
    minimalOCamlVersion = "4.04.2";

    meta = {
      description = "Base set of ppx rewriters";
      mainProgram = "ppx-base";
    };
  };

  ppx_bench = janePackage {
    pname = "ppx_bench";
    version = "0.14.1";
    propagatedBuildInputs = [ ppx_inline_test ];
    hash = "12r7jgqgpb4i4cry3rgyl2nmxcscs5w7mmk06diz7i49r27p96im";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Syntax extension for writing in-line benchmarks in ocaml code";
  };

  ppx_bin_prot = janePackage {
    pname = "ppx_bin_prot";

    propagatedBuildInputs = [
      bin_prot
      ppx_here
    ];

    doCheck = false; # circular dependency with ppx_jane
    hash = "1qryjxhyz3kn5jz5wm62j59lhjhd1mp7nbsj0np9qnbpapnnr1zg";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Generation of bin_prot readers and writers from types";
  };

  ppx_cold = janePackage {
    pname = "ppx_cold";
    propagatedBuildInputs = [ ppxlib ];
    hash = "0ciqs6f9ab73gq4krj14xzzba4ydcxph214m87i1s0xp25hwxr8v";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Expands [@cold] into [@inline never][@specialise never][@local never]";
  };

  ppx_compare = janePackage {
    pname = "ppx_compare";

    propagatedBuildInputs = [
      ppxlib
      base
    ];

    doCheck = false; # test build rule broken
    hash = "11pj76dimx2f7l8m85myzp6yzx9xcg0bqi97s7ayssvkckm57390";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Generation of comparison functions from types";
  };

  ppx_custom_printf = janePackage {
    pname = "ppx_custom_printf";
    version = "0.14.1";
    propagatedBuildInputs = [ ppx_sexp_conv ];
    hash = "0c1m65kn27zvwmfwy7kk46ga76yw2a3ik9jygpy1b6nn6pi026w9";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Printf-style format-strings for user-defined string conversion";
  };

  ppx_enumerate = janePackage {
    pname = "ppx_enumerate";
    propagatedBuildInputs = [ ppxlib ];
    hash = "1sriid4vh10p80wwvn46v1g16m646qw5r5xzwlymyz5gbvq2zf40";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Generate a list containing all values of a finite type";
  };

  ppx_expect = janePackage {
    pname = "ppx_expect";
    version = "0.14.1";

    propagatedBuildInputs = [
      ppx_here
      ppx_inline_test
      re
    ];

    doCheck = false; # circular dependency with ppx_jane
    hash = "0vbbnjrzpyk5p0js21lafr6fcp2wqka89p1876rdf472cmg0l7fv";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Cram like framework for OCaml";
  };

  ppx_fields_conv = janePackage {
    pname = "ppx_fields_conv";
    version = "0.14.2";

    propagatedBuildInputs = [
      fieldslib
      ppxlib
    ];

    hash = "1zwirwqry24b48bg7d4yc845hvcirxyymzbw95aaxdcck84d30n8";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Generation of accessor and iteration functions for ocaml records";
  };

  ppx_fixed_literal = janePackage {
    pname = "ppx_fixed_literal";
    propagatedBuildInputs = [ ppxlib ];
    hash = "0s7rb4dhz4ibhh42a9sfxjj3zbwfyfmaihr92hpdv5j9xqn3n8mi";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Simpler notation for fixed point literals";
  };

  ppx_hash = janePackage {
    pname = "ppx_hash";

    propagatedBuildInputs = [
      ppx_compare
      ppx_sexp_conv
    ];

    hash = "1zf03xdrg4jig7pdcrdpbabyjkdpifb31z2z1bf9wfdawybdhwkq";
    minimalOCamlVersion = "4.04.2";
    meta.description = "PPX rewriter that generates hash functions from type expressions and definitions";
  };

  ppx_here = janePackage {
    pname = "ppx_here";
    propagatedBuildInputs = [ ppxlib ];
    doCheck = false; # test build rules broken
    hash = "09zcyigaalqccs9s0h7n0535clgfmqb9s4p1jbgcqji9zj8w426s";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Expands [%here] into its location";
  };

  ppx_inline_test = janePackage {
    pname = "ppx_inline_test";
    version = "0.14.1";

    propagatedBuildInputs = [
      ppxlib
      time_now
    ];

    doCheck = false; # test build rules broken
    hash = "1ajdna1m9l1l3nfigyy33zkfa3yarfr6s086jdw2pcfwlq1fhhl4";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Syntax extension for writing in-line tests in ocaml code";
  };

  ppx_jane = janePackage {
    pname = "ppx_jane";

    propagatedBuildInputs = [
      base_quickcheck
      ppx_bin_prot
      ppx_expect
      ppx_fixed_literal
      ppx_module_timer
      ppx_optcomp
      ppx_optional
      ppx_pipebang
      ppx_stable
      ppx_string
      ppx_typerep_conv
      ppx_variants_conv
    ];

    hash = "1kk238fvrcylymwm7xwc7llbyspmx1y662ypq00vy70g112rir7j";
    minimalOCamlVersion = "4.04.2";

    meta = {
      description = "Standard Jane Street ppx rewriters";
      mainProgram = "ppx-jane";
    };
  };

  ppx_js_style = janePackage {
    pname = "ppx_js_style";
    version = "0.14.1";

    propagatedBuildInputs = [
      octavius
      ppxlib
    ];

    hash = "16ax6ww9h36xyn9acbm8zxv0ajs344sm37lgj2zd2bvgsqv24kxj";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Code style checker for Jane Street Packages";
  };

  ppx_let = janePackage {
    pname = "ppx_let";
    propagatedBuildInputs = [ ppxlib ];
    hash = "1jq3g88xv9g6y9im67hiig3cfn5anwwnq09mp7yn7a86ha5r9w3i";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Monadic let-bindings";
  };

  ppx_log = janePackage {
    pname = "ppx_log";

    propagatedBuildInputs = [
      async_unix
      ppx_jane
      sexplib
    ];

    hash = "10hnr5lpww3fw0bnidzngalbgy0j1wvz1g5ki9c9h558pnpvsazr";
    minimalOCamlVersion = "4.08.0";
    meta.description = "Ppx_sexp_message-like extension nodes for lazily rendering log messages";
  };

  ppx_module_timer = janePackage {
    pname = "ppx_module_timer";
    propagatedBuildInputs = [ time_now ];
    hash = "163q1rpblwv82fxwyf0p4j9zpsj0jzvkfmzb03r0l49gqhn89mp6";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Ppx rewriter that records top-level module startup times";
  };

  ppx_optcomp = janePackage {
    pname = "ppx_optcomp";
    version = "0.14.3";
    propagatedBuildInputs = [ ppxlib ];
    hash = "1iflgfzs23asw3k6098v84al5zqx59rx2qjw0mhvk56avlx71pkw";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Optional compilation for OCaml";
  };

  ppx_optional = janePackage {
    pname = "ppx_optional";
    propagatedBuildInputs = [ ppxlib ];
    hash = "1d7rsdqiccxp2w4ykb9klarddm2qrrym3brbnhzx2hm78iyj3hzv";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Pattern matching on flat options";
  };

  ppx_pattern_bind = janePackage {
    pname = "ppx_pattern_bind";
    propagatedBuildInputs = [ ppx_let ];
    hash = "0yxkwnn30nxgrspi191zma95bgrh134aqh2bnpj3wg0245ki55zv";
    minimalOCamlVersion = "4.07";
    meta.description = "PPX for writing fast incremental bind nodes in a pattern match";
  };

  ppx_pipebang = janePackage {
    pname = "ppx_pipebang";
    propagatedBuildInputs = [ ppxlib ];
    hash = "0450b3p2rpnnn5yyvbkcd3c33jr2z0dp8blwxddaj2lv7nzl5dzf";
    minimalOCamlVersion = "4.04.2";
    meta.description = "PPX rewriter that inlines reverse application operators `|>` and `|!`";
  };

  ppx_python = janePackage {
    pname = "ppx_python";

    # Compatibility with ppxlib 0.23
    patches = fetchpatch {
      sha256 = "sha256:1mrdwp0zw3dqavzx3ffrmzq5cdlninyf67ksavfzxb8gb16w6zpz";
      url = "https://github.com/janestreet/ppx_python/commit/b2fe0040cc39fa6164de868f8a20edb38d81170e.patch";
    };

    propagatedBuildInputs = [
      ppx_base
      ppxlib
      pyml
    ];

    hash = "0gk4nqz4i9v3hwjg5mvgpgwj0dfcgpyc7ikba93cafyhn6fy83zk";
    meta.description = "[@@deriving] plugin to generate Python conversion functions";
  };

  ppx_sexp_conv = janePackage {
    pname = "ppx_sexp_conv";
    version = "0.14.3";

    propagatedBuildInputs = [
      (ppxlib.override { version = "0.24.0"; })
      sexplib0
      base
    ];

    hash = "0dbri9d00ydi0dw1cavswnqdmhjaaz80vap29ns2lr6mhhlvyjmj";
    minimalOCamlVersion = "4.04.2";
    meta.description = "[@@deriving] plugin to generate S-expression conversion functions";
  };

  ppx_sexp_message = janePackage {
    pname = "ppx_sexp_message";
    version = "0.14.1";

    propagatedBuildInputs = [
      ppx_here
      ppx_sexp_conv
    ];

    hash = "1lvsr0d68kakih1ll33hy6dxbjkly6lmky4q6z0h0hrcbd6z48k4";
    minimalOCamlVersion = "4.04.2";
    meta.description = "PPX rewriter for easy construction of s-expressions";
  };

  ppx_sexp_value = janePackage {
    pname = "ppx_sexp_value";

    propagatedBuildInputs = [
      ppx_here
      ppx_sexp_conv
    ];

    hash = "1d1c92pyypqkd9473d59j0sfppxvcxggbc62w8bkqnbxrdmvirn9";
    minimalOCamlVersion = "4.04.2";
    meta.description = "PPX rewriter that simplifies building s-expressions from ocaml values";
  };

  ppx_stable = janePackage {
    pname = "ppx_stable";
    version = "0.14.1";
    propagatedBuildInputs = [ ppxlib ];
    hash = "1sp1kn23qr0pfypa4ilvhqq5y11y13xpfygfl582ra9kik5xqfa1";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Stable types conversions generator";
  };

  ppx_string = janePackage {
    pname = "ppx_string";
    version = "0.14.1";

    propagatedBuildInputs = [
      ppx_base
      ppxlib
      stdio
    ];

    hash = "0a8khmg0y32kyn3q6idwgh0d6d1s6ms1w75gj3dzng0v7y4h6jx4";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Ppx extension for string interpolation";
  };

  ppx_typerep_conv = janePackage {
    pname = "ppx_typerep_conv";
    version = "0.14.2";

    propagatedBuildInputs = [
      ppxlib
      typerep
    ];

    hash = "0yk9vkpnwr8labgfncqdi4rfkj88d8mb3cr8m4gdqpi3f2r27hf0";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Generation of runtime types from type declarations";
  };

  ppx_variants_conv = janePackage {
    pname = "ppx_variants_conv";
    version = "0.14.2";

    propagatedBuildInputs = [
      variantslib
      ppxlib
    ];

    hash = "1p11fiz4m160hs0xzg4g9rxchp053sz3s3d1lyciqixad1xi47a4";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Generation of accessor and iteration functions for ocaml variant types";
  };

  protocol_version_header = janePackage {
    pname = "protocol_version_header";
    propagatedBuildInputs = [ core_kernel ];
    hash = "0lfblv2yqw01bl074ga6vxii0p9mqwlqw1g9b9z7pfdva9wqilrd";
    meta.description = "Protocol versioning";
  };

  pythonlib = janePackage {
    pname = "pythonlib";

    propagatedBuildInputs = [
      ppx_expect
      ppx_let
      ppx_python
      stdio
      typerep
    ];

    hash = "0qr0mh9jiv1ham5zlz9i4im23a1vh6x1yp6dp2db2s4icmfph639";
    meta.broken = lib.versionAtLeast ocaml.version "4.13";
    meta.description = "Library to help writing wrappers around ocaml code for python";
  };

  re2 = janePackage {
    pname = "re2";
    propagatedBuildInputs = [ core_kernel ];
    hash = "1j7dizls6lkz3i9dgf8nq2fm382mfbrmz72ci066zl3hkgdq8xwc";

    prePatch = ''
      substituteInPlace src/re2_c/dune --replace 'CXX=g++' 'CXX=c++'
      substituteInPlace src/dune --replace '(cxx_flags (:standard \ -pedantic) (-I re2_c/libre2))' '(cxx_flags (:standard \ -pedantic) (-I re2_c/libre2) (-x c++))'
    '';

    meta.description = "OCaml bindings for RE2, Google's regular expression library";
  };

  re2_stable = janePackage {
    pname = "re2_stable";

    propagatedBuildInputs = [
      core
      re2
    ];

    hash = "0kjc0ff6b3509s3b9n4q8ilb06d5fngdh3z58cm95vg7zkcas9w3";
    meta.description = "Re2_stable adds an incomplete but stable serialization of Re2";
  };

  resource_cache = janePackage {
    pname = "resource_cache";
    propagatedBuildInputs = [ async_rpc_kernel ];
    hash = "197z9s535q74h00365ydhggg7hyzpyqvislgwwyi69sl1vy6dr0j";
    meta.description = "General resource cache";
  };

  sexp = janePackage {
    pname = "sexp";
    patches = ./sexp.patch;

    propagatedBuildInputs = [
      async
      core
      csvfields
      re2
      sexp_diff_kernel
      sexp_macro
      sexp_pretty
      sexp_select
    ];

    hash = "1x08pyrkd78233kgj70wxlc79w6jjhfrjdamm2xr7jzdc8ycfigf";
    meta.broken = true; # Does not build with GCC 14
    meta.description = "S-expression swiss knife";
  };

  sexp_diff_kernel = janePackage {
    pname = "sexp_diff_kernel";
    propagatedBuildInputs = [ core_kernel ];
    hash = "1pljcs019hs2ffhhb7rjh3xz7cbrk8vsv967jzmip3rv9w21c9kh";
    meta.description = "Code for computing the diff of two sexps";
  };

  sexp_macro = janePackage {
    pname = "sexp_macro";

    propagatedBuildInputs = [
      async
      sexplib
    ];

    hash = "1ih1g7vpb1j8vhzm9a5mjrrzgqrhjqdhf6vjrg8kxfqg5i5b8nyx";
    meta.description = "Sexp macros";
  };

  sexp_pretty = janePackage {
    pname = "sexp_pretty";

    propagatedBuildInputs = [
      ppx_base
      re
      sexplib
    ];

    hash = "0dax0wm511zgvr7p6kcd5gygi58118by7hsv7hymy8ldfcky5cwd";
    minimalOCamlVersion = "4.07";
    meta.description = "S-expression pretty-printer";
  };

  sexp_select = janePackage {
    pname = "sexp_select";

    propagatedBuildInputs = [
      base
      ppx_jane
    ];

    hash = "1lchhfqw4afw38fnarwylqc2qp7k6xwx3j7m9gy8ygjgd0vgd729";
    minimalOCamlVersion = "4.07";
    meta.description = "Library to use CSS-style selectors to traverse sexp trees";
  };

  sexplib = janePackage {
    pname = "sexplib";

    propagatedBuildInputs = [
      num
      parsexp
    ];

    hash = "03c3j1ihx4pjbb0x3arrcif3wvp3iva2ivnywhiak4mbbslgsnzr";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Library for serializing OCaml values to and from S-expressions";
  };

  sexplib0 = janePackage {
    pname = "sexplib0";
    hash = "06sb3zqhb3dwqsmn15d769hfgqwqhxnm52iqim9l767gvlwpmibb";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Library containing the definition of S-expressions and some base converters";
  };

  shell = janePackage {
    pname = "shell";
    buildInputs = [ jst-config ];
    propagatedBuildInputs = [ textutils ];
    doCheck = false; # Does not build with GCC 14
    checkInputs = [ ounit ];
    hash = "1c4zmpf6s1lk7nficip32c324if6zhm62h9h03d84zgvhvymi0r1";
    meta.description = "Yet another implementation of fork&exec and related functionality";
  };

  shexp = janePackage {
    pname = "shexp";

    propagatedBuildInputs = [
      posixat
      spawn
    ];

    hash = "1h6hsnbg6bk32f8iv6kd6im4mv2pjsjpd1mjsfx80p1n9273xack";
    minimalOCamlVersion = "4.07";
    meta.description = "Process library and s-expression based shell";
  };

  spawn = janePackage {
    pname = "spawn";
    version = "0.13.0";
    buildInputs = [ ppx_expect ];
    doCheck = false; # tests are broken on NixOS (absolute paths)
    hash = "1w003k1kw1lmyiqlk58gkxx8rac7dchiqlz6ah7aj7bh49b36ppf";
    minimalOCamlVersion = "4.02.3";
    meta.description = "Spawning sub-processes";
  };

  splay_tree = janePackage {
    pname = "splay_tree";
    propagatedBuildInputs = [ core_kernel ];
    hash = "1xbzzbqb054hl1v1zcgfwdgzqihni3a0dmvrric9xggmgn4ycmqq";
    meta.description = "Splay tree implementation";
  };

  splittable_random = janePackage {
    pname = "splittable_random";

    propagatedBuildInputs = [
      base
      ppx_assert
      ppx_bench
      ppx_sexp_message
    ];

    hash = "0ax988b1wc7km8khg4s6iphbz16y1rssh7baigxfyw3ldp0agk14";
    meta.description = "PRNG that can be split into independent streams";
  };

  stdio = janePackage {
    pname = "stdio";
    propagatedBuildInputs = [ base ];
    hash = "0vv6d8absy4hvjd1babv7avpsdlvjpnd5hq691h39d0h3pvs6l98";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Standard IO library for OCaml";
  };

  textutils = janePackage {
    pname = "textutils";
    propagatedBuildInputs = [ core ];
    hash = "1ggd0530lc5dkc419y3xw1wb52b4b5j3z78991gn5yxf2s50a8d4";
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

    hash = "1lyq8zdz93hvpi4hpxh88kds30k5ljil8js9clcqyxrldp5n9mw0";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Reports the current time";
  };

  timezone = janePackage {
    pname = "timezone";
    propagatedBuildInputs = [ core_kernel ];
    hash = "0zf075k94nk2wxnzpxia7pnm655damwp1b58xf2s9disia1ydxg7";
    meta.description = "Time-zone handling";
  };

  topological_sort = janePackage {
    pname = "topological_sort";

    propagatedBuildInputs = [
      ppx_jane
      stdio
    ];

    hash = "17iz7956zln31p0xnm3jlhj863zi84bcx41jylzf7gk23qsm95m8";
    meta.description = "Topological sort algorithm";
  };

  typerep = janePackage {
    pname = "typerep";
    propagatedBuildInputs = [ base ];
    hash = "0wc7h853ka3s3lxxgm61ypidl0lzgc9abdkil6f72anl0c417y90";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Typerep is a library for runtime types";
  };

  variantslib = janePackage {
    pname = "variantslib";
    propagatedBuildInputs = [ base ];
    hash = "0vy0hpiaawmydh08nqlwjx52pasp74383yi0pshwbdxin99n9mxd";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Part of Jane Street's Core library";
  };

  vcaml = janePackage {
    pname = "vcaml";

    propagatedBuildInputs = [
      angstrom-async
      async_extra
      faraday
    ];

    hash = "0ykwrn8bvwx26ad4wb36jw9xnlwsdpnnx88396laxvcfimrp13qs";
    meta.description = "OCaml bindings for the Neovim API";
  };

  virtual_dom = janePackage {
    pname = "virtual_dom";
    buildInputs = [ js_of_ocaml-ppx ];

    propagatedBuildInputs = [
      core_kernel
      js_of_ocaml
      lambdasoup
      tyxml
    ];

    hash = "0vcydxx0jhbd5hbriahgp947mc7n3xymyrsfny1c4adk6aaq3c5w";
    meta.description = "OCaml bindings for the virtual-dom library";
  };

  zarith_stubs_js = janePackage {
    pname = "zarith_stubs_js";
    doCheck = false; # requires workspace with zarith
    hash = "16p4bn5spkrx31fr4np945v9mwdq55706v3wl19s5fy6x83gvb86";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Javascripts stubs for the Zarith library";
  };

  zstandard = janePackage {
    pname = "zstandard";
    buildInputs = [ ppx_jane ];

    propagatedBuildInputs = [
      core
      ctypes
      zstd
    ];

    hash = "1vf76v5m9wsh5f77w9z4i8sxm05wr5digyi95x4wvzdi7q3qg6m8";
    meta.description = "OCaml bindings to Zstandard";
  };

}
