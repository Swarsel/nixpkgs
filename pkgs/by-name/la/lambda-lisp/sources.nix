let
  lambdaLispVersion = "2022-08-18";
  blcVersion = "2";
  # Archive of "https://justine.lol/lambda/";
  justineLolArchive = "https://web.archive.org/web/20230614065521if_/https://justine.lol/lambda/";
in
{ fetchurl, fetchFromGitHub }:
{
  inherit blcVersion;
  inherit lambdaLispVersion;

  src = fetchFromGitHub {
    owner = "woodrush";
    repo = "lambdalisp";
    rev = "2119cffed1ab2005f08ab3cfca92028270f08725";
    hash = "sha256-ml2xQ8s8sux+6GwTw8mID3PEOcH6hn8tyc/UI5tFaO0=";
  };

  blcSrc = fetchurl {
    hash = "sha256-qt7vDtn9WvDoBaLESCyyscA0u74914e8ZKhLiUAN52A=";
    url = "${justineLolArchive}Blc.S?v=${blcVersion}";
  };

  # needed later
  clambSrc = fetchFromGitHub {
    hash = "sha256-1lGg2NBoxAKDCSnnPn19r/hwBC5paAKUnlcsUv3dpNY=";
    owner = "irori";
    repo = "clamb";
    rev = "44c1208697f394e22857195be5ea73bfdd48ebd1";
  };

  flatSrc = fetchurl {
    hash = "sha256-HxX+10rV86zPv+UtF+n72obtz3DosWLMIab+uskxIjA=";
    url = "${justineLolArchive}flat.lds";
  };

  # needed later
  lazykSrc = fetchFromGitHub {
    hash = "sha256-1lGg2NBoxAKDCSnnPn19r/hwBC5paAKUnlcsUv3dpNY=";
    owner = "irori";
    repo = "lazyk";
    rev = "5edb0b834d0af5f7413c484eb3795d47ec2e3894";
  };

  uniCSrc = fetchFromGitHub {
    hash = "sha256-JmbqQp2kkkkkkkkSWQmG3uBxdgyIu4r2Ch8bBGyQ4H4=";
    owner = "tromp";
    repo = "tromp.github.io";
    rev = "b4de12e566c1fb0fa3f3babe89bac885f4c966a4";
  };
}
