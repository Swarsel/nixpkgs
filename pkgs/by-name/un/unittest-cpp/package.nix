{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "unittest-cpp";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "unittest-cpp";
    repo = "unittest-cpp";
    rev = "v${finalAttrs.version}";
    sha256 = "0sxb3835nly1jxn071f59fwbdzmqi74j040r81fanxyw3s1azw0i";
  };

  patches = [
    # GCC12 Patch
    (fetchpatch {
      hash = "sha256-xyhV2VBelw/uktUXSZ3JBxgG+8/Mout/JiXEZVV2+2Y=";
      url = "https://github.com/unittest-cpp/unittest-cpp/pull/185/commits/f361c2a1034c02ba8059648f9a04662d6e2b5553.patch";
    })
  ];

  # Fix the build with CMake 4.
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail \
        'cmake_minimum_required(VERSION 2.8.1)' \
        'cmake_minimum_required(VERSION 3.10)'
  '';

  nativeBuildInputs = [ cmake ];
  # Fix 'Version:' setting in .pc file. TODO: remove once upstreamed:
  #     https://github.com/unittest-cpp/unittest-cpp/pull/188
  cmakeFlags = [ "-DPACKAGE_VERSION=${finalAttrs.version}" ];
  doCheck = false;

  meta = {
    description = "Lightweight unit testing framework for C++";
    homepage = "https://github.com/unittest-cpp/unittest-cpp";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
