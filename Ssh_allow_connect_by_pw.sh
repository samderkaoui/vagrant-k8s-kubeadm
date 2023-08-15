#!/bin/bash

# Vérifiez si "PasswordAuthentication no" est présent dans le fichier
grep -q "PasswordAuthentication no" /etc/ssh/sshd_config

# Si la dernière commande (grep) a réussi (code de sortie 0), alors on modifie le fichier
if [ $? -eq 0 ]; then
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    echo "Modification effectuée."
else
    echo "La ligne 'PasswordAuthentication no' n'a pas été trouvée ou la modification a déjà été effectuée."
fi

# Redémarrez le service SSH
sudo systemctl restart sshd
