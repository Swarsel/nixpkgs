{
  lib,
  fetchFromGitHub,
  buildPecl,
  fetchpatch,
  file,
  gnupg,
  gpgme,
  php,
}:

let
  version = "1.5.4";
in
buildPecl {
  inherit version;
  pname = "gnupg";

  src = fetchFromGitHub {
    owner = "php-gnupg";
    repo = "php-gnupg";
    rev = "gnupg-${version}";
    hash = "sha256-g9w0v9qc/Q5qjB9/ekZyheQ1ClIEqMEoBc32nGWhXYA=";
    fetchSubmodules = true;
  };

  patches = [
    # https://github.com/php-gnupg/php-gnupg/issues/62
    (fetchpatch {
      hash = "sha256-fJ/H1tbwMuLUpdWe0+oPyzhBFAsjG2QzmZSiuIsMekY=";
      name = "fix-test-typos.patch";
      url = "https://github.com/php-gnupg/php-gnupg/commit/4b9160b94df1d831d7bcc4f980cb8969d9ab5c11.patch";
    })
    (fetchpatch {
      hash = "sha256-/c+cxfAj3Cg7m2+sFiHWQr4R9atPypQuAUVyAOI8ZeM=";
      name = "fix-clearsign-newline-test.patch";
      url = "https://github.com/php-gnupg/php-gnupg/commit/6eda368b55044343349a8e76f6beda3ad54660dc.patch";
    })
  ];

  buildInputs = [ gpgme ];

  postConfigure = ''
    substituteInPlace Makefile \
      --replace-fail 'run-tests.php' 'run-tests.php -q --offline'
    substituteInPlace tests/gnupg_res_init_file_name.phpt \
      --replace-fail '/usr/bin/gpg' '${gnupg}/bin/gpg' \
      --replace-fail 'string(12)' 'string(${toString (lib.stringLength "${gnupg}/bin/gpg")})'
    substituteInPlace tests/gnupg_oo_init_file_name.phpt \
      --replace-fail '/usr/bin/gpg' '${gnupg}/bin/gpg' \
      --replace-fail 'string(12)' 'string(${toString (lib.stringLength "${gnupg}/bin/gpg")})'
    # Suppress warnings from unlinking socket files that gpg-agent may have
    # already removed during shutdown (TOCTOU race in cleanup code).
    substituteInPlace tests/gnupgt.inc \
      --replace-fail 'unlink(' '@unlink('
  '';

  doCheck = true;
  nativeCheckInputs = [ gnupg ];

  postPhpize = ''
    substituteInPlace configure \
      --replace-fail '/usr/bin/file' '${file}/bin/file' \
      --replace-fail 'SEARCH_PATH="/usr/local /usr /opt /opt/homebrew"' 'SEARCH_PATH="${gpgme.dev}"'
  '';

  meta = {
    description = "PHP wrapper for GpgME library that provides access to GnuPG";
    homepage = "https://pecl.php.net/package/gnupg";
    changelog = "https://github.com/php-gnupg/php-gnupg/releases/tag/gnupg-${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ taikx4 ];
    broken = lib.versionOlder php.version "8.1"; # Broken on PHP older than 8.1.
    teams = [ lib.teams.php ];
  };
}
