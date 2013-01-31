wget_research_paper
===================
#description
script perl to: 
* easily download the pdf (formated date_title.pdf) 
* access the bibtex citation 

from the publisher websites 

#Require 
curl


#usage 
perl wget_resear_paper PUBLISHER_WEBSITE IDPAPER

#PUBLISHER_WEBSITE
s  Springer

a  ACM

#IDPAPER
the id you find in the URL

for ACM : 

http://dl.acm.org/citation.cfm?id=1136495

the id is 1136495

for Springer :

http://link.springer.com/chapter/10.1007%2F978-3-642-19137-4_4?LI=true

the id is 10.1007%2F978-3-642-19137-4_4

#output
./name_title.pdf
+ 
the first bibtex citation found is printed on the standard output.


