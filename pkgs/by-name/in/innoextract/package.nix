{
  lib,
  stdenv,
  fetchFromGitHub,
  boost188,
  cmake,
  libiconv,
  makeWrapper,
  unstableGitUpdater,
  xz,
  unar ? null,
  withGog ? false,
}:

stdenv.mkDerivation {
  pname = "innoextract";
  version = "1.9-unstable-2025-02-06";

  src = fetchFromGitHub {
    owner = "dscharrer";
    repo = "innoextract";
    rev = "6e9e34ed0876014fdb46e684103ef8c3605e382e";
    hash = "sha256-bgACPDo1phjIiwi336JEB1UAJKyL2NmCVOhyZxBFLJo=";
  };

  strictDeps = true;

  # Python is reported as missing during the build, however
  # including Python does not change the output.
  nativeBuildInputs = [
    cmake
    makeWrapper
  ];

  buildInputs = [
    xz
    # pin to oplder boost188 as boost189
    # fails to find cmake bits: https://github.com/dscharrer/innoextract/pull/199
    boost188
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];

  # we need unar to for multi-archive extraction
  postFixup = lib.optionalString withGog ''
    wrapProgram $out/bin/innoextract \
      --prefix PATH : ${lib.makeBinPath [ unar ]}
  '';

  # use unstable as latest release does not yet support cmake-4
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Tool to unpack installers created by Inno Setup";
    homepage = "https://constexpr.org/innoextract/";
    license = lib.licenses.zlib;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "innoextract";
  };
}
