{
  lib,
  stdenv,
  fetchFromGitLab,
  argp-standalone,
  autoreconfHook,
  fetchpatch,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "iucode-tool";
  version = "2.3.1";

  src = fetchFromGitLab {
    owner = "iucode-tool";
    repo = "iucode-tool";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ajDpywgyerbvgern0b8T4jJUWisMzwrhwKO1g7iOtBE=";
  };

  patches = [
    # build fix for musl libc, pending upstream review
    # https://gitlab.com/iucode-tool/iucode-tool/-/merge_requests/4
    (fetchpatch {
      hash = "sha256-BxYrXALpZFyJtFrgU5jFmzd1dIMPmpNgvYArgkwGt/w=";
      url = "https://gitlab.com/iucode-tool/iucode-tool/-/commit/fda4aaa4727601dbe817fac001f234c19420351a.patch";
    })
  ];

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = lib.optional stdenv.hostPlatform.isMusl argp-standalone;
  enableParallelBuilding = true;

  meta = {
    description = "Intel® 64 and IA-32 processor microcode tool";
    homepage = "https://gitlab.com/iucode-tool/iucode-tool";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ peterhoeg ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];

    mainProgram = "iucode_tool";
  };
})
