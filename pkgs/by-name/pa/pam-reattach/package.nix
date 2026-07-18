{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  openpam,
}:

stdenv.mkDerivation rec {
  pname = "pam_reattach";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "fabianishere";
    repo = "pam_reattach";
    rev = "v${version}";
    sha256 = "1k77kxqszdwgrb50w7algj22pb4fy5b9649cjb08zq9fqrzxcbz7";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ openpam ];

  cmakeFlags = [
    "-DCMAKE_OSX_ARCHITECTURES=${stdenv.hostPlatform.darwinArch}"
    "-DENABLE_CLI=ON"
  ];

  meta = {
    description = "Reattach to the user's GUI session on macOS during authentication (for Touch ID support in tmux)";
    homepage = "https://github.com/fabianishere/pam_reattach";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lockejan ];
    platforms = lib.platforms.darwin;
  };
}
