FROM kristophjunge/mediawiki:$MW_VERSION

RUN apt-get install -y wget

# COPY LocalSettings.php /var/www/mediawiki/

WORKDIR /var/www/mediawiki/
RUN cd extensions ; git clone https://github.com/mathiasertl/CustomNavBlocks.git
RUN cd skins ; wget https://extdist.wmflabs.org/dist/skins/Metrolook-REL1_29-3795b1d.tar.gz ; tar -xf Metrolook-REL1_29-3795b1d.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/WikiArticleFeeds-REL1_29-8b12cb8.tar.gz ; tar -xf WikiArticleFeeds-REL1_29-8b12cb8.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/MobileFrontend-REL1_29-00fab28.tar.gz ; tar -xf MobileFrontend-REL1_29-00fab28.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/Variables-REL1_29-7a95992.tar.gz ; tar -xf Variables-REL1_29-7a95992.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/DynamicPageList-REL1_29-969980b.tar.gz ; tar -xf DynamicPageList-REL1_29-969980b.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/Scribunto-REL1_29-f1a4d6c.tar.gz ; tar -xf Scribunto-REL1_29-f1a4d6c.tar.gz
RUN cd extensions ; wget https://github.com/jmnote/SimpleMathJax/archive/v0.6.1.tar.gz -O SimpleMathJax-v0.6.1.tar.gz ; tar -xf SimpleMathJax-v0.6.1.tar.gz ; ln -s SimpleMathJax-0.6.1 SimpleMathJax
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/UploadLocal-REL1_29-1278d90.tar.gz ; tar -xf UploadLocal-REL1_29-1278d90.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/RSS-REL1_29-ec39acf.tar.gz ; tar -vxf RSS-REL1_29-ec39acf.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/SocialProfile-REL1_29-a68a73a.tar.gz ; tar -vxf SocialProfile-REL1_29-a68a73a.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/Flow-REL1_29-5971110.tar.gz ; tar -vxf Flow-REL1_29-5971110.tar.gz
RUN cd extensions ; wget https://extdist.wmflabs.org/dist/extensions/Echo-REL1_29-a3fd1af.tar.gz ; tar -vxf Echo-REL1_29-a3fd1af.tar.gz
