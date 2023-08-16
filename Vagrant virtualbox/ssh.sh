#!/bin/bash

# Vérifiez si "#PasswordAuthentication no" ou "#PasswordAuthentication yes" est présent dans le fichier
if grep -q "^#PasswordAuthentication no" /etc/ssh/sshd_config; then
    sed -i 's/^#PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    echo "Modification effectuée pour remplacer '#PasswordAuthentication no' par 'PasswordAuthentication yes'."
elif grep -q "^#PasswordAuthentication yes" /etc/ssh/sshd_config; then
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    echo "Modification effectuée pour remplacer '#PasswordAuthentication yes' par 'PasswordAuthentication yes2'."
else
    echo "Aucune des lignes spécifiées n'a été trouvée ou la modification a déjà été effectuée."
fi

# Redémarrez le service SSH
sudo systemctl restart sshd
