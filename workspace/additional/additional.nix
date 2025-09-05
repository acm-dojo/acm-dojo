{ pkgs }:

let
  ghidra = import ./ghidra.nix { inherit pkgs; };
  burpsuite = import ./burpsuite.nix { inherit pkgs; };
  bata24-gef = import ./bata24-gef.nix { inherit pkgs; };

  pythonPackages = ps: with ps; [
    angr
    asteval
    flask
    ipython
    jupyter
    psutil
    pwntools
    requests
    rich
  ];

  pythonEnv = pkgs.python3.withPackages pythonPackages;

  tools = with pkgs; {
    build = [ gcc gnumake cmake git ];

    compression = [ zip unzip gzip gnutar ];

    system = [ htop rsync openssh nftables git neofetch ];

    editors = [ vim neovim emacs nano gedit ];

    terminal = [ tmux screen kitty.terminfo ];

    # network = [ netcat-openbsd tcpdump wireshark termshark nmap burpsuite ];

    # debugging = [ strace ltrace gdb pwndbg gef bata24-gef ];
  };

in
{
  packages = with pkgs;
    [ (lib.hiPrio pythonEnv) ]
    ++ tools.build
    ++ tools.compression
    ++ tools.system
    ++ tools.editors
    ++ tools.terminal
}
