{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ac-library";
  version = "1.6";

  src = fetchFromGitHub {
    owner = "atcoder";
    repo = "ac-library";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1wwzN/JPS6daj1vDFuEN5z20tMdLfMvEKti0sxCVlHA=";
    fetchSubmodules = true;
  };

  outputs = [
    "dev"
    "out"
  ];

  patches = [
    # Fix type_traits_test assumptions about char signedness on platforms
    # where char is unsigned by default (e.g. aarch64-linux).
    # Reported upstream: https://github.com/atcoder/ac-library/issues/191
    ./fix-char-signedness-tests.patch
  ];

  buildInputs = [
    python3
  ];

  env = {
    NIX_CFLAGS_COMPILE = toString [
      "-Wno-error=array-bounds"
    ];
  };

  installPhase = ''
    runHook preInstall

    install -d $dev/include/atcoder
    install -m644 atcoder/* $dev/include/atcoder/
    install -Dm755 expander.py $out/bin/expander

    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    python3.pkgs.pytest
    cmake
  ];

  installCheckPhase = ''
    runHook preInstallCheck

    substituteInPlace test/test_expander.py \
      --replace-fail "g++" "$CXX"
    python -m pytest --ignore-glob='test/unittest/googletest/*'

    pushd test/unittest
    mkdir build
    cd build
    cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_STANDARD=$STDCXX
    make
    ctest -VV
    popd

    runHook postInstallCheck
  '';

  dontUseCmakeConfigure = true;
  # We don't need -fno-strict-overflow because it will break UBSanitize's overflow check especially when the operation number is static definded.
  hardeningDisable = [ "strictoverflow" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Official library of AtCoder";
    homepage = "https://github.com/atcoder/ac-library";
    changelog = "https://github.com/atcoder/ac-library/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.all;
  };
})
