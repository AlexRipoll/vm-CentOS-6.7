sudo yum -y install man
sudo yum -y groupinstall 'Development Tools'
sudo yum -y install gmp-devel
sudo yum -y install python-devel
echo "******************************************"
echo "|              Fix Languaje              |"
echo "******************************************"
grep -q -F 'LANG=en_US.utf-8' /etc/environment || echo 'LANG=en_US.utf-8' >> /etc/environment
grep -q -F 'LC_ALL=en_US.utf-8' /etc/environment || echo 'LC_ALL=en_US.utf-8' >> /etc/environment
echo "Fix complete"

#remi repo 7.1
sudo yum -y install yum-utils

echo "******************************************"
echo "|     Verificando Instalación de PIP     |"
echo "******************************************"

if ! pip --version | grep pip;
then
    curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
    sudo python get-pip.py
    pip --version
else
    echo "-> Ansible already Installed!"
    pip --version
fi

echo "******************************************"
echo "|   Verificando Instalación de Ansible   |"
echo "******************************************"

if ! ansible --version | grep ansible;
then
    sudo pip install 'ansible==2.3.3.0' 
    ansible --version
else
    echo "-> Ansible already Installed!"
    ansible --version
fi


# Install Ansible Galaxy modules
# To review in furure: http://docs.ansible.com/ansible/galaxy.html#id12
echo "******************************************"
echo "|  Installing Ansibe Galaxy Modules      |"
echo "******************************************"

roles_list[0]='geerlingguy.ntp,1.5.2'
roles_list[1]='geerlingguy.repo-remi,1.2.0'
roles_list[2]='geerlingguy.repo-epel,1.2.2'
roles_list[3]='geerlingguy.firewall,2.3.0'
roles_list[4]='geerlingguy.apache,2.1.1'
roles_list[5]='geerlingguy.php-versions,2.0.0'
roles_list[6]='geerlingguy.php,3.5.0'
roles_list[7]='geerlingguy.apache-php-fpm,1.0.2'
roles_list[8]='geerlingguy.composer,1.6.1'
roles_list[9]='geerlingguy.mysql,2.8.0'
roles_list[10]='geerlingguy.php-mysql,2.0.1'
roles_list[11]='geerlingguy.git,1.4.0'


for role_and_version in "${roles_list[@]}"
do
    role_and_version_for_grep="${role_and_version/,/, }"

    if ! sudo ansible-galaxy list | grep -qw "$role_and_version_for_grep";
    then
            echo "Installing ${role_and_version}"
            sudo ansible-galaxy -f install $role_and_version
   else
        echo "Already installed ${role_and_version}"
    fi
done

echo "Disable permanently SE Linux in apache"
sudo setenforce 0;

sed -i --follow-symlinks 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux && cat /etc/sysconfig/selinux

# Execute Ansible
echo "-> Execute Ansible"
ansible-playbook /ansible/playbook.yml -i /ansible/inventories/hosts --connection=local


