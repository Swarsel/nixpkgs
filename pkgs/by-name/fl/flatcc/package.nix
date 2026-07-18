{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  nix-update-script,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flatcc";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "dvidelabs";
    repo = "flatcc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0/IZ7eX6b4PTnlSSdoOH0FsORGK9hrLr1zlr/IHsJFQ=";
  };

  patches = [
    # Fix builds on clang15. Remove post-0.6.1.
    (fetchpatch {
      hash = "sha256-z2HSxNXerDFKtMGu6/vnzGRlqfz476bFMjg4DVfbObQ";
      name = "clang15fixes.patch";
      url = "https://github.com/dvidelabs/flatcc/commit/5885e50f88248bc7ed398880c887ab23db89f05a.patch";
    })
    # Bump cmake to 2.8.12, required fox 3.16 patch
    (fetchpatch {
      hash = "sha256-eRlkQw+YGRgCUjrlYB3I8w+/cPuJhgEfNUW/+TZhHlI=";
      name = "bump-cmake-version.patch";
      url = "https://github.com/dvidelabs/flatcc/commit/5f07eda43caabd81a2bfa2857af0e3f26dc6d4ee.patch?full_index=1";
    })
    # Bump min. CMake to 3.16 and fix custom build rules
    (fetchpatch {
      excludes = [
        "README.md"
        "CHANGELOG.md"
        "test/doublevec_test/CMakeLists.txt"
        "test/monster_test_cpp/CMakeLists.txt"
      ];

      hash = "sha256-ORDby2LRRQdFrNc1owHKxo0TfMIxISj5SuD5oqvDFFo=";
      name = "fix-cmake-version.patch";
      url = "https://github.com/dvidelabs/flatcc/commit/385c27b23236dff7ad4fa35c59fd4f9143dcaae6.patch?full_index=1";
    })
  ]
  ++ lib.optionals stdenv.cc.isClang [
    # Fix clang compilation
    # https://github.com/dvidelabs/flatcc/pull/273
    (fetchpatch {
      hash = "sha256-kGupiMVa2r+hsQnknatRK+EfscNjJD0T75NY1ELkJ5U=";
      name = "fix-c23-fallthrough.patch";
      url = "https://github.com/dvidelabs/flatcc/commit/7c199e3b191a6f714694035f1eba40112e71675c.patch";
    })

    # Fix implicit int conversion on negation for int8/int16
    # https://github.com/dvidelabs/flatcc/commit/5df663837c93eb7516890c27574dcc4b042890cb
    (fetchpatch {
      excludes = [ "CHANGELOG.md" ];
      hash = "sha256-pntpatUDkZbj5pEViA8jDvXP+9KNdfhUDQCUd598Lxg=";
      name = "fix-pprintint-implicit-int-conversion.patch";
      url = "https://github.com/dvidelabs/flatcc/commit/5df663837c93eb7516890c27574dcc4b042890cb.patch";
    })
  ];

  postPatch = ''
    substituteInPlace include/flatcc/portable/grisu3_print.h \
      --replace-fail \
        'static char hexdigits[16] = "0123456789ABCDEF";' \
        "static char hexdigits[16] = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};"
  '';

  strictDeps = true;
  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    (lib.cmakeBool "FLATCC_INSTALL" true)
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "FlatBuffers Compiler and Library in C for C";
    homepage = "https://github.com/dvidelabs/flatcc";
    changelog = "https://github.com/dvidelabs/flatcc/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = [ lib.licenses.asl20 ];
    maintainers = with lib.maintainers; [ onny ];
    mainProgram = "flatcc";
  };
})
