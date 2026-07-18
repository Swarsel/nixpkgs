{
  lib,
  stdenv,
  fetchFromGitHub,
  libnotify,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tg";
  version = "0.22.0";

  src = fetchFromGitHub {
    owner = "paul-nameless";
    repo = "tg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qzqYkksocR86QFmP75ZE93kMSVmdel+OTxPgt9uZHLI=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "poetry-core>=1.0.0,<2.0.0" "poetry-core"
  ''
  + lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    # Fix notifications on platforms other than darwin by providing notify-send
    sed -i 's|^NOTIFY_CMD = .*|NOTIFY_CMD = "${libnotify}/bin/notify-send {title} {message} -i {icon_path}"|' tg/config.py
  '';

  doCheck = false; # No tests
  build-system = [ python3Packages.poetry-core ];

  dependencies = with python3Packages; [
    mailcap-fix
    python-telegram
  ];

  pyproject = true;

  meta = {
    description = "Terminal client for telegram";
    homepage = "https://github.com/paul-nameless/tg";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ sikmir ];
    mainProgram = "tg";
  };
})
