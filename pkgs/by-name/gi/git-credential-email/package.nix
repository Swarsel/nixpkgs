{
  lib,
  fetchFromGitHub,
  python3Packages,
  description ? "Git credential helpers for Microsoft Outlook, Gmail, Yahoo, AOL and Proton Mail accounts",
  license ? with lib.licenses; [
    asl20
    gpl3Only
  ],
  pname ? "git-credential-email",
  scripts ? [
    "git-credential-aol"
    "git-credential-gmail"
    "git-credential-outlook"
    "git-credential-yahoo"
    "git-msgraph"
    "git-protonmail"
  ],
  withOpencv ? false,
  withPyqt6 ? builtins.elem "git-protonmail" scripts,
  withQrcode ? true,
}:

let
  withProtonmail = builtins.elem "git-protonmail" scripts;
in
python3Packages.buildPythonApplication (finalAttrs: {
  inherit pname;
  version = "5.6.2";

  src = fetchFromGitHub {
    owner = "AdityaGarg8";
    repo = "git-credential-email";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pW13tOPOyS5EorR1C/WEpJpu2ilCA4s8N7GkXoyPv7U=";
  };

  installPhase = ''
    install -D -t $out/bin ${lib.concatStringsSep " " scripts}
  '';

  dependencies =
    with python3Packages;
    [
      keyring
      requests
    ]
    ++ lib.optionals withPyqt6 [ pyqt6 ]
    ++ lib.optionals withQrcode [ qrcode ]
    ++ lib.optionals withProtonmail [
      bcrypt
      cryptography
      pgpy
      requests-toolbelt
      typing-extensions
    ]
    ++ lib.optionals (withProtonmail && withOpencv) [ opencv4 ];

  pyproject = false;

  meta = {
    inherit description license;
    homepage = "https://github.com/AdityaGarg8/git-credential-email";
    changelog = "https://github.com/AdityaGarg8/git-credential-email/releases/tag/${finalAttrs.src.tag}";
    maintainers = with lib.maintainers; [ sephalon ];
  };
})
