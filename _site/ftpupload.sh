#!/bin/bash
# HOST='ftp.mattarcher.co.uk'
# ftp $HOST << EOT
# prompt no
# lcd /home/matt/projects/web/cv_mattarcher.co.uk/_site/
# cd public_html
# mput *
# ls 
# EOT
jekyll build
ncftp mattarcher << EOT
cd public_html
lcd /home/matt/projects/web/cv_mattarcher.co.uk/_site/
put -R . 
EOT

# user matt@mattarcher.co.uk
# pass 13holly24
