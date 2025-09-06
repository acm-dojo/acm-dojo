{ pkgs }:

let
  pythonPackages = ps: with ps; [
    rich
  ];

  pythonEnv = pkgs.python3.withPackages pythonPackages;

  tools = with pkgs; {
    compression = [ zip unzip gzip gnutar ];

    system = [ htop git neofetch ];

    editors = [ vim neovim nano ];

    terminal = [ tmux screen ];
  };

in
{
  packages = with pkgs;
    [ (lib.hiPrio pythonEnv) ]
    ++ tools.compression
    ++ tools.system
    ++ tools.editors
    ++ tools.terminal
}
