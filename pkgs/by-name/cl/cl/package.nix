{
  lib,
  stdenv,
  fetchFromGitHub,
  beamPackages,
  ocl-icd,
  opencl-headers,
  rebar3,
}:

stdenv.mkDerivation rec {
  pname = "cl";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "tonyrog";
    repo = "cl";
    rev = "cl-${version}";
    sha256 = "1gwkjl305a0231hz3k0w448dsgbgdriaq764sizs5qfn59nzvinz";
  };

  # https://github.com/tonyrog/cl/issues/39
  postPatch = ''
    substituteInPlace c_src/Makefile \
      --replace-fail "-m64" ""
  '';

  buildInputs = [
    beamPackages.erlang
    rebar3
    opencl-headers
    ocl-icd
  ];

  buildPhase = ''
    rebar3 compile
  '';

  # 'cp' line taken from Arch recipe
  # https://projects.archlinux.org/svntogit/community.git/tree/trunk/PKGBUILD?h=packages/erlang-sdl
  installPhase = ''
    DIR=$out/lib/erlang/lib/${pname}-${version}
    mkdir -p $DIR
    cp -ruv c_src doc ebin include priv src $DIR
  '';

  meta = {
    description = "OpenCL binding for Erlang";
    homepage = "https://github.com/tonyrog/cl";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
