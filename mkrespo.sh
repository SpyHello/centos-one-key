#!/usr/bin/bash

cd ~
mkdir $1
cd $1
git --bare init

cd hooks

echo "#!/usr/bin/bash
MY_WORKSPACE=/home/srv/webroot/${1}
GIT_DIR=\${MY_WORKSPACE}/.git
GIT_WORK_TREE=\${MY_WORKSPACE}
cd \${MY_WORKSPACE}
git pull origin master


" >>  post-receive
chmod a+x post-receive

