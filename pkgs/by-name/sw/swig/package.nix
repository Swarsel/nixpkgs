{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  bison,
  libtool,
  pcre2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swig";
  version = "4.4.1";

  src = fetchFromGitHub {
    owner = "swig";
    repo = "swig";
    rev = "v${finalAttrs.version}";
    hash = "sha256-jsi83v9sg0n5kUfDACqdNAS2VuLSyxv+pe2LRcO4Khc=";
  };

  # Disable ccache documentation as it needs yodl
  postPatch = ''
    sed -i '/man1/d' CCache/Makefile.in
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    bison
    pcre2
  ];

  buildInputs = [ pcre2 ];
  configureFlags = [ "--without-tcl" ];

  preConfigure = ''
    ./autogen.sh
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Interface compiler that connects C/C++ code to higher-level languages";
    homepage = "https://swig.org/";
    changelog = "https://github.com/swig/swig/blob/${finalAttrs.src.rev}/CHANGES.current";
    # Different types of licenses available: https://www.swig.org/Release/LICENSE .
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ hythera ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "swig";
  };
})
