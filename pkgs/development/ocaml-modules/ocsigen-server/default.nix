{
  lib,
  fetchFromGitHub,
  bigstringaf,
  buildDunePackage,
  ca-certs,
  camlzip,
  cohttp,
  cohttp-lwt-unix,
  cryptokit,
  cstruct,
  findlib,
  ipaddr,
  logs-syslog,
  lwt,
  lwt_react,
  lwt_ssl,
  makeWrapper,
  mirage-crypto,
  mirage-crypto-ec,
  mirage-crypto-rng,
  mtime,
  ocaml,
  ptime,
  re,
  ssl,
  which,
  xml-light,
  zarith,
}:

let
  mkpath = p: "${p}/lib/ocaml/${ocaml.version}/site-lib/stublibs";
in

let
  caml_ld_library_path = lib.concatMapStringsSep ":" mkpath [
    bigstringaf
    lwt
    ssl
    cstruct
    mirage-crypto
    zarith
    mirage-crypto-ec
    ptime
    mirage-crypto-rng
    mtime
    ca-certs
    cryptokit
    re
  ];
in

buildDunePackage (finalAttrs: {
  pname = "ocsigenserver";
  version = "7.0.0";

  src = fetchFromGitHub {
    owner = "ocsigen";
    repo = "ocsigenserver";
    tag = finalAttrs.version;
    hash = "sha256-J2XBelpRWJGeIF9RdC9+icJI1hc6Oe0k1w25QHZz0zs=";
  };

  nativeBuildInputs = [
    makeWrapper
    which
  ];

  buildInputs = [
    lwt_react
    camlzip
    findlib
  ];

  propagatedBuildInputs = [
    cohttp
    cohttp-lwt-unix
    cryptokit
    ipaddr
    lwt_ssl
    re
    logs-syslog
    xml-light
  ];

  postInstall = ''
    make install.files
  '';

  postFixup = ''
    rm -rf $out/var/run
    wrapProgram $out/bin/ocsigenserver \
      --suffix CAML_LD_LIBRARY_PATH : "${caml_ld_library_path}"
  '';

  configurePlatforms = [ ];
  dontAddPrefix = true;
  dontAddStaticConfigureFlags = true;
  dontPatchShebangs = true;

  meta = {
    description = "Full featured Web server";

    longDescription = ''
      A full featured Web server. It implements most features of the HTTP protocol, and has a very powerful extension mechanism that make very easy to plug your own OCaml modules for generating pages.
    '';

    homepage = "http://ocsigen.org/ocsigenserver/";
    license = lib.licenses.lgpl21Only;
    maintainers = [ lib.maintainers.gal_bolle ];
  };

})
