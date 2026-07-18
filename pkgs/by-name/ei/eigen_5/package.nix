{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  # nativeBuildInputs
  doxygen,
  fetchpatch,
  graphviz,
  nix-update-script,
  withDoc ? true, # upstream disable for cross, even if it seems to build fine
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "eigen";
  version = "5.0.1";

  src = fetchFromGitLab {
    owner = "libeigen";
    repo = "eigen";
    tag = finalAttrs.version;
    hash = "sha256-8TW1MUXt2gWJmu5YbUWhdvzNBiJ/KIVwIRf2XuVZeqo=";
  };

  outputs = [
    "out"
  ]
  ++ lib.optional withDoc "doc";

  patches = [
    # merged upstream
    (fetchpatch {
      hash = "sha256-/FSXhY+/ZRKfE/aIDAgP+DoNCtH8ikUItYGmfo+QH0E=";
      name = "fix-doc.patch";
      url = "https://gitlab.com/libeigen/eigen/-/commit/976f15ebca3f486902c3da4c98b8f92c3c4ed7a4.diff";
    })
  ];

  nativeBuildInputs = [
    cmake
  ]
  ++ lib.optionals withDoc [
    doxygen
    graphviz
  ];

  cmakeFlags = [
    (lib.cmakeBool "EIGEN_BUILD_DOC" withDoc)
  ];

  # tests are super long and mostly flaky
  doCheck = false;

  postInstall = lib.optionalString withDoc ''
    # Fontconfig error: No writable cache directories
    export XDG_CACHE_HOME="$(mktemp -d)"

    cmake --build . -t install-doc
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "C++ template library for linear algebra: vectors, matrices, and related algorithms";
    homepage = "https://eigen.tuxfamily.org";
    changelog = "https://gitlab.com/libeigen/eigen/-/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.lgpl3Plus;

    maintainers = with lib.maintainers; [
      nim65s
      pbsds
      raskin
    ];

    platforms = lib.platforms.unix;
  };
})
