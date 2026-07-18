{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  ant,
  autoPatchelfHook,
  boost,
  cef-binary,
  cmake,
  fetchpatch,
  git,
  jdk,
  libGL,
  libx11,
  libxdamage,
  ninja,
  nspr,
  nss,
  python3,
  rsync,
  strip-nondeterminism,
  stripJavaArchivesHook,
  thrift,
  which,
  debugBuild ? false,
}:

let
  buildType = if debugBuild then "Debug" else "Release";
  platform =
    {
      "aarch64-linux" = "linuxarm64";
      "x86_64-linux" = "linux64";
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  arches =
    {
      "linux64" = {
        depsArch = "amd64";
        projectArch = "x86_64";
        targetArch = "x86_64";
      };

      "linuxarm64" = {
        depsArch = "arm64";
        projectArch = "arm64";
        targetArch = "arm64";
      };
    }
    .${platform};
  inherit (arches) depsArch projectArch targetArch;

  # `cef_binary_${CEF_VERSION}_linux64_minimal`, where CEF_VERSION is from $src/CMakeLists.txt
  cef-name = "cef_binary_144.0.15+g72717cf+chromium-144.0.7559.172_${platform}_minimal";

  cef-bin = cef-binary.override {
    version = "144.0.15";
    chromiumVersion = "144.0.7559.172";
    gitRevision = "72717cf";

    srcHashes = {
      aarch64-linux = "sha256-2w2TDj7LGjYeUjpVvojAsHb8HlqG82AwH8Arg0NxREg=";
      x86_64-linux = "sha256-JDlZmIEg9ajjuFOL8qAr6HDVbeu3/Cg21Z57fHryfdc=";
    };
  };

  thrift20 = thrift.overrideAttrs (old: {
    version = "0.20.0";

    src = fetchFromGitHub {
      owner = "apache";
      repo = "thrift";
      tag = "v0.20.0";
      hash = "sha256-cwFTcaNHq8/JJcQxWSelwAGOLvZHoMmjGV3HBumgcWo=";
    };

    patches = (old.patches or [ ]) ++ [
      # Fix build with gcc15
      # https://github.com/apache/thrift/pull/3078
      (fetchpatch {
        hash = "sha256-pWcG6/BepUwc/K6cBs+6d74AWIhZ2/wXvCunb/KyB0s=";
        name = "thrift-add-missing-cstdint-include-gcc15.patch";
        url = "https://github.com/apache/thrift/commit/947ad66940cfbadd9b24ba31d892dfc1142dd330.patch";
      })
    ];

    cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.10"
    ];
  });

in
stdenv.mkDerivation rec {
  pname = "jcef-jetbrains";
  # This is the commit number
  # Currently from the branch: https://github.com/JetBrains/jcef/tree/261
  # Run `git rev-list --count HEAD`
  version = "1207";

  src = fetchFromGitHub {
    inherit rev;
    owner = "jetbrains";
    repo = "jcef";
    hash = "sha256-eYn1T4cRrHeVDSye6FKBv8X3zZPDGFurk6HJG+jPypY=";
  };

  outputs = [
    "out"
  ];

  nativeBuildInputs = [
    cmake
    python3
    jdk
    git
    rsync
    which
    ant
    ninja
    strip-nondeterminism
    stripJavaArchivesHook
    autoPatchelfHook
  ];

  buildInputs = [
    boost
    libGL
    libx11
    libxdamage
    nss
    nspr
    thrift20
  ];

  postBuild = ''
    export JCEF_ROOT_DIR=$(realpath ..)

    # Apply https://github.com/JetBrains/jcef/pull/42
    substituteInPlace ../build.xml \
      --replace-fail \
        '<matches pattern="17*.*" string="''${java.version}"/>' \
        '<javaversion atLeast="17"/>'

    ../tools/compile.sh ${platform} Release
  '';

  installPhase = ''
    runHook preInstall

    export JCEF_ROOT_DIR=$(realpath ..)
    export OUT_NATIVE_DIR=$JCEF_ROOT_DIR/jcef_build/native/${buildType}
    export OUT_REMOTE_DIR=$JCEF_ROOT_DIR/jcef_build/remote/${buildType}
    export JB_TOOLS_DIR=$(realpath ../jb/tools)
    export JB_TOOLS_OS_DIR=$JB_TOOLS_DIR/linux
    export OUT_CLS_DIR=$(realpath ../out/${platform})
    export TARGET_ARCH=${targetArch} DEPS_ARCH=${depsArch}
    export OS=linux
    export JOGAMP_DIR="$JCEF_ROOT_DIR"/third_party/jogamp/jar

    bash "$JB_TOOLS_DIR"/common/create_modules.sh

    mkdir -p $out

    bash "$JB_TOOLS_DIR"/common/create_version_file.sh $out

    cp -r $JCEF_ROOT_DIR/jmods/ $out
    cp -r $JCEF_ROOT_DIR/cef_server/ $out

    runHook postInstall
  '';

  postFixup = ''
    # stripJavaArchivesHook gets rid of jar file timestamps, but not of jmod file timestamps
    # We have to manually call strip-nondeterminism to do this for jmod files too
    find $out -name "*.jmod" -exec strip-nondeterminism --type jmod {} +
  '';

  # Find the hash in tools/buildtools/linux64/clang-format.sha1
  clang-fmt = fetchurl {
    hash = "sha256-4H6FVO9jdZtxH40CSfS+4VESAHgYgYxfCBFSMHdT0hE=";
    url = "https://storage.googleapis.com/chromium-clang-format/dd736afb28430c9782750fc0fd5f0ed497399263";
  };

  configurePhase = ''
    runHook preConfigure

    patchShebangs .

    cp -r ${cef-bin} third_party/cef/${cef-name}
    chmod +w -R third_party/cef/${cef-name}

    sed \
      -e 's|os.path.isdir(os.path.join(path, \x27.git\x27))|True|' \
      -e 's|"%s rev-parse %s" % (git_exe, branch)|"echo '${rev}'"|' \
      -e 's|"%s config --get remote.origin.url" % git_exe|"echo 'https://github.com/jetbrains/jcef'"|' \
      -e 's|"%s rev-list --count %s" % (git_exe, branch)|"echo '${version}'"|' \
      -i tools/git_util.py

    cp ${clang-fmt} tools/buildtools/linux64/clang-format
    chmod +w tools/buildtools/linux64/clang-format

    sed \
      -e 's|include(cmake/vcpkg.cmake)||' \
      -e 's|bring_vcpkg()||' \
      -e 's|vcpkg_install_package(boost-filesystem boost-interprocess thrift)||' \
      -i CMakeLists.txt

    sed -e 's|vcpkg_bring_host_thrift()|set(THRIFT_COMPILER_HOST ${lib.getExe thrift20})|' -i remote/CMakeLists.txt

    mkdir jcef_build
    cd jcef_build

    cmake -G "Ninja" -DPROJECT_ARCH="${projectArch}" -DCMAKE_BUILD_TYPE=${buildType} ..

    runHook postConfigure
  '';

  dontStrip = debugBuild;
  rev = "fa677024a129747bd8cb05447af8918c494e4af7";

  meta = {
    description = "Jetbrains' fork of JCEF";
    homepage = "https://github.com/JetBrains/JCEF";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      aoli-al
    ];

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
