Ce dépôt montre un exemple de playbook faisant appel à un rôle. Ce rôle contient l'arborescence complète et les bases (variables, import de fichiers etc...).
Dans le meme playbook il y a l'exemple d'un playbook simple utilisable directement sans faire appel au role.
Les rôles permettent de découper une configuration complexe en composants plus petits et plus gérables. Cela facilite la maintenance et la compréhension du code.

+ files => permet d'utiliser un fichier ou une archive stockée localement
+ handlers => appel de commande(s)
+ templates => appel de fichier(s) permettant de copier le contenu de ce fichier au format j2 où l'on souhaite
+ defaults/vars => sert à définir les variables présentes soit dans le playbook, soit dans le rôle. Attention : "defaults" est surchargé par "vars", qui lui-même est surchargé par celles définies dans le playbook.