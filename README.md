# Punto Dotfiles Manager (POSIX Version)

[EN](docs/README.en.md)

Ejem... verás... _"Punto"_... _"Dot"_ significa "punto" en inglés... la referenc... mejor olvídalo...

Mi propia solución para el manejo de Dotfiles y Fresh-Installs para macOS y GNU/Linux. **IMPORTANTE:** Para poder usar este repositorio, es necesario que cambies la variable _[$DOTFILES](https://github.com/dievilz/dotfiles)_ por los tuyos o ajustes los míos acorde a tus necesidades al momento de instalar.


## Instalación
**Nota**: Si quieres una mejor experiencia con coloreado y estilos de texto, y además disfrutas de _Solarized Dark_, recomiendo que descargues los esquemas personalizados que hice de [OG Solarized](https://ethanschoonover.com/solarized/) para Terminal.app y iTerm2 que están en la carpeta [/terminal-colorschemes](https://github.com/dievilz/dotfiles/tree/master/home/opt/terminal-colorschemes). Una vez que cambies de perfil, inserta el siguiente código de instalación:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dievilz/punto.sh/master/src/install.sh DOTFILES=<your_repo>)"
```

(_Si por alguna razón el código del script de arriba se parece al instalador de [Oh-My-Zsh](https://github.com/robbyrussell/oh-my-zsh/blob/master/install.sh), es mera coincidencia_ :smiling_imp: )

El script de instalación se encargará de clonar el repositorio, y te dará dos opciones:

* _Bootstrap_: Empezar la instalación completa de los Dotfiles y configuraciones dependiendo de si tu sistema operativo es macOS o GNU/Linux, con [este archivo](bootstrap.sh).

* _Sync_: Sincronizar únicamente los dotfiles que tengas localizados en $DOTFILES, es decir, $HOME/.dotfiles. En este caso, mis _[dotfiles](https://github.com/dievilz/dotfiles/blob/master/sync.sh)_

El proceso será totalmente guiado e irá mostrando siempre el output de las descargas y acciones que se vayan haciendo.


## Ejecución
Sección pendiente...


## Por Hacer
- [ ] Dentro de _[TODO.md](TODO.md)_


## ¿Quieres Contribuir?
- [ ] Ve las pautas en _[CONTRIBUTING.md](CONTRIBUTING.md)_


## Honor a quien honor merece
* **Principalmente a:**
	* [Matthias Vallentin](https://github.com/mavam/dotfiles), de quien me basé para el manejo de mis Dotfiles: [bootstrap.sh](https://github.com/mavam/dotfiles/blob/master/bootstrap) y [sync.sh](https://github.com/mavam/dotfiles/blob/master/dots).
	* [Mathias Bynens](https://github.com/mathiasbynens/dotfiles), y sus famosos macOS defaults: [.macos](https://github.com/mathiasbynens/dotfiles/blob/master/.macos).
	* [Mohammed Ajmal Siddiqui](https://github.com/ajmalsiddiqui/dotfiles), quien me motivó a realizar mi propia solución para mis Dotfiles con sus [artículos](https://ajmalsiddiqui.me/blog/dive-into-dotfiles-part-2/).
