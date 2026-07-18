{
  lib,
  bash,
  fetchpatch,
  fzf,
  ocaml,
  openssl,
  self,
  zstd,
}:

let
  js_of_ocaml-compiler = self.js_of_ocaml-compiler.override { version = "5.9.1"; };
  js_of_ocaml = self.js_of_ocaml.override { inherit js_of_ocaml-compiler; };
  gen_js_api = self.gen_js_api.override {
    inherit js_of_ocaml-compiler;
    ojs = self.ojs.override { inherit js_of_ocaml-compiler; };
  };
  js_of_ocaml-ppx = self.js_of_ocaml-ppx.override { inherit js_of_ocaml; };
in

with self;

{

  abstract_algebra = janePackage {
    pname = "abstract_algebra";

    propagatedBuildInputs = [
      base
      ppx_jane
    ];

    hash = "12imf6ibm7qb8r1fpqnrl20x2z14zl3ri1vzg0z8qby9l8bv2fbd";
    minimalOCamlVersion = "4.08";
    meta.description = "Small library describing abstract algebra concepts";
  };

  accessor = janePackage {
    pname = "accessor";
    propagatedBuildInputs = [ higher_kinded ];
    hash = "17rzf0jpc9s3yrxcnn630jhgsw5mrnrhwbfh62hqxqanascc5rxh";
    minimalOCamlVersion = "4.09";
    meta.description = "Library that makes it nicer to work with nested functional data structures";
  };

  accessor_async = janePackage {
    pname = "accessor_async";

    propagatedBuildInputs = [
      accessor_core
      async_kernel
    ];

    hash = "17r6af55ms0i496jsfx0xpdm336c2vhyf49b3s8s1gpz521wrgmc";
    minimalOCamlVersion = "4.09";
    meta.description = "Accessors for Async types, for use with the Accessor library";
  };

  accessor_base = janePackage {
    pname = "accessor_base";
    propagatedBuildInputs = [ ppx_accessor ];
    hash = "1qvq005vxf6n1c7swzb4bzcqdh471bfb9gcmdj4m57xg85xznc1n";
    minimalOCamlVersion = "4.09";
    meta.description = "Accessors for Base types, for use with the Accessor library";
  };

  accessor_core = janePackage {
    pname = "accessor_core";

    propagatedBuildInputs = [
      accessor_base
      core_kernel
    ];

    hash = "0zrs5zbyrhfbah73g22l19bw1mmljhyb3l2mrwcxgbjq9pqp0k9v";
    minimalOCamlVersion = "4.09";
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
    hash = "0pykmnsil754jsnr8gss91ykyjvivngx4ii0ih3nsg1x2jl9xmy2";
    meta.description = "Monadic concurrency library";
  };

  async_extra = janePackage {
    pname = "async_extra";
    propagatedBuildInputs = [ async_kernel ];
    hash = "0pxp0b4shz9krsj8xfzajv8a1mijgf0xdgxrn2abdqrz3rvj6pig";
    meta.description = "Monadic concurrency library";
  };

  async_find = janePackage {
    pname = "async_find";
    propagatedBuildInputs = [ async ];
    hash = "119988nkcnw6l6wch4llqkvsrawv2gkbn5q4hngpdwvnw0g0aapv";
    meta.description = "Directory traversal with Async";
  };

  async_inotify = janePackage {
    pname = "async_inotify";

    propagatedBuildInputs = [
      async_find
      inotify
    ];

    hash = "1nxz6bijp7liy18ljrxg92v2m8v8fqcs1pmzg9kbcf0d4vij8j2p";
    meta.description = "Async wrapper for inotify";
  };

  async_interactive = janePackage {
    pname = "async_interactive";
    propagatedBuildInputs = [ async ];
    hash = "00hr2lhs8p3hwnyllmns59rwlpimc5b7r6v4zn6cmpb1riblaxqp";
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

    hash = "184j077bz686k5lrqswircnrdqldb316ngpzq7xri1pcsl39sy3q";
    meta.description = "Small library that provide Async support for JavaScript platforms";
  };

  async_kernel = janePackage {
    pname = "async_kernel";
    propagatedBuildInputs = [ core_kernel ];
    hash = "01if6c8l2h64v7sk56xr8acnmj6g9whxcjrzzzvczspq88hq2bfh";
    meta.description = "Monadic concurrency library";
  };

  async_rpc_kernel = janePackage {
    pname = "async_rpc_kernel";

    propagatedBuildInputs = [
      async_kernel
      protocol_version_header
    ];

    hash = "1b5rp5yam03ir4f1sixpzjg1zdqmkb7lvnaa82kac4fzk80gfrfr";
    meta.description = "Platform-independent core of Async RPC library";
  };

  async_rpc_websocket = janePackage {
    pname = "async_rpc_websocket";

    propagatedBuildInputs = [
      async_rpc_kernel
      async_websocket
      cohttp_async_websocket
    ];

    hash = "1n93jhkz5r76xcc40c4i4sxcyfz1dbppz8sjfxpwcwjyi6lyhp1p";
    meta.description = "Library to serve and dispatch Async RPCs over websockets";
  };

  async_sendfile = janePackage {
    pname = "async_sendfile";
    propagatedBuildInputs = [ async_unix ];
    hash = "0lnagdxfnac4z29narphf2ab5a23ys883zmc45r96rssfx82i3fs";
    meta.description = "Thin wrapper around [Linux_ext.sendfile] to send full files";
  };

  async_shell = janePackage {
    pname = "async_shell";

    propagatedBuildInputs = [
      async
      shell
    ];

    hash = "07iwlyrc4smk6hsnz89cz2ihp670mllq0y9wbdafvagm1y1p62vx";
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

    hash = "1m00j7wcb0blipnc1m6by70gd96a1k621b4dgvgffp8as04a461r";
    minimalOCamlVersion = "4.12";
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

    hash = "1b7f7p3xj4jr2n2dxy2lp7a9k7944w6x2nrg6524clvcsd1ax4hn";
    meta.description = "Async wrappers for SSL";
  };

  async_unix = janePackage {
    pname = "async_unix";

    propagatedBuildInputs = [
      async_kernel
      core_unix
    ];

    hash = "0z4fgpn93iw0abd7l9kac28qgzgc5qr2x0s1n2zh49lsdn02n6ys";
    meta.description = "Monadic concurrency library";
  };

  async_websocket = janePackage {
    pname = "async_websocket";

    propagatedBuildInputs = [
      async
      cryptokit
    ];

    hash = "16ixqfnx9jp77bvx11dlzsq0pzfpyiif60hl2q06zncyswky9xgb";
    meta.description = "Library that implements the websocket protocol on top of Async";
  };

  base = janePackage {
    pname = "base";
    version = "0.15.1";
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ sexplib0 ];
    checkInputs = [ alcotest ];
    hash = "sha256-CDKQVF+hAvJTo5QmRvyOfQNrdRgz6m+64q9UzNHlJEA=";
    minimalOCamlVersion = "4.10";
    meta.description = "Full standard library replacement for OCaml";
  };

  base_bigstring = janePackage {
    pname = "base_bigstring";

    propagatedBuildInputs = [
      int_repr
      ppx_jane
    ];

    hash = "1hv3hw2fwqmkrxms1g6rw3c18mmla1z5bva3anx45mnff903iv4q";
    minimalOCamlVersion = "4.08";
    meta.description = "String type based on [Bigarray], for use in I/O and C-bindings";
  };

  base_quickcheck = janePackage {
    pname = "base_quickcheck";

    propagatedBuildInputs = [
      ppx_base
      ppx_fields_conv
      ppx_let
      ppx_sexp_value
      splittable_random
    ];

    hash = "0q73kfr67cz5wp4qn4rq3lpa922hqmvwdiinnans0js65fvlgqsi";
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

    hash = "12q3xcv78b4s9srnc17jbyn53d5drmwmyvgp62p7nk3fs4f7cr4f";
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

    hash = "1qfqglscc25wwnjx7byqmjcnjww1msnr8940gyg8h93wdq43fjnh";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Binary protocol generator";
  };

  bonsai = janePackage {
    pname = "bonsai";
    patches = [ ./bonsai_jsoo_4_0.patch ];

    nativeBuildInputs = [
      js_of_ocaml-compiler
      ocaml-embed-file
    ];

    buildInputs = [ ppx_pattern_bind ];

    propagatedBuildInputs = [
      async
      async_extra
      async_rpc_websocket
      cohttp-async
      core_bench
      fuzzy_match
      incr_dom
      js_of_ocaml-ppx
      patdiff
      ppx_css
      ppx_typed_fields
      profunctor
      textutils
    ];

    hash = "150zx2g1dmhyrxwqq8j7f2m3hjpmk5bk182ihx2gdbarhw1ainpm";
    meta.description = "Library for building dynamic webapps, using Js_of_ocaml";
  };

  cinaps = janePackage {
    pname = "cinaps";
    version = "0.15.1";
    propagatedBuildInputs = [ re ];
    doCheck = false; # fails because ppx_base doesn't include ppx_js_style
    hash = "0g856cxmxg4vicwslhqldplkpwi158s2d62vwzv26xg5m6wjn9rg";
    minimalOCamlVersion = "4.04";
    meta.description = "Trivial metaprogramming tool";
  };

  cohttp_async_websocket = janePackage {
    pname = "cohttp_async_websocket";

    propagatedBuildInputs = [
      async_ssl
      async_websocket
      cohttp-async_5_3
      ppx_jane
      uri-sexp
    ];

    hash = "0d0smavnxpnwrmhlcf3b5a3cm3n9kz1y8fh6l28xv6zrn4sc7ik8";
    meta.description = "Websocket library for use with cohttp and async";
  };

  cohttp_static_handler = janePackage {
    pname = "cohttp_static_handler";
    version = "0.15.0";
    propagatedBuildInputs = [ cohttp-async_5_3 ];
    hash = "sha256-ENaH8ChvjeMc9WeNIhkeNBB7YK9vB4lw95o6FFZI1ys=";
    meta.description = "Library for easily creating a cohttp handler for static files";
  };

  core = janePackage {
    pname = "core";
    version = "0.15.1";
    buildInputs = [ jst-config ];

    propagatedBuildInputs = [
      base
      base_bigstring
      base_quickcheck
      ppx_jane
      time_now
    ];

    doCheck = false; # circular dependency with core_kernel
    hash = "sha256-SHjnNFl+JAjdgVoRgmnz0wqrrc3zoh0ZyG2UhUsUbJ8=";
    meta.broken = lib.versionAtLeast ocaml.version "5.1";
    meta.description = "Industrial strength alternative to OCaml's standard library";
  };

  core_bench = janePackage {
    pname = "core_bench";
    propagatedBuildInputs = [ textutils ];
    hash = "0v6lm9vz6y1qd7h8pg9l5jsy8qr74vlk1nd4qzchld4jhwq7mbdi";
    meta.description = "Benchmarking library";
  };

  core_extended = janePackage {
    pname = "core_extended";

    propagatedBuildInputs = [
      core_unix
      record_builder
    ];

    hash = "0sx79hc1y1daczib2p4nbyw4aqnznmdd83knrhs5q153j7lnlalx";
    meta.description = "Extra components that are not as closely vetted or as stable as Core";
  };

  core_kernel = janePackage {
    pname = "core_kernel";
    buildInputs = [ jst-config ];

    propagatedBuildInputs = [
      base_bigstring
      core
      int_repr
      sexplib
    ];

    doCheck = false; # we don't have quickcheck_deprecated
    hash = "05mb4vbf293iq1xx4acyrmi9cgcw6capwrsa54ils62alby6w6yq";
    meta.description = "System-independent part of Core";
  };

  core_unix = janePackage {
    pname = "core_unix";
    version = "0.15.2";

    postPatch = ''
      patchShebangs unix_pseudo_terminal/src/discover.sh
    '';

    buildInputs = [ jst-config ];

    propagatedBuildInputs = [
      core_kernel
      expect_test_helpers_core
      ocaml_intrinsics
      ppx_jane
      timezone
      spawn
    ];

    hash = "sha256-9f2PiLo+4Bjnfvh3scvIiPHj0wPZozmMMiCTe7vC1EA=";
    meta.description = "Unix-specific portions of Core";
  };

  csvfields = janePackage {
    pname = "csvfields";
    version = "0.15.1";

    propagatedBuildInputs = [
      core
      num
    ];

    hash = "sha256-bBupsarwjte2NCncNDFSkrrmMR3EYPn+D7xI9zQOhFA=";
    meta.description = "Runtime support for ppx_xml_conv and ppx_csv_conv";
  };

  delimited_parsing = janePackage {
    pname = "delimited_parsing";

    propagatedBuildInputs = [
      async
      core_extended
    ];

    hash = "0d050v58zzi8c4qiwxbfcyrdw6zvncnnl3qj79qi0yq4xkg7820r";
    meta.description = "Parsing of character (e.g., comma) separated and fixed-width values";
  };

  ecaml = janePackage {
    pname = "ecaml";

    propagatedBuildInputs = [
      async
      expect_test_helpers_core
    ];

    hash = "08g2bl06vkn3bkqzkmvk2646aqb6jj4a7n3wgzpcx1c2gl3iw5i6";
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

    hash = "00h66l2g5rjaay0hbyqy4v9i866g779miriwv20h9k4mliqdq7in";
    meta.description = "E-mail message parser";
  };

  expect_test_helpers_async = janePackage {
    pname = "expect_test_helpers_async";

    propagatedBuildInputs = [
      async
      expect_test_helpers_core
    ];

    hash = "14v4966p5dmqgjb9sgrvnsixv0w0bagicn8v44g9mf9d88z8pfym";
    meta.description = "Async helpers for writing expectation tests";
  };

  expect_test_helpers_core = janePackage {
    pname = "expect_test_helpers_core";

    propagatedBuildInputs = [
      core_kernel
      sexp_pretty
    ];

    hash = "0bxs3g0zzym8agfcbpg5lmrh6hcb86z861bq40xhhfwqf4pzdbfa";
    meta.description = "Helpers for writing expectation tests";
  };

  fieldslib = janePackage {
    pname = "fieldslib";
    propagatedBuildInputs = [ base ];
    hash = "0xwf9mdxlyr3f0vv5y82cyw2bsckwl8rwf6jm6bai1gqpgxjq756";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Syntax extension to define first class values representing record fields, to get and set record fields, iterate and fold over all fields of a record and create new record values";
  };

  file_path = janePackage {
    pname = "file_path";

    propagatedBuildInputs = [
      async
      core
      core_kernel
      core_unix
      expect_test_helpers_async
      expect_test_helpers_core
      ppx_jane
    ];

    hash = "0vjvxviryywwwfdazcijwhpajp2d4mavlki7lj4qaafjrw62x14k";
    minimalOCamlVersion = "4.11";
    meta.description = "Library for typed manipulation of UNIX-style file paths";
  };

  fuzzy_match = janePackage {
    pname = "fuzzy_match";

    propagatedBuildInputs = [
      core
      ppx_jane
    ];

    hash = "0s5w81698b07l5m11nwx8xbjcpmp54dnf5fcrnlva22jrlsf14h4";
    meta.description = "Library for fuzzy string matching";
  };

  fzf = janePackage {
    pname = "fzf";

    postPatch = ''
      substituteInPlace src/fzf.ml --replace /usr/bin/fzf ${fzf}/bin/fzf
    '';

    propagatedBuildInputs = [
      async
      core_kernel
      ppx_jane
    ];

    hash = "1ha0i6dx5bgwzbdi4rn98wjwi2imv5p2i7qs7hy0c6cmg88xbdry";
    minimalOCamlVersion = "4.08";
    meta.description = "Library for running the fzf command line tool";
  };

  higher_kinded = janePackage {
    pname = "higher_kinded";

    propagatedBuildInputs = [
      base
      ppx_jane
    ];

    hash = "0rafxxajqswi070h8sinhjna0swh1hc6d7i3q7y099yj3wlr2y1l";
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

    hash = "1sija9w2im8vdp61h387w0mww9hh7jgkgsjcccps4lbv936ac7c1";
    meta.description = "Library for building dynamic webapps, using Js_of_ocaml";
  };

  incr_map = janePackage {
    pname = "incr_map";
    buildInputs = [ ppx_pattern_bind ];

    propagatedBuildInputs = [
      abstract_algebra
      incremental
    ];

    hash = "0aq8wfylvq68him92vzh1fqmr7r0lfwc5cdiqr10r5x032vzpnii";
    meta.description = "Helpers for incremental operations on map like data structures";
  };

  incr_select = janePackage {
    pname = "incr_select";
    propagatedBuildInputs = [ incremental ];
    hash = "0qm2i4hb5jh2ra95kq881s4chkwbd2prvql1c0nahd63h829m57l";
    meta.description = "Handling of large set of incremental outputs from a single input";
  };

  incremental = janePackage {
    pname = "incremental";
    propagatedBuildInputs = [ core_kernel ];
    hash = "1dp30mhljnbcxqimydwbmxx0x4y4xnb55gyhldm1f5qrwdxdl747";
    meta.description = "Library for incremental computations";
  };

  int_repr = janePackage {
    pname = "int_repr";

    propagatedBuildInputs = [
      base
      ppx_jane
    ];

    hash = "0ph88ym3s9dk30n17si2xam40sp8wv1xffw5cl3bskc2vfya1nvl";
    meta.description = "Integers of various widths";
  };

  jane-street-headers = janePackage {
    pname = "jane-street-headers";
    hash = "1lzk3w66x4429n2j75lwm55xafc46mywgdrbh9nc9jwqwgzf0wwx";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Jane Street C header files";
  };

  jsonaf = janePackage {
    pname = "jsonaf";

    propagatedBuildInputs = [
      base
      ppx_jane
      angstrom
      faraday
    ];

    hash = "1j9rn8vsvfpgmdpmdqb5qhvss5171j8n3ii1bcgnavqinchbvqa6";
    meta.description = "Library for parsing, manipulating, and serializing data structured as JSON";
  };

  jst-config = janePackage {
    pname = "jst-config";

    patches = [
      # remove on next release
      (fetchpatch {
        sha256 = "sha256-8hVC76z5ilYD/++xRHVswy/l+zzDt63jH4hfSJ/rPaA=";
        url = "https://github.com/janestreet/jst-config/commit/e5fdac6e5df9ba93e014a4d2db841fdbf209446f.patch";
      })
    ];

    buildInputs = [
      dune-configurator
      ppx_assert
      stdio
    ];

    hash = "1lxqsj5k3v8p7g802vj1xc6bs5wrfpszh3q61xvpcd42pf3ahma9";
    meta.description = "Compile-time configuration for Jane Street libraries";
  };

  ocaml-compiler-libs = janePackage {
    pname = "ocaml-compiler-libs";
    version = "0.12.4";
    hash = "00if2f7j9d8igdkj4rck3p74y17j6b233l91mq02drzrxj199qjv";
    minimalOCamlVersion = "4.04.1";
    meta.description = "OCaml compiler libraries repackaged";
  };

  ocaml-embed-file = janePackage {
    pname = "ocaml-embed-file";

    propagatedBuildInputs = [
      async
      ppx_jane
    ];

    hash = "1nzgc0q05f0j3q1kwfpyhhhpgwrfjvmkqqifrkrm4y7d1i44bfnw";
    meta.description = "Files contents as module constants";
  };

  ocaml_intrinsics = janePackage {
    pname = "ocaml_intrinsics";
    version = "0.15.2";
    buildInputs = [ dune-configurator ];
    doCheck = false; # test rules broken
    hash = "sha256-f5zqrKaokj1aEvbu7lOuK0RoWSklFr6QFpV+oWbIX9U=";
    minimalOCamlVersion = "4.08";
    meta.description = "Intrinsics";
  };

  parsexp = janePackage {
    pname = "parsexp";

    propagatedBuildInputs = [
      base
      sexplib0
    ];

    hash = "1grzpxi39318vcqhwf723hqh11k68irh59zb3dyg9lw8wjn7752a";
    minimalOCamlVersion = "4.04.2";
    meta.description = "S-expression parsing library";
  };

  patdiff = janePackage {
    pname = "patdiff";
    # Used by patdiff-git-wrapper.  Providing it here also causes the shebang
    # line to be automatically patched.
    buildInputs = [ bash ];

    propagatedBuildInputs = [
      core_unix
      patience_diff
      ocaml_pcre
    ];

    hash = "0623a7n5r659rkxbp96g361mvxkcgc6x9lcbkm3glnppplk5kxr9";

    meta = {
      description = "File Diff using the Patience Diff algorithm";
    };
  };

  patience_diff = janePackage {
    pname = "patience_diff";
    propagatedBuildInputs = [ core_kernel ];
    hash = "17yrhn4qfi31m8g1ygb3m6i9z4fqd8f60fn6viazgx06s3x4xp3v";
    meta.description = "Diff library using Bram Cohen's patience diff algorithm";
  };

  posixat = janePackage {
    pname = "posixat";

    propagatedBuildInputs = [
      ppx_optcomp
      ppx_sexp_conv
    ];

    hash = "1xgycwa0janrfn9psb7xrm0820blr82mqf1lvjy9ipqalj7v9w1f";
    minimalOCamlVersion = "4.07";
    meta.description = "Binding to the posix *at functions";
  };

  ppx_accessor = janePackage {
    pname = "ppx_accessor";
    propagatedBuildInputs = [ accessor ];
    hash = "0qv51if1nk0zff2v6q946h8ac7bpd5xa4ivyixl9g4h2mk29w4qb";
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

    hash = "0dic250q3flrjs3i70a2qqqnhqqj75ddlixpy7hdfghjw32azw90";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Assert-like extension nodes that raise useful errors on failure";
  };

  ppx_base = janePackage {
    pname = "ppx_base";

    propagatedBuildInputs = [
      ppx_cold
      ppx_enumerate
      ppx_hash
    ];

    hash = "13rfmy2fxvwi7z5l1mai474ri5anqjm8q4hs7dblplsjjd9m5ld1";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Base set of ppx rewriters";
  };

  ppx_bench = janePackage {
    pname = "ppx_bench";
    version = "0.15.1";
    propagatedBuildInputs = [ ppx_inline_test ];
    hash = "sha256-2uk3NfpAODScoQtqiU+ZaOE8zOqkayn/jpfn3GQ4vQg=";
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
    hash = "1280wsls061fmvmdysjqn3lv4mnkyg400jnjf4jyfr14s33h1ad5";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Generation of bin_prot readers and writers from types";
  };

  ppx_cold = janePackage {
    pname = "ppx_cold";
    propagatedBuildInputs = [ ppxlib ];
    hash = "0x7xgpvy0l28k971xy08ibhr4w9nh8d9zvxc6jfxxx4fbfcv5gca";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Expands [@cold] into [@inline never][@specialise never][@local never]";
  };

  ppx_compare = janePackage {
    pname = "ppx_compare";

    propagatedBuildInputs = [
      ppxlib
      base
    ];

    hash = "1wjwqkr71p61vjidbr80l93y4kkad7xsfyp04w8qfqrj7h5nm625";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Generation of comparison functions from types";
  };

  ppx_conv_func = janePackage {
    pname = "ppx_conv_func";

    propagatedBuildInputs = [
      ppxlib
      base
    ];

    hash = "sha256-61jX8yHZYOnMx1Jlqaq9zSOz25HLOa0Wv/iG6Hu82zI=";
    meta.description = "Part of the Jane Street's PPX rewriters collection";
  };

  ppx_css = janePackage {
    pname = "ppx_css";

    propagatedBuildInputs = [
      core_kernel
      ppxlib
      js_of_ocaml
      js_of_ocaml-ppx
      sedlex
    ];

    hash = "09dpmj3f3m3z1ji9hq775iqr3cfmv5gh7q9zlblizj4wx4y0ibyi";
    meta.broken = true; # Not compatible with sedlex > 3.4
    meta.description = "PPX that takes in css strings and produces a module for accessing the unique names defined within";
  };

  ppx_csv_conv = janePackage {
    pname = "ppx_csv_conv";

    propagatedBuildInputs = [
      csvfields
      ppx_conv_func
    ];

    hash = "sha256-ctwgUs1buBZiNqac4760LhWd2/PMZRuxx8SE5T7yZ+g=";
    meta.description = "Generate functions to read/write records in csv format";
  };

  ppx_custom_printf = janePackage {
    pname = "ppx_custom_printf";
    propagatedBuildInputs = [ ppx_sexp_conv ];
    hash = "1k8nmq6kwqz2wpkm9ymq749dz1vd8lxrjc711knp1wyz5935hnsv";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Printf-style format-strings for user-defined string conversion";
  };

  ppx_disable_unused_warnings = janePackage {
    pname = "ppx_disable_unused_warnings";
    propagatedBuildInputs = [ ppxlib ];
    hash = "0sb5i4v7p9df2bxk66rjs30k9fqdrwsq1jgykjv6wyrx2d9bv955";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Expands [@disable_unused_warnings] into [@warning \"-20-26-32-33-34-35-36-37-38-39-60-66-67\"]";
  };

  ppx_enumerate = janePackage {
    pname = "ppx_enumerate";
    propagatedBuildInputs = [ ppxlib ];
    hash = "1i0f6jv5cappw3idd70wpg76d7x6mvxapa89kri1bwz47hhg4pkz";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Generate a list containing all values of a finite type";
  };

  ppx_expect = janePackage {
    pname = "ppx_expect";
    version = "0.15.1";

    propagatedBuildInputs = [
      ppx_here
      ppx_inline_test
      re
    ];

    doCheck = false; # test build rules broken
    hash = "sha256-qlOipzTTdN9yQ35sItKmWpCv74kbuJLDg4IHNVTKvow=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Cram like framework for OCaml";
  };

  ppx_fields_conv = janePackage {
    pname = "ppx_fields_conv";

    propagatedBuildInputs = [
      fieldslib
      ppxlib
    ];

    hash = "094wsnw7fcwgl9xg6vkjb0wbgpn9scsp847yhdd184sz9v1amz14";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Generation of accessor and iteration functions for ocaml records";
  };

  ppx_fixed_literal = janePackage {
    pname = "ppx_fixed_literal";
    propagatedBuildInputs = [ ppxlib ];
    hash = "10siwcqrqa4gh0mg6fkaby0jjskc01r81pcblc67h3vmbjjh08j9";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Simpler notation for fixed point literals";
  };

  ppx_hash = janePackage {
    pname = "ppx_hash";

    propagatedBuildInputs = [
      ppx_compare
      ppx_sexp_conv
    ];

    hash = "15agkwavadllzxdv4syjna02083nfnap8qs4yqf5s0adjw73fzyg";
    minimalOCamlVersion = "4.04.2";
    meta.description = "PPX rewriter that generates hash functions from type expressions and definitions";
  };

  ppx_here = janePackage {
    pname = "ppx_here";
    propagatedBuildInputs = [ ppxlib ];
    doCheck = false; # test build rules broken
    hash = "0jv81k8x18q8rxdyfwavrvx8yq9k5m3abpmgdg6zipx2ajcjzvag";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Expands [%here] into its location";
  };

  ppx_ignore_instrumentation = janePackage {
    pname = "ppx_ignore_instrumentation";
    propagatedBuildInputs = [ ppxlib ];
    hash = "16fgig88g3jr0m3i636fr52h29h1yzhi8nhnl4029zn808kcdyj2";
    minimalOCamlVersion = "4.08";
    meta.description = "Ignore Jane Street specific instrumentation extensions";
  };

  ppx_inline_test = janePackage {
    pname = "ppx_inline_test";
    version = "0.15.1";

    propagatedBuildInputs = [
      ppxlib
      time_now
    ];

    doCheck = false; # test build rules broken
    hash = "sha256-9Up4/VK4gayuwbPc3r6gVRj78ILO2G3opL5UDOTKOgk=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Syntax extension for writing in-line tests in ocaml code";
  };

  ppx_jane = janePackage {
    pname = "ppx_jane";

    propagatedBuildInputs = [
      base_quickcheck
      ppx_bin_prot
      ppx_disable_unused_warnings
      ppx_expect
      ppx_fixed_literal
      ppx_ignore_instrumentation
      ppx_log
      ppx_module_timer
      ppx_optcomp
      ppx_optional
      ppx_pipebang
      ppx_stable
      ppx_string
      ppx_typerep_conv
      ppx_variants_conv
    ];

    hash = "1p6847gdfnnj6qpa4yh57s6wwpsl7rfgy0q7993chz24h9mhz5lk";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Standard Jane Street ppx rewriters";
  };

  ppx_js_style = janePackage {
    pname = "ppx_js_style";

    propagatedBuildInputs = [
      octavius
      ppxlib
    ];

    hash = "0q2p9pvmlncgv0hprph95xiv7s6q44ynvp4yl4dckf1qx68rb3ba";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Code style checker for Jane Street Packages";
  };

  ppx_jsonaf_conv = janePackage {
    pname = "ppx_jsonaf_conv";
    version = "0.15.1";

    propagatedBuildInputs = [
      base
      jsonaf
      ppx_jane
      ppxlib
    ];

    hash = "0wprs7qmscklyskj4famhaqqisi6jypy414aqba14qdyi43w0cv3";
    minimalOCamlVersion = "4.08";
    meta.description = "[@@deriving] plugin to generate Jsonaf conversion functions";
  };

  ppx_let = janePackage {
    pname = "ppx_let";

    propagatedBuildInputs = [
      ppxlib
      ppx_here
    ];

    hash = "04v3fq0vnvvavxbc7hfsrg8732pwxbyw8pjl3xfplqdqci6fj15n";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Monadic let-bindings";
  };

  ppx_log = janePackage {
    pname = "ppx_log";

    propagatedBuildInputs = [
      base
      ppx_here
      ppx_sexp_conv
      ppx_sexp_message
      sexplib
    ];

    hash = "08i9gz3f4w3bmlrfdw7ja9awsfkhhldz03bnnc4hijfmn8sawzi0";
    minimalOCamlVersion = "4.08.0";
    meta.description = "Ppx_sexp_message-like extension nodes for lazily rendering log messages";
  };

  ppx_module_timer = janePackage {
    pname = "ppx_module_timer";
    propagatedBuildInputs = [ time_now ];
    hash = "0lzi5hxi10p89ddqbrc667267f888kqslal76gfhmszyk60n20av";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Ppx rewriter that records top-level module startup times";
  };

  ppx_optcomp = janePackage {
    pname = "ppx_optcomp";
    propagatedBuildInputs = [ ppxlib ];
    hash = "0ypivfipi8fcr9pqyvl2ajpcivmr1irdwwv248i4x6mggpc2pl0b";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Optional compilation for OCaml";
  };

  ppx_optional = janePackage {
    pname = "ppx_optional";
    propagatedBuildInputs = [ ppxlib ];
    hash = "0amxwxhkyzamgnxx400qhvxzqr3m4sazhhkc516lm007pynv7xq2";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Pattern matching on flat options";
  };

  ppx_pattern_bind = janePackage {
    pname = "ppx_pattern_bind";
    propagatedBuildInputs = [ ppx_let ];
    hash = "01nfdk9yvk92r7sjl4ngxfsx8fyqh2dsjxz0i299nszv9jc4rn4f";
    minimalOCamlVersion = "4.07";
    meta.description = "PPX for writing fast incremental bind nodes in a pattern match";
  };

  ppx_pipebang = janePackage {
    pname = "ppx_pipebang";
    propagatedBuildInputs = [ ppxlib ];
    hash = "0sm5dghyalhws3hy1cc2ih36az1k4q02hcgj6l26gwyma3y4irvq";
    minimalOCamlVersion = "4.04.2";
    meta.description = "PPX rewriter that inlines reverse application operators `|>` and `|!`";
  };

  ppx_python = janePackage {
    pname = "ppx_python";

    propagatedBuildInputs = [
      ppx_base
      ppxlib
      pyml
    ];

    hash = "1d2wf0rkvxg07q6xq2zmxh6hmvnwlsmny3mm92jsg1s7bdl39gap";
    meta.description = "[@@deriving] plugin to generate Python conversion functions";
  };

  ppx_sexp_conv = janePackage {
    pname = "ppx_sexp_conv";
    version = "0.15.1";

    propagatedBuildInputs = [
      ppxlib
      sexplib0
      base
    ];

    hash = "sha256-NYknZHyDklr71hihM2pPFQ7uAKkuKO2DJkjtsF+xc5g=";
    minimalOCamlVersion = "4.08.0";
    meta.description = "[@@deriving] plugin to generate S-expression conversion functions";
  };

  ppx_sexp_message = janePackage {
    pname = "ppx_sexp_message";

    propagatedBuildInputs = [
      ppx_here
      ppx_sexp_conv
    ];

    hash = "0a7hx50bkkc5n5msc3zzc4ixnp7674x3mallknb9j31jnd8l90nj";
    minimalOCamlVersion = "4.04.2";
    meta.description = "PPX rewriter for easy construction of s-expressions";
  };

  ppx_sexp_value = janePackage {
    pname = "ppx_sexp_value";

    propagatedBuildInputs = [
      ppx_here
      ppx_sexp_conv
    ];

    hash = "0kz83j9v6yz3v8c6vr9ilhkcci4hhjd6i6r6afnx72jh6i7d3hnv";
    minimalOCamlVersion = "4.04.2";
    meta.description = "PPX rewriter that simplifies building s-expressions from ocaml values";
  };

  ppx_stable = janePackage {
    pname = "ppx_stable";
    propagatedBuildInputs = [ ppxlib ];
    hash = "1as0v0x8c9ilyhngax55lvwyyi4a2wshyan668v0f2s1608cwb1l";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Stable types conversions generator";
  };

  ppx_string = janePackage {
    pname = "ppx_string";

    propagatedBuildInputs = [
      ppx_base
      ppxlib
      stdio
    ];

    hash = "1dp5frk6cig5m3m5rrh2alw63snyf845x7zlkkaljip02pqcbw1s";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Ppx extension for string interpolation";
  };

  ppx_typed_fields = janePackage {
    pname = "ppx_typed_fields";

    propagatedBuildInputs = [
      core
      ppx_jane
      ppxlib
    ];

    hash = "0hxililjgy4jh66b4xmphrfhv6qpp7dz7xbz3islp357hf18niqy";
    meta.description = "GADT-based field accessors and utilities";
  };

  ppx_typerep_conv = janePackage {
    pname = "ppx_typerep_conv";

    propagatedBuildInputs = [
      ppxlib
      typerep
    ];

    hash = "1q1lzykpm83ra4l5jh4rfddhd3c96kx4s4rvx0w4b51z1qk56zam";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Generation of runtime types from type declarations";
  };

  ppx_variants_conv = janePackage {
    pname = "ppx_variants_conv";

    propagatedBuildInputs = [
      variantslib
      ppxlib
    ];

    hash = "1dh0bw9dn246k00pymf59yjkl6x6bxd76lkk9b5xpq2692wwlc3s";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Generation of accessor and iteration functions for ocaml variant types";
  };

  profunctor = janePackage {
    pname = "profunctor";

    propagatedBuildInputs = [
      base
      ppx_jane
      record_builder
    ];

    hash = "151vk0cagjwn0isnnwryn6gmvnpds4dyj1in9jvv5is8yij203gg";
    meta.description = "Library providing a signature for simple profunctors and traversal of a record";
  };

  protocol_version_header = janePackage {
    pname = "protocol_version_header";
    propagatedBuildInputs = [ core_kernel ];
    hash = "0s638cwf1357gg754rc4306654hhrhzqaqm2lp3yv5vj3ml8p4qy";
    meta.description = "Protocol versioning";
  };

  pythonlib = janePackage {
    pname = "pythonlib";
    version = "0.15.1";
    buildInputs = [ ppx_optcomp ];

    propagatedBuildInputs = [
      ppx_expect
      ppx_let
      ppx_python
      stdio
      typerep
    ];

    hash = "sha256-j8WXVTEiBmHtoTjkbnIh31vC4IghfAMaEL19nDLx3mc=";
    meta.description = "Library to help writing wrappers around ocaml code for python";
  };

  re2 = janePackage {
    pname = "re2";
    propagatedBuildInputs = [ core_kernel ];
    hash = "0z1cajd8abrryf3gz322jpynba79nv4a2kmmcdz0314ran5w68v3";

    prePatch = ''
      substituteInPlace src/re2_c/dune --replace 'CXX=g++' 'CXX=c++'
      substituteInPlace src/dune --replace '(cxx_flags (:standard \ -pedantic) (-I re2_c/libre2))' '(cxx_flags (:standard \ -pedantic) (-I re2_c/libre2) (-x c++))'
    '';

    meta.description = "OCaml bindings for RE2, Google's regular expression library";
  };

  re2_stable = janePackage {
    pname = "re2_stable";
    version = "0.14.0";

    propagatedBuildInputs = [
      core
      re2
    ];

    hash = "0kjc0ff6b3509s3b9n4q8ilb06d5fngdh3z58cm95vg7zkcas9w3";
    meta.description = "Re2_stable adds an incomplete but stable serialization of Re2";
  };

  record_builder = janePackage {
    pname = "record_builder";

    propagatedBuildInputs = [
      base
      ppx_jane
    ];

    hash = "004nqcmwll0vy47mb3d3jlk21cc6adcjy62dkv2k966n9jkh472h";
    meta.description = "Library which provides traversal of records with an applicative";
  };

  redis-async = janePackage {
    pname = "redis-async";

    propagatedBuildInputs = [
      async
      bignum
      core
      core_kernel
      ppx_jane
    ];

    hash = "0pccf4gkm880yyk8x4kgy5rwblkbscxav2sbis13abpms9vr7jfn";
    meta.description = "Redis client for Async applications";
  };

  resource_cache = janePackage {
    pname = "resource_cache";
    propagatedBuildInputs = [ async_rpc_kernel ];
    hash = "13wzx8ixgbb7jj5yrps890irw2wvkchnihsn7rfrcvnvrjzzjshm";
    meta.description = "General resource cache";
  };

  sexp = janePackage {
    pname = "sexp";

    propagatedBuildInputs = [
      async
      core
      csvfields
      jsonaf
      re2
      sexp_diff
      sexp_macro
      sexp_pretty
      sexp_select
    ];

    hash = "00xlsymm1mpgs8cqkb6c36vh5hfw0saghvwiqh7jry65qc5nvv9z";
    meta.broken = true; # Does not build with GCC 14
    meta.description = "S-expression swiss knife";
  };

  sexp_diff = janePackage {
    pname = "sexp_diff";
    propagatedBuildInputs = [ core_kernel ];
    hash = "1p5xwhj634ij4a0m5k6a3abddi5315y7is1a6ha1lifdz3v985ll";
    meta.description = "Code for computing the diff of two sexps";
  };

  sexp_macro = janePackage {
    pname = "sexp_macro";

    propagatedBuildInputs = [
      async
      sexplib
    ];

    hash = "1l5dsv9gawmf5dg3rf8sxphp9qs3n4n038nlmf9rxzypzyn112k8";
    meta.description = "Sexp macros";
  };

  sexp_pretty = janePackage {
    pname = "sexp_pretty";
    version = "0.15.1";

    propagatedBuildInputs = [
      ppx_base
      re
      sexplib
    ];

    hash = "sha256-UJEO2P4C7ZaD110MEfkG4FXfGDVAAW2TAK489faV6SM=";
    minimalOCamlVersion = "4.07";
    meta.description = "S-expression pretty-printer";
  };

  sexp_select = janePackage {
    pname = "sexp_select";

    propagatedBuildInputs = [
      base
      ppx_jane
    ];

    hash = "0mmvga9w3gbb2gd1h4l8f1c3l2lrpn1zld2a8xgqyfqfff3vg31p";
    minimalOCamlVersion = "4.07";
    meta.description = "Library to use CSS-style selectors to traverse sexp trees";
  };

  sexplib = janePackage {
    pname = "sexplib";
    version = "0.15.1";

    propagatedBuildInputs = [
      num
      parsexp
    ];

    hash = "sha256-LkGNnp717LMHeWe1Ka6qUZcpw8fKSsd5MusaLgFjm70=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Library for serializing OCaml values to and from S-expressions";
  };

  sexplib0 = janePackage {
    pname = "sexplib0";
    version = "0.15.1";
    hash = "sha256-6K0yrCbVFcUalN4cQuDI1TvWvNDjfXXRDhJKUskbqRY=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Library containing the definition of S-expressions and some base converters";
  };

  shell = janePackage {
    pname = "shell";
    buildInputs = [ jst-config ];
    propagatedBuildInputs = [ textutils ];
    doCheck = false; # Does not build with GCC 14
    checkInputs = [ ounit ];
    hash = "1vzdif7w9y1kw2qynlfixwphdgiflrf43j0fzinjp9f56vlhghhy";
    meta.description = "Yet another implementation of fork&exec and related functionality";
  };

  shexp = janePackage {
    pname = "shexp";

    propagatedBuildInputs = [
      posixat
      spawn
    ];

    hash = "05iswnhi92f4yvrh76j3254bvls6fbrdb56mv6vc6mi5f8z4l79i";
    minimalOCamlVersion = "4.07";
    meta.description = "Process library and s-expression based shell";
  };

  spawn = janePackage {
    pname = "spawn";
    buildInputs = [ ppx_expect ];
    hash = "1fjr91psas5zmk1hxvxh0dchhn0pkyzlr4gg232f5g9vdgissi0p";
    minimalOCamlVersion = "4.02.3";
    meta.description = "Spawning sub-processes";
  };

  splay_tree = janePackage {
    pname = "splay_tree";
    propagatedBuildInputs = [ core_kernel ];
    hash = "1jxfh7f2hjrms5pm2cy1cf6ivphgiqqvyyr9hdcz8d3vi612p4dm";
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

    hash = "0ap5z4z1aagz4z02q9642cbl25jzws9lbc2x5xkpyjlc0qcm9v3m";
    meta.description = "PRNG that can be split into independent streams";
  };

  stdio = janePackage {
    pname = "stdio";
    propagatedBuildInputs = [ base ];
    hash = "0g00b00kpjcadikq2asng35w7kvd24q9ldkiylwmn3gv3lrbipa8";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Standard IO library for OCaml";
  };

  textutils = janePackage {
    pname = "textutils";

    propagatedBuildInputs = [
      core_unix
      textutils_kernel
    ];

    hash = "1wass49h645wql9b7nck2iqlkf4648dkxvlvxixr7z80zcnb5rxr";
    meta.description = "Text output utilities";
  };

  textutils_kernel = janePackage {
    pname = "textutils_kernel";

    propagatedBuildInputs = [
      core
      ppx_jane
      uutf
    ];

    hash = "068g11d98wsb5a6ds0p5xybdmx5nx9bxa0k11dmh3l57kn4c169x";
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

    hash = "1pa0hyh470j9jylii4983qagb6hq2dz6s0q2fnrcph9qbw83bc0c";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Reports the current time";
  };

  timezone = janePackage {
    pname = "timezone";
    propagatedBuildInputs = [ core_kernel ];
    hash = "00a007aji5rbz42kgbq1w90py6fm9k9akycs5abkcfll5rd0cbhx";
    meta.description = "Time-zone handling";
  };

  topological_sort = janePackage {
    pname = "topological_sort";

    propagatedBuildInputs = [
      ppx_jane
      stdio
    ];

    hash = "0iqhp8n6g5n1ng80brjpav54229lykm2c1fc104s58lk3rqfvj9v";
    meta.description = "Topological sort algorithm";
  };

  typerep = janePackage {
    pname = "typerep";
    propagatedBuildInputs = [ base ];
    hash = "1qxfi01qim0hrgd6d0bgvpxg36i99mmm8cw4wqpr9kxyqvgzv26z";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Typerep is a library for runtime types";
  };

  variantslib = janePackage {
    pname = "variantslib";
    propagatedBuildInputs = [ base ];
    hash = "033ns8ph6bd8g5cdfryjfcnrnzkdshppjyw5kl7cvszjfrz33ij7";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Part of Jane Street's Core library";
  };

  vcaml = janePackage {
    pname = "vcaml";

    propagatedBuildInputs = [
      angstrom-async
      async_extra
      expect_test_helpers_async
      faraday
    ];

    hash = "12fd29x9dgf4f14xrx7z4y1bm1wbfynrs3jismjbiqnckfpbqrib";
    meta.description = "OCaml bindings for the Neovim API";
  };

  virtual_dom = janePackage {
    pname = "virtual_dom";
    version = "0.15.1";
    buildInputs = [ js_of_ocaml-ppx ];

    propagatedBuildInputs = [
      core_kernel
      gen_js_api
      js_of_ocaml
      lambdasoup
      tyxml
    ];

    hash = "sha256-Uv6ZDxz2/H0nHjiycUKNQwy/zZyHHmwDEHknFHwDuDs=";
    meta.description = "OCaml bindings for the virtual-dom library";
  };

  zarith_stubs_js = janePackage {
    pname = "zarith_stubs_js";
    hash = "119xgr3kla9q1bvs4a5z2ivbmsrz4db3a9z0gf77ryqg4i22ywvl";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Javascripts stubs for the Zarith library";
  };

  zstandard = janePackage {
    pname = "zstandard";
    buildInputs = [ ppx_jane ];

    propagatedBuildInputs = [
      core_kernel
      ctypes
      zstd
    ];

    hash = "1blkv35g5q1drkc6zmc4m027gjz6vfdadra1kw1xkp1wlc2l4v3k";
    meta.description = "OCaml bindings to Zstandard";
  };

}
