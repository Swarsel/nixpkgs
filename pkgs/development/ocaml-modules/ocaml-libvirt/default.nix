{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  findlib,
  libvirt,
  ocaml,
  perl,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "ocaml-libvirt";
  version = "0.6.1.5";

  src = fetchFromGitLab {
    owner = "libvirt";
    repo = "libvirt-ocaml";
    rev = "v${version}";
    sha256 = "0xpkdmknk74yqxgw8z2w8b7ss8hpx92xnab5fsqg2byyj55gzf2k";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    findlib
    perl
    ocaml
  ];

  propagatedBuildInputs = [ libvirt ];

  buildFlags = [
    "all"
    "opt"
    "CPPFLAGS=-Wno-error"
  ];

  preInstall = ''
    # Fix 'dllmllibvirt.so' install failure into non-existent directory.
    mkdir -p $OCAMLFIND_DESTDIR/stublibs
  '';

  installTargets = "install-opt";

  meta = {
    inherit (ocaml.meta) platforms;
    description = "OCaml bindings for libvirt";
    homepage = "https://libvirt.org/ocaml/";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    broken = !(lib.versionAtLeast ocaml.version "4.02");
  };
}
