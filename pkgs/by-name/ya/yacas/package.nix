{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  fetchpatch,
  gtest,
  jsoncpp,
  openjdk,
  openssl,
  perl,
  zmqpp,
  enableJava ? false,
  enableJupyter ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yacas";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "grzegorzmazur";
    repo = "yacas";
    rev = "v${finalAttrs.version}";
    sha256 = "0dqgqvsb6ggr8jb3ngf0jwfkn6xwj2knhmvqyzx3amc74yd3ckqx";
  };

  patches = [
    # upstream issue: https://github.com/grzegorzmazur/yacas/issues/340
    # Upstream patch which doesn't apply on 1.9.1 is:
    # https://github.com/grzegorzmazur/yacas/pull/342
    ./jsoncpp-fix-include.patch
    # Fixes testing - https://github.com/grzegorzmazur/yacas/issues/339
    # PR: https://github.com/grzegorzmazur/yacas/pull/343
    (fetchpatch {
      sha256 = "sha256-aPO5T8iYNkGtF8j12YxNJyUPJJPKrXje1DmfCPt317A=";
      url = "https://github.com/grzegorzmazur/yacas/commit/8bc22d517ecfdde3ac94800dc8506f5405564d48.patch";
    })
  ];

  # jsoncpp 1.9.7 rejects std::sub_match in Json::Value::operator[].
  postPatch = ''
    substituteInPlace cyacas/yacas-kernel/src/yacas_kernel.cpp \
      --replace-fail 'content_data[m[2]] = base64_encode(img);' \
                     'content_data[m[2].str()] = base64_encode(img);'
  '';

  nativeBuildInputs = [
    cmake
    # Perl is only for the documentation
    perl
  ]
  ++ lib.optionals enableJava [
    openjdk
  ];

  buildInputs = [
  ]
  ++ lib.optionals enableJupyter [
    boost
    jsoncpp
    openssl
    zmqpp
  ];

  cmakeFlags = [
    "-DENABLE_CYACAS_GUI=OFF"
    "-DENABLE_CYACAS_KERNEL=${if enableJupyter then "ON" else "OFF"}"
    "-DENABLE_JYACAS=${if enableJava then "ON" else "OFF"}"
    "-DENABLE_CYACAS_UNIT_TESTS=ON"
  ];

  doCheck = true;

  nativeCheckInputs = [
    gtest
  ];

  preCheck = ''
    patchShebangs ../tests/test-yacas
  '';

  hardeningDisable = [ "format" ];

  meta = {
    description = "Easy to use, general purpose Computer Algebra System, optionally with GUI";
    homepage = "http://www.yacas.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
  };
})
