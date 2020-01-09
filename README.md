This repository contains various snippets of code and random notes related to Mathematica

* remote_kernel: configuration files to run a kernel behind a firewall/NAT

* init.m: my .Mathematica/Kernel/init.m

* Attach.wl: package to emulate sage's `%attach` magic

* to have graphic output when running in a terminal use 
```
<<JavaGraphics`
```

* for latex output use the package MaTeX
```
 Needs["PacletManager`"]
 PacletInstall["/tmp/MaTeX-1.7.4.paclet"]
 <<MaTeX`
```
This also works well in conjunction with `JavaGraphics`

* to have a saner readline interface alias math to something like `rlwrap -c -e
  '' -f ~/.Mathematica/local/commands -H ~/.Mathematica/local/history -pgreen -m
  /opt/mathematica/bin/math -rawterm`

Another (free) way to access mathematica is though Jupyter:
* use https://github.com/WolframResearch/WolframLanguageForJupyter for the frontend
and
* WolframEngine https://www.wolfram.com/engine/?source=nav for the backend
