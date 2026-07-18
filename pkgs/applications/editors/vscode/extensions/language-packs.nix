{
  lib,
  nix-update,
  vscode-extension-update,
  vscode-utils,
  writeShellScript,
}:

with vscode-utils;

let

  buildVscodeLanguagePack =
    {
      hash,
      language,
      version ? "1.110.2026041514",
    }:
    buildVscodeMarketplaceExtension {
      mktplcRef = {
        inherit version hash;
        name = "vscode-language-pack-${language}";
        publisher = "MS-CEINTL";
      };

      passthru.updateScript = lib.optionalAttrs (language == "fr") (
        writeShellScript "vscode-language-packs-update-script" ''
          ${lib.getExe vscode-extension-update} vscode-extensions.ms-ceintl.vscode-language-pack-fr --override-filename "pkgs/applications/editors/vscode/extensions/language-packs.nix"
          for lang in cs de es it ja ko pl pt-br qps-ploc ru tr zh-hans zh-hant; do
            ${lib.getExe nix-update} --version "skip" "vscode-extensions.ms-ceintl.vscode-language-pack-$lang" --override-filename "pkgs/applications/editors/vscode/extensions/language-packs.nix"
          done
        ''
      );

      meta = {
        license = lib.licenses.mit;
      };
    };
in

# See list of core language packs at https://github.com/Microsoft/vscode-loc
{
  # Czech
  vscode-language-pack-cs = buildVscodeLanguagePack {
    hash = "sha256-A/87U9aR4OPUIm6lDwQNHQFUv/wWsyh6rqFnG15VzN4=";
    language = "cs";
  };

  # German
  vscode-language-pack-de = buildVscodeLanguagePack {
    hash = "sha256-8la5VVAq5+62/1biCeGqpA9ohvI7NEeH2M1Q4e4KvQI=";
    language = "de";
  };

  # Spanish
  vscode-language-pack-es = buildVscodeLanguagePack {
    hash = "sha256-XugtbAlrHH73AEAljJ6IdfXvnTWhxVFJJg09YzJbM5o=";
    language = "es";
  };

  # French
  vscode-language-pack-fr = buildVscodeLanguagePack {
    hash = "sha256-k+wpnvLqp4blMWKuHf9IAyOZLExvekd4vYjzMiXQAhw=";
    language = "fr";
  };

  # Italian
  vscode-language-pack-it = buildVscodeLanguagePack {
    hash = "sha256-gKdW15gYsoAdBPJBYVvYMmgUW2fhBAZRLLKC9uPjmSk=";
    language = "it";
  };

  # Japanese
  vscode-language-pack-ja = buildVscodeLanguagePack {
    hash = "sha256-RqO+OO4wzEc3UQYoWPweXLYMKjNLgwobWzrulREbCmU=";
    language = "ja";
  };

  # Korean
  vscode-language-pack-ko = buildVscodeLanguagePack {
    hash = "sha256-QQRqctsXxEwGGTtc+o+CVzxw+Ec/ba4j3YXoZoalUQY=";
    language = "ko";
  };

  # Polish
  vscode-language-pack-pl = buildVscodeLanguagePack {
    hash = "sha256-fJCNNoYLFhRIUbAFKiiAfc43V8aNKSu/ORNAzoqTTGw=";
    language = "pl";
  };

  # Portuguese (Brazil)
  vscode-language-pack-pt-br = buildVscodeLanguagePack {
    hash = "sha256-PUGEzmxWonHPl5i96dsFguWjKZPf/FVV2bzYBr63Xs8=";
    language = "pt-BR";
  };

  # Pseudo Language
  vscode-language-pack-qps-ploc = buildVscodeLanguagePack {
    hash = "sha256-zmnplZFsQQYuTp9TiBiuuPPcffmFHkIGcy8sn6dDt5M=";
    language = "qps-ploc";
  };

  # Russian
  vscode-language-pack-ru = buildVscodeLanguagePack {
    hash = "sha256-YO6uvr1QHvq8HTlPW2ebMADsfqd5acmNnXphDaDrBew=";
    language = "ru";
  };

  # Turkish
  vscode-language-pack-tr = buildVscodeLanguagePack {
    hash = "sha256-Hs8LAvINGRO06CQEjSRee1ryT3X31jsy9lynghMzu7k=";
    language = "tr";
  };

  # Chinese (Simplified)
  vscode-language-pack-zh-hans = buildVscodeLanguagePack {
    hash = "sha256-h9wvZX1/3raPIthq3L1iD2GyYcUON9IiqriAV6kJlSQ=";
    language = "zh-hans";
  };

  # Chinese (Traditional)
  vscode-language-pack-zh-hant = buildVscodeLanguagePack {
    hash = "sha256-TO4o3/+4HIElQA37O19u9Ul6VZ8IKCuMElEN9C8kUGo=";
    language = "zh-hant";
  };
}
