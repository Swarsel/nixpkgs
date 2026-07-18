{
  lib,
  stdenv,
  ant,
  coreutils,
  fetchgit,
  git,
  jdk11,
  libgbm,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  libxrender,
  libxt,
  libxxf86vm,
  stripJavaArchivesHook,
  udev,
  xmlstarlet,
}:

let
  version = "2.4.0";

  gluegen-src = fetchgit {
    fetchSubmodules = true;
    hash = "sha256-qQzq7v2vMFeia6gXaNHS3AbOp9HhDRgISp7P++CKErA=";
    rev = "v${version}";
    url = "git://jogamp.org/srv/scm/gluegen.git";
  };
  jogl-src = fetchgit {
    fetchSubmodules = true;
    hash = "sha256-PHDq7uFEQfJ2P0eXPUi0DGFR1ob/n5a68otgzpFnfzQ=";
    rev = "v${version}";
    url = "git://jogamp.org/srv/scm/jogl.git";
  };
in
stdenv.mkDerivation {
  inherit version;
  pname = "jogl";

  postPatch = ''
    substituteInPlace gluegen/src/java/com/jogamp/common/util/IOUtil.java \
      --replace-fail '#!/bin/true' '#!${coreutils}/bin/true'
  ''
  # prevent looking for native libraries in /usr/lib
  + ''
    substituteInPlace jogl/make/build-*.xml \
      --replace-warn 'dir="''${TARGET_PLATFORM_USRLIBS}"' ""
  ''
  # force way to do dysfunctional "ant -Dsetup.addNativeBroadcom=false" and disable dependency on raspberrypi drivers
  # if arm/aarch64 support will be added, this block might be commented out on those platforms
  # on x86 compiling with default "setup.addNativeBroadcom=true" leads to unsatisfied import "vc_dispmanx_resource_delete" in libnewt.so
  + ''
    xmlstarlet ed --inplace \
      --delete '//*[@if="setup.addNativeBroadcom"]' \
      jogl/make/build-newt.xml
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    sed -i '/if="use.macos/d' gluegen/make/gluegen-cpptasks-base.xml
    rm -r jogl/oculusvr-sdk
  '';

  nativeBuildInputs = [
    ant
    jdk11
    git
    xmlstarlet
    stripJavaArchivesHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    udev
    libx11
    libxrandr
    libxcursor
    libxi
    libxt
    libxxf86vm
    libxrender
    libgbm
  ];

  env = {
    # error: incompatible pointer to integer conversion returning 'GLhandleARB' (aka 'void *') from a function with result type 'jlong' (aka 'long long')
    NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-int-conversion";
    SOURCE_LEVEL = "1.8";
    TARGET_LEVEL = "1.8";
    TARGET_RT_JAR = "null.jar";
  };

  buildPhase = ''
    runHook preBuild

    for f in gluegen jogl; do
      pushd $f/make
      ant
      popd
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/java
    cp -v $NIX_BUILD_TOP/gluegen/build/gluegen-rt{,-natives-linux-*}.jar $out/share/java/
    cp -v $NIX_BUILD_TOP/jogl/build/jar/jogl-all{,-natives-linux-*}.jar  $out/share/java/
    cp -v $NIX_BUILD_TOP/jogl/build/nativewindow/nativewindow{,-awt,-natives-linux-*,-os-drm,-os-x11}.jar  $out/share/java/

    runHook postInstall
  '';

  sourceRoot = ".";

  srcs = [
    gluegen-src
    jogl-src
  ];

  unpackCmd = "cp -r $curSrc \${curSrc##*-}";

  meta = {
    description = "Java libraries for 3D Graphics, Multimedia and Processing";
    homepage = "https://jogamp.org/";
    changelog = "https://jogamp.org/deployment/jogamp-current/archive/ChangeLogs/";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
  };
}
