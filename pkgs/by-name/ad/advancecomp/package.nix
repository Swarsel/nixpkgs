{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "advancecomp";
  version = "2.6";

  src = fetchFromGitHub {
    owner = "amadvance";
    repo = "advancecomp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MwXdXT/ZEvTcYV4DjhCUFflrPKBFu0fk5PmaWt4MMOU=";
  };

  # autover.sh relies on 'git describe', which obviously doesn't work as we're not cloning
  # the full git repo. so we have to put the version number in `.version`, otherwise
  # the binaries get built reporting "none" as their version number.
  postPatch = ''
    echo "${finalAttrs.version}" >.version
  '';

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ zlib ];

  meta = {
    description = "Set of tools to optimize deflate-compressed files";
    homepage = "https://github.com/amadvance/advancecomp";
    changelog = "https://github.com/amadvance/advancecomp/blob/v${finalAttrs.version}/HISTORY";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
