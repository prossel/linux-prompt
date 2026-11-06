# Linux Prompt — Starship personnalisé

Un prompt Bash/Zsh à deux lignes, coloré par machine et enrichi avec les informations Git.

## Installation locale

```sh
sh install.sh '#38BDF8'
```

## Installation depuis ton dépôt GitHub

Après avoir publié `install.sh` à la racine d'un dépôt public `linux-prompt` :

```sh
curl -fsSL https://raw.githubusercontent.com/prossel/linux-prompt/main/install.sh | sh -s -- '#38BDF8'
```

Exemples de couleurs : `#38BDF8` (bleu), `#34D399` (vert), `#FBBF24` (orange), `#C4B5FD` (violet), `#FB7185` (rose).

## Fonctionnalités

- Utilisateur et nom du serveur toujours visibles.
- Répertoire actuel, branche et état Git.
- Durée des commandes de plus de 2 secondes.
- Symbole rouge si la commande précédente a échoué.
- Espacement entre blocs de commandes.
- Sans Nerd Font obligatoire.
- Ajout non destructif des blocs d'initialisation à `~/.bashrc` et `~/.zshrc`.
- Si `~/.bash_profile` ou `~/.profile` existe sans charger `~/.bashrc`, l'installateur propose de l'ajouter.
- Installation de Starship localement sous `~/.local/bin`, sans sudo.
- Relance de l'installateur avec une autre couleur pour changer l'accent.

## Notes

L'installateur écrit `~/.config/starship.toml`. S'il trouve un fichier Starship non géré par cet installateur, il le sauvegarde avec un suffixe horodaté avant de le remplacer. Les couleurs de Git et du répertoire restent fixes pour conserver leur signification, tandis que l'accent change selon la machine.

Le compte root et un compte standard ont chacun leur propre configuration; lance l'installation sous le compte correspondant. Pour la sécurité, inspecte le script et épingle une révision Git avant de le déployer massivement.

L'installation utilise l'installateur officiel de Starship, avec un téléchargement HTTPS. Il faut `curl`, et Git doit être installé pour afficher les informations Git.
