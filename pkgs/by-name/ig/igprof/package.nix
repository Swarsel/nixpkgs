{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gdb,
  libunwind,
  pcre,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "igprof";
  version = "5.9.18";

  src = fetchFromGitHub {
    owner = "igprof";
    repo = "igprof";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-UTrAaH8C79km78Z/7NxvQ6dnl4u4Ki80nORf4bsoSNw=";
  };

  postPatch = ''
    substituteInPlace src/igprof \
      --replace-fail libigprof.so $out/lib/libigprof.so
    substituteInPlace CMakeLists.txt \
      --replace-fail "CMAKE_MINIMUM_REQUIRED(VERSION 2.6)" "CMAKE_MINIMUM_REQUIRED(VERSION 3.10)"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    libunwind
    gdb
    pcre
  ];

  env.CXXFLAGS = toString [
    "-fPIC"
    "-O2"
    "-w"
    "-fpermissive"
  ];

  meta = {
    description = "Ignominous Profiler";

    longDescription = ''
      IgProf is a fast and light weight profiler. It correctly handles
      dynamically loaded shared libraries, threads and sub-processes started by
      the application.  We have used it routinely with large C++ applications
      consisting of many hundreds of shared libraries and thousands of symbols
      from millions of source lines of code. It requires no special privileges
      to run. The performance reports provide full navigable call stacks and
      can be customised by applying filters. Results from any number of
      profiling runs can be included. This means you can both dig into the
      details and see the big picture from combined workloads.
    '';

    homepage = "https://igprof.org/";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ ktf ];
    platforms = lib.platforms.linux;
    broken = (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64);
  };
})
